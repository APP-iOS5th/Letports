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
                        image: user.photoURL?.absoluteString ?? "https://firebasestorage.googleapis.com/v0/b/letports-81f7f.appspot.com/o/Base_User_Image%2Fimage%403x.png?alt=media&token=4b201641-336a-413b-a5f8-3cb09e39fffe",
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
        let adjectives = ["빠른", "강한", "민첩한", "용맹한", "날쌘", "힘찬", "지혜로운", "굳센", "기민한", "용감한",
                          "끈질긴", "대담한", "적극적인", "눈부신", "지치지않는", "침착한", "열정적인", "포기하지않는",
                          "강인한", "단호한", "끈기있는", "승리하는", "집중하는", "성실한", "용의주도한", "재빠른",
                          "신속한", "과감한", "끈질긴", "강력한", "불굴의", "결단력있는", "활기찬", "맹렬한", "열정적인",
                          "날렵한", "위풍당당한", "기운찬", "철저한", "끈기있는", "파워풀한", "유연한", "부드러운", "정확한",
                          "빠릿한", "초인적인", "강력한", "단단한", "독창적인", "눈부신"]
        
        let animals = ["호랑이", "독수리", "사자", "표범", "매", "상어", "늑대", "곰", "치타", "여우",
                       "코끼리", "뱀", "펭귄", "물개", "돌고래", "소", "말", "돼지", "원숭이", "양",
                       "고릴라", "쥐", "토끼", "악어", "하마", "코뿔소", "치타", "재규어", "개", "수리부엉이",
                       "까치", "고양이", "사슴", "참새", "오리", "독사", "펠리칸", "늑대", "백호", "하이에나",
                       "캥거루", "스컹크", "도마뱀", "용", "청둥오리", "호박벌", "방울뱀", "물소", "족제비", "곰팡이"]
        
        let sportsRoles = ["공격수", "수비수", "미드필더", "골키퍼", "스프린터", "주전", "교체선수", "감독", "코치", "보조코치",
                           "캐처", "투수", "타자", "주루코치", "포워드", "스트라이커", "센터", "윙어", "풀백", "미드필더",
                           "플레이메이커", "리베로", "세터", "디그", "리드오프", "중거리주자", "단거리주자", "장거리주자",
                           "하프백", "풀백", "킥커", "헤더", "스위퍼", "프리키커", "페널티킥", "롱스로인", "볼보이", "주심",
                           "부심", "테니스선수", "배드민턴선수", "수영선수", "스키선수", "스노보드선수", "농구선수", "배구선수",
                           "탁구선수", "볼링선수", "골프선수", "양궁선수", "펜싱선수"]
        
        let randomAdjective = adjectives.randomElement() ?? "강한"
        let randomAnimal = animals.randomElement() ?? "호랑이"
        let randomSportRole = sportsRoles.randomElement() ?? "공격수"
        
        let nickname = "\(randomAdjective)\(randomAnimal)\(randomSportRole)"
        
        return nickname
    }
}
