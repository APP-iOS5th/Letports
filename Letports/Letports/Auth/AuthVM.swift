import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Combine

class AuthVM {
    private let authService: AuthServiceProtocol
    
    var loginSuccess: (() -> Void)?
    var loginFailure: ((Error) -> Void)?
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    func signInWithApple(idTokenString: String, nonce: String) {
        authService.signInWithApple(idTokenString: idTokenString, nonce: nonce) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.registerTokenIfNeeded()
                    self?.loginSuccess?()
                case .failure(let error):
                    self?.loginFailure?(error)
                }
            }
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) {
        authService.signInWithGoogle(presenting: presenting) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.registerTokenIfNeeded()
                    self?.loginSuccess?()
                case .failure(let error):
                    self?.loginFailure?(error)
                }
            }
        }
    }
    
    private func registerTokenIfNeeded() {
        guard let fcmToken = Messaging.messaging().fcmToken, let user = Auth.auth().currentUser else {
            print("Cannot register FCM token, missing data.")
            return
        }
        NotificationService.shared.setUIDAndRegisterToken(uid: user.uid, fcmToken: fcmToken)
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            loginFailure?(error)
        }
    }
}
