import UIKit

protocol PostBtnDelegate: AnyObject {
    func didTapPostUploadBtn(type: PostType)
}

class PostBtn: UIView {
    private var logoHex: String?
    
    private let floatingButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 30
        btn.clipsToBounds = true
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        btn.configuration = configuration
        return btn
    }()
    
    private let optionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.layer.cornerRadius = 10
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alpha = 0.5
        sv.isHidden = true
        return sv
    }()
    
    private let postButton: UIButton = {
        let btn = UIButton(type: .custom)
        let boldFont = UIFont.lp_Font(.regular, size: 16)
        let attributedTitle = NSAttributedString(string: "게시글 작성", attributes: [.font: boldFont])
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.setTitleColor(UIColor(named: "lp_white"), for: .normal)
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10)
        btn.configuration = configuration
        return btn
    }()
    
    private let noticeButton: UIButton = {
        let btn = UIButton(type: .custom)
        let boldFont = UIFont.lp_Font(.regular, size: 16)
        let attributedTitle = NSAttributedString(string: "공지사항 작성", attributes: [.font: boldFont])
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.setTitleColor(UIColor(named: "lp_white"), for: .normal)
        btn.setImage(UIImage(systemName: "bell"), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 10
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10)
        btn.configuration = configuration
        return btn
    }()
    
    var isMaster: Bool = false {
        didSet {
            updateButtonVisibility()
        }
    }
    
    weak var delegate: PostBtnDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = optionsStackView.hitTest(convert(point, to: optionsStackView), with: event),
           !optionsStackView.isHidden {
            return hitView
        }
        
        if let hitView = floatingButton.hitTest(convert(point, to: floatingButton), with: event) {
            return hitView
        }
        
        if !optionsStackView.isHidden {
            hideOptionsStackView()
        }
        
        return super.hitTest(point, with: event)
    }
    
    private func setupUI() {
        addSubview(floatingButton)
        addSubview(optionsStackView)
        
        optionsStackView.addArrangedSubview(postButton)
        optionsStackView.addArrangedSubview(noticeButton)
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            floatingButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60),
            optionsStackView.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -10)
        ])
        
        updateFloatingButtonIcon(isPlus: true)
        
        floatingButton.addTarget(self, action: #selector(floatingBtnTap), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postBtnTap), for: .touchUpInside)
        noticeButton.addTarget(self, action: #selector(noticeBtnTap), for: .touchUpInside)
        
        optionsStackView.transform = CGAffineTransform(translationX: 0, y: 60)
    }
    
    private func updateButtonVisibility() {
        if isMaster {
            if !optionsStackView.arrangedSubviews.contains(noticeButton) {
                optionsStackView.addArrangedSubview(noticeButton)
            }
        } else {
            noticeButton.removeFromSuperview()
        }
    }
    
    private func updateFloatingButtonIcon(isPlus: Bool) {
        if isPlus {
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
            let largePencil = UIImage(systemName: "pencil", withConfiguration: largeConfig)
            floatingButton.setImage(largePencil, for: .normal)
            
            floatingButton.backgroundColor = UIColor(hex: logoHex ?? "")
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)
            let largePencil = UIImage(systemName: "xmark", withConfiguration: largeConfig)
            floatingButton.setImage(largePencil, for: .normal)
            
            floatingButton.backgroundColor = .lp_gray
        }
    }
    
    func setVisible(_ isVisible: Bool) {
        self.isHidden = !isVisible
    }
    
    @objc func floatingBtnTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.floatingButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.floatingButton.transform = .identity
            })
        })
        
        if optionsStackView.isHidden {
            showOptionsStackView()
        } else {
            hideOptionsStackView()
        }
    }
    
    @objc func postBtnTap() {
        optionsStackView.isHidden = true
        updateFloatingButtonIcon(isPlus: true)
        delegate?.didTapPostUploadBtn(type: .free)
    }
    
    @objc func noticeBtnTap() {
        optionsStackView.isHidden = true
        updateFloatingButtonIcon(isPlus: true)
        delegate?.didTapPostUploadBtn(type: .noti)
    }
    
    private func hideOptionsStackView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.updateFloatingButtonIcon(isPlus: true)
            self.optionsStackView.alpha = 0
            self.optionsStackView.transform = CGAffineTransform(translationX: 0, y: 60)
        }) { _ in
            self.optionsStackView.isHidden = true
        }
    }
    
    private func showOptionsStackView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.updateFloatingButtonIcon(isPlus: false)
            self.optionsStackView.isHidden = false
            self.optionsStackView.alpha = 1
            self.optionsStackView.transform = .identity
        }) { _ in }
    }
    
    func configure(logoHex: String?) {
        self.logoHex = logoHex
        floatingButton.backgroundColor = UIColor(hex: logoHex ?? "")
        optionsStackView.backgroundColor = UIColor(hex: logoHex ?? "")
    }
}
