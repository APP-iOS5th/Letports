

import UIKit

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
                    self?.loginSuccess?()
                case .failure(let error):
                    self?.loginFailure?(error)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            loginFailure?(error)
        }
    }
}
