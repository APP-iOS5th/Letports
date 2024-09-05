import UIKit
import Kingfisher

class ProfileImageTVCell: UITableViewCell {
    weak var delegate: ProfileEditDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lp_white
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var profileImageBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(imageBtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .systemBlue
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .default
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .default
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        profileImageBtn.setImage(nil, for: .normal)
        profileImageBtn.transform = .identity
        profileImageBtn.layer.removeAllAnimations()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        
        [profileImageView, profileImageBtn].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            profileImageBtn.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            profileImageBtn.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileImageBtn.widthAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageBtn.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
    }
    
    @objc private func imageBtnDidTap() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.profileImageBtn.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.profileImageBtn.transform = CGAffineTransform.identity
            }) { _ in
                self.delegate?.didTapEditProfileImage()
            }
        }
    }
    
    func configure(with image: UIImage?) {
        if let image = image {
            profileImageView.image = image
            profileImageBtn.setImage(nil, for: .normal)
        } else {
            profileImageView.image = nil
            let personImage = UIImage(systemName: "person.circle")?
                .withTintColor(.systemBlue, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 100, height: 100))
            profileImageBtn.setImage(personImage, for: .normal)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageBtn.setNeedsLayout()
        profileImageBtn.layoutIfNeeded()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
