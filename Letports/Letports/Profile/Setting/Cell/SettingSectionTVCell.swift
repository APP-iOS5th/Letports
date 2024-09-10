import UIKit
import UserNotifications

class SettingSectionTVCell: UITableViewCell {
    
    var celltype: SettingCellType?
    weak var delegate: SettingDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lp_background_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleIV: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .lp_black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.lp_black, for: .normal)
        btn.titleLabel?.font = UIFont.lp_Font(.regular, size: 18)
        btn.addTarget(self, action: #selector(titlebtnDidTap), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .lp_main
        toggle.isHidden = true
        toggle.addTarget(self, action: #selector(toggleDidTap), for: .touchUpInside)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.lp_Font(.regular, size: 14)
        label.textColor = .lp_gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabelLeadingConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .lp_background_white
        contentView.addSubview(containerView)
        
        [titleIV, titleLabel, toggleSwitch, versionLabel].forEach {
            containerView.addSubview($0)
        }
        
        titleLabelLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: titleIV.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            titleIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleIV.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleIV.widthAnchor.constraint(equalToConstant: 20),
            titleIV.heightAnchor.constraint(equalToConstant: 20),

            titleLabelLeadingConstraint!,
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            versionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func toggleDidTap() {
        delegate?.toggleDidTap()
    }
    
    @objc func titlebtnDidTap() {
        guard let celltype = celltype else { return }
        delegate?.buttonDidTap(cellType: celltype)
    }
    
    func configure(cellType: SettingCellType, notificationState: Bool) {
        self.celltype = cellType
        
        
        switch cellType {
        case .appInfo:
            configureAppInfo()
        case .notification:
            configureNotification(notificationState: notificationState)
        case .appTermsofService:
            configureAppTermsOfService()
        case .openLibrary:
            configureOpenLibrary()
        case .logout:
            configureLogout()
        case .personnalInfo:
            configurePersonalInfo()
        case .exit:
            configureExit()
        }
    }
    
    private func resetUI() {
        versionLabel.isHidden = true
        toggleSwitch.isHidden = true
        titleIV.image = nil
        titleLabel.setTitleColor(.lp_black, for: .normal)
        titleLabel.titleLabel?.font = UIFont.lp_Font(.regular, size: 20)
    
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = false
    }
    
    private func configureAppInfo() {
        titleIV.image = UIImage(systemName: "info.circle")?
            .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        
        titleLabel.setTitle("앱 정보", for: .normal)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
            versionLabel.isHidden = false
        }
    }
    
    private func configureNotification(notificationState: Bool) {
        titleIV.image = UIImage(systemName: "bell")?
            .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        titleLabel.setTitle("알림", for: .normal)
        toggleSwitch.isHidden = false
        toggleSwitch.isOn = notificationState
    }
    
    private func configureAppTermsOfService() {
        titleIV.image = UIImage(systemName: "book.closed")?
            .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        titleLabel.setTitle("서비스 이용약관", for: .normal)
    }
    
    private func configureOpenLibrary() {
        titleIV.image = UIImage(systemName: "book")?
            .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        titleLabel.setTitle("오픈소스 라이브러리", for: .normal)
    }
    
    private func configureLogout() {
        titleIV.image = UIImage(systemName: "arrow.down.left.circle")?
            .withTintColor(.lp_tint, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        titleLabel.setTitle("로그아웃", for: .normal)
        titleLabel.setTitleColor(.lp_tint, for: .normal)
    }
    
    private func configurePersonalInfo() {
        titleIV.image = UIImage(systemName: "person")?
            .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
            .resized(size: CGSize(width: 20, height: 20))
        titleLabel.setTitle("개인정보 처리방침", for: .normal)
    }
    
    private func configureExit() {
        titleIV.image = nil
        titleLabel.setTitle("회원탈퇴", for: .normal)
        titleLabel.setTitleColor(.lpLightGray, for: .normal)
        titleLabel.titleLabel?.font = UIFont.lp_Font(.regular, size: 15)
        
        titleLabelLeadingConstraint?.isActive = false
        
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        titleLabelLeadingConstraint = titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 100)
        titleLabelLeadingConstraint?.isActive = true
    }
}
