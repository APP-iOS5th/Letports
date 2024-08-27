

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import CryptoKit

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
            
            self?.signInWithFirebase(credential: credential, completion: completion)
        }
    }
    
    private func signInWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = authResult?.user {
                self?.createNewUser(user: user)
                    .sink(receiveCompletion: { result in
                        switch result {
                        case .finished:
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }, receiveValue: { _ in })
                    .store(in: &self!.cancellables)
            } else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: 2,
                                            userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        }
    }
    
    private func createNewUser(user: User) -> AnyPublisher<Void, FirestoreError> {
            let newUser = LetportsUser(
                email: user.email ?? "",
                image: user.photoURL?.absoluteString ?? "",
                nickname: user.displayName ?? "",
                simpleInfo: "",
                uid: user.uid,
                userSports: "",
                userSportsTeam: ""
            )
            
            return FM.setData(collection: "Users", document: user.uid, data: newUser)
        }
    
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}
