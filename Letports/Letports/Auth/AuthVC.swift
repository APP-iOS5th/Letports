
import UIKit
import AuthenticationServices
import GoogleSignIn


class AuthVC: UIViewController {
    private let viewModel: AuthVM
    private let authService: AuthService
    
    private var currentNonce: String?
    
    private let logoIconImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "login")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    init(viewModel: AuthVM, authService: AuthService) {
        self.viewModel = viewModel
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var appleSignInBtn: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.background.backgroundColor = .black
        configuration.baseForegroundColor = .white
        
        configuration.imagePadding = 10
        
        configuration.image = UIImage(named: "apple_login")
        configuration.imagePlacement = .leading
        
        let btn = UIButton(configuration: configuration, primaryAction: nil)
        btn.layer.cornerRadius = 10
      
        btn.setTitle("애플로 쉬운 로그인", for: .normal)
        
        btn.addTarget(self, action: #selector(appleSignInBtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var googleSignInBtn: UIButton = {
        var configuration = UIButton.Configuration.plain()
        
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.imagePadding = 10
        configuration.image = UIImage(named: "google_login")
        configuration.imagePlacement = .leading
        
        let btn = UIButton(configuration: configuration, primaryAction: nil)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.black.cgColor
        
        btn.setTitle("구글로 쉬운 로그인", for: .normal)
        
        btn.addTarget(self, action: #selector(googleSignInBtnDidTap), for: .touchUpInside)
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
        view.addSubview(logoIconImage)
        
        NSLayoutConstraint.activate([
            logoIconImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            logoIconImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoIconImage.widthAnchor.constraint(equalToConstant: 250),
            logoIconImage.heightAnchor.constraint(equalTo: logoIconImage.widthAnchor, multiplier: 1/3.2),
            
            
            appleSignInBtn.topAnchor.constraint(equalTo: logoIconImage.bottomAnchor, constant: 200),
            appleSignInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInBtn.widthAnchor.constraint(equalToConstant: 280),
            appleSignInBtn.heightAnchor.constraint(equalToConstant: 44),
            
            googleSignInBtn.topAnchor.constraint(equalTo: appleSignInBtn.bottomAnchor, constant: 20),
            googleSignInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInBtn.widthAnchor.constraint(equalToConstant: 280),
            googleSignInBtn.heightAnchor.constraint(equalToConstant: 44),
            googleSignInBtn.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func appleSignInBtnDidTap() {
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
    
    @objc private func googleSignInBtnDidTap() {
        viewModel.signInWithGoogle(presenting: self)
    }
}

extension AuthVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
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
