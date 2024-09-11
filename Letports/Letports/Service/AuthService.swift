import Foundation
import Combine
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

protocol AuthServiceProtocol {
    func signInWithApple(idTokenString: String, nonce: String, completion: @escaping (Result<User, Error>) -> Void)
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<User, Error>) -> Void)
    func signOut() throws
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func signInWithApple(idTokenString: String, nonce: String, completion: @escaping (Result<User, Error>) -> Void) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        signInWithFirebase(credential: credential, completion: completion)
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: 0,
                                        userInfo:
                                            [NSLocalizedDescriptionKey:
                                                "Google Client ID not found in environment variables"])))
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: 1,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            self.signInWithFirebase(credential: credential, completion: completion)
        }
    }
    
    private func signInWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: 2,
                                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
                return
            }
            
            self.processUserData(for: user, credential: credential) { result in
                switch result {
                case .success(let processedUser):
                    completion(.success(processedUser))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func processUserData(for user: User, credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        let userID = user.uid
        
        FM.getData(collection: "Users", document: userID, type: LetportsUser.self)
            .flatMap { existingUser -> AnyPublisher<LetportsUser, FirestoreError> in
                let updatedUser = LetportsUser(
                    email: user.email ?? existingUser.email,
                    image: existingUser.image,
                    nickname: existingUser.nickname,
                    simpleInfo: existingUser.simpleInfo,
                    uid: userID,
                    userSports: existingUser.userSports,
                    userSportsTeam: existingUser.userSportsTeam
                )
                return FM.setData(collection: "Users", document: userID, data: updatedUser)
                    .map { updatedUser }
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<LetportsUser, FirestoreError> in
                if error == .documentNotFound {
                    let newUser = LetportsUser(
                        email: user.email ?? "",
                        image: user.photoURL?.absoluteString ?? "https://firebasestorage.googleapis.com/v0/b/letports-81f7f.appspot.com/o/Base_User_Image%2Fimage3x.png?alt=media&token=f9590a53-37db-46cf-acb9-be6055082eec",
                        nickname: user.displayName ?? self.generateSportsNickname(),
                        simpleInfo: "",
                        uid: userID,
                        userSports: "",
                        userSportsTeam: ""
                    )
                    return FM.setData(collection: "Users", document: userID, data: newUser)
                        .map { newUser }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { updatedUser in
                UserManager.shared.login(user: updatedUser)
                completion(.success(user))
            })
            .store(in: &cancellables)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        UserManager.shared.logout()
    }
    
    
    func generateSportsNickname() -> String {
        let adjectives = ["빠른", "강한", "민첩", "용맹", "날쌘", "힘찬", "지혜", "굳센", "기민", "용감",
                          "끈질", "대담", "적극", "눈부", "지치", "침착", "열정", "포기", "강인", "단호",
                          "끈기", "승리", "집중", "성실", "용의", "재빠", "신속", "과감", "끈질", "강력",
                          "불굴", "결단", "활기", "맹렬", "열정", "날렵", "위풍", "기운", "철저", "파워",
                          "유연", "부드", "정확", "빠릿", "초인", "단단", "독창", "눈부"]

        let animals = ["호랑", "독수", "사자", "표범", "매", "상어", "늑대", "곰", "치타", "여우",
                       "코끼", "뱀", "펭귄", "물개", "돌고", "소", "말", "돼지", "원숭", "양",
                       "고릴", "쥐", "토끼", "악어", "하마", "코뿔", "치타", "재규", "개", "수리",
                       "까치", "고양", "사슴", "참새", "오리", "독사", "펠리", "백호", "하이에", "캥거",
                       "스컹", "도마", "용", "청둥", "호박", "방울", "물소", "족제", "곰팡"]

        let sportsRoles = ["공격", "수비", "미드", "골키", "스프", "주전", "교체", "감독", "코치", "보조",
                           "캐처", "투수", "타자", "주루", "포워", "센터", "윙어", "풀백", "플레",
                           "리베", "세터", "디그", "리드", "중거", "단거", "장거", "하프", "풀백",
                           "킥커", "헤더", "스위", "프리", "페널", "롱스", "볼보", "주심", "부심",
                           "테니", "배드", "수영", "스키", "스노", "농구", "배구", "탁구", "볼링",
                           "골프", "양궁", "펜싱"]

        let randomAdjective = adjectives.randomElement() ?? "강한"
        let randomAnimal = animals.randomElement() ?? "호랑"
        let randomSportRole = sportsRoles.randomElement() ?? "공격"

        let nickname = "\(randomAdjective)\(randomAnimal)\(randomSportRole)"

        return nickname
    }
}
