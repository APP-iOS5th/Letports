//
//  AppInfoTVCell.swift
//  Letports
//
//  Created by mosi on 9/4/24.
//

import UIKit

class SettingSectionTVCell: UITableViewCell {
    
    var celltype: SettingCellType?
    var delegate: SettingDelegate?
    
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
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
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
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lp_gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            titleIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleIV.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleIV.trailingAnchor, constant: 10),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            versionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func titlebtnDidTap() {
        guard let celltype = celltype else { return }
        delegate?.buttonDidTap(cellType: celltype)
    }
    
    @objc func toggleDidTap() {
        delegate?.toggleDidtap()
    }
    
    func configure(cellType: SettingCellType) {
        self.celltype = cellType
        switch cellType {
        case .appInfo:
            titleIV.image = UIImage(systemName: "info.circle")?
                .withTintColor(.lp_black, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 20, height: 20))
            titleLabel.setTitle("앱 정보", for: .normal)
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            versionLabel.text = version
            versionLabel.isHidden = false
        case .notification:
            titleIV.image = UIImage(systemName: "bell")?.withTintColor(.lp_black, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 20, height: 20))
            titleLabel.setTitle("알림 설정", for: .normal)
            toggleSwitch.isHidden = false
        case .AppTermsofService:
            titleIV.image = UIImage(systemName: "book.closed")?.withTintColor(.lp_black, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 20, height: 20))
            titleLabel.setTitle("앱 사용약관", for: .normal)
        case .openLibrary:
            titleIV.image = UIImage(systemName: "book")?.withTintColor(.lp_black, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 20, height: 20))
            titleLabel.setTitle("오픈소스 라이브러리", for: .normal)
        case .logout:
            titleIV.image = UIImage(systemName: "arrow.down.left.circle")?.withTintColor(.lp_tint, renderingMode: .alwaysTemplate)
                .resized(size: CGSize(width: 20, height: 20))
            titleIV.image?.withTintColor(.lp_tint)
            titleLabel.setTitle("로그아웃", for: .normal)
            titleLabel.setTitleColor(.lp_tint, for: .normal)
        }
    }
}
