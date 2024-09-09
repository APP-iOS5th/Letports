import UIKit
import Kingfisher

class ProfileTVCell: UITableViewCell {
    
    weak var delegate: ProfileDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.backgroundColor = .lp_gray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
		label.font = UIFont.lp_Font(.regular, size: 18)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var simpleInfoLabel: UILabel = {
        let label = UILabel()
		label.font = UIFont.lp_Font(.regular, size: 13)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("프로필 변경", for: .normal)
        btn.setTitleColor(.lp_main, for: .normal)
        btn.backgroundColor = UIColor(named: "lp_white")
        btn.layer.borderColor = UIColor.lp_main.cgColor
        btn.layer.borderWidth = 1.0
        btn.layer.cornerRadius = 5
        btn.isHidden = false
		btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 12)
        btn.addTarget(self, action: #selector(editBtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var editableNickNameTrailingConstraint: NSLayoutConstraint?
    private var nonEditableNickNameTrailingConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileIV.image = nil
        profileIV.backgroundColor = .lp_gray
        
        nickNameLabel.text = nil
        simpleInfoLabel.text = nil
        
        editProfileBtn.isHidden = true
        
        editableNickNameTrailingConstraint?.isActive = false
        nonEditableNickNameTrailingConstraint?.isActive = true
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [profileIV, nickNameLabel, simpleInfoLabel, editProfileBtn].forEach {
            containerView.addSubview($0)
        }
        editableNickNameTrailingConstraint = nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: editProfileBtn.leadingAnchor, constant: -10)
        nonEditableNickNameTrailingConstraint = nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            profileIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            profileIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            profileIV.widthAnchor.constraint(equalToConstant: 80),
            profileIV.heightAnchor.constraint(equalToConstant: 80),
            
            nickNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nickNameLabel.leadingAnchor.constraint(equalTo: profileIV.trailingAnchor, constant: 10),
            nickNameLabel.heightAnchor.constraint(equalToConstant: 25),
            editableNickNameTrailingConstraint!,
            
            simpleInfoLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            simpleInfoLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            simpleInfoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            editProfileBtn.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            editProfileBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            editProfileBtn.widthAnchor.constraint(equalToConstant: 100),
            editProfileBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func editBtnDidTap() {
        self.delegate?.editProfileBtnDidTap()
    }
    
    func configure(user: LetportsUser, isEditable: Bool) {
        nickNameLabel.text = user.nickname
        simpleInfoLabel.text = user.simpleInfo
        editProfileBtn.isHidden = !isEditable
        
        if isEditable {
            editableNickNameTrailingConstraint?.isActive = true
            nonEditableNickNameTrailingConstraint?.isActive = false
        } else {
            editableNickNameTrailingConstraint?.isActive = false
            nonEditableNickNameTrailingConstraint?.isActive = true
        }
        
        guard let url = URL(string: user.image) else {
            profileIV.image = UIImage(systemName: "person.circle")
            profileIV.backgroundColor = .lpWhite
            return
        }
        
        let placeholder = UIImage()
        profileIV.kf.setImage(with: url, placeholder: placeholder, options: [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ])
    }
}
