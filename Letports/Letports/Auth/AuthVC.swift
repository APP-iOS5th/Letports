
import UIKit
import AuthenticationServices
import GoogleSignIn


class AuthVC: UIViewController {
    private let viewModel: AuthVM
    private let authService: AuthService
    
    private var currentNonce: String?
    
    init(viewModel: AuthVM, authService: AuthService) {
        self.viewModel = viewModel
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var appleSignInBtn: ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        btn.addTarget(self, action: #selector(appleSignInBtnTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var googleSignInBtn: GIDSignInButton = {
        let btn = GIDSignInButton()
        btn.style = .standard
        btn.addTarget(self, action: #selector(googleSignInBtnTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .lpBackgroundWhite
        view.addSubview(appleSignInBtn)
        view.addSubview(googleSignInBtn)
        
        NSLayoutConstraint.activate([
            appleSignInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleSignInBtn.widthAnchor.constraint(equalToConstant: 280),
            appleSignInBtn.heightAnchor.constraint(equalToConstant: 44),
            googleSignInBtn.topAnchor.constraint(equalTo: appleSignInBtn.bottomAnchor, constant: 20),
            googleSignInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInBtn.widthAnchor.constraint(equalToConstant: 280),
            googleSignInBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func appleSignInBtnTapped() {
        let nonce = authService.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = authService.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc private func googleSignInBtnTapped() {
        viewModel.signInWithGoogle(presenting: self)
    }
}

extension AuthVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            viewModel.signInWithApple(idTokenString: idTokenString, nonce: nonce)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Appel errored: \(error)")
    }
}

extension AuthVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
