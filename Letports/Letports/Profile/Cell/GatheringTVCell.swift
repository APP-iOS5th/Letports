import UIKit
import Kingfisher

class GatheringTVCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gatheringIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lp_gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var isGatheringMasterIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.image = UIImage(systemName: "crown.fill")
        iv.tintColor = .lp_main
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gatheringName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gatheringInfo: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(named: "lp_gray")
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gatheringMasterIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lp_gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var gatheringMasterName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var personIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.2.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var memberCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar.circle.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var createGatheringDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.transform = CGAffineTransform.identity
        gatheringIV.image = nil
        gatheringMasterIV.image = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [gatheringIV, gatheringName, gatheringInfo, gatheringMasterIV, gatheringMasterName, personIV, memberCount, calendarIV, createGatheringDate, isGatheringMasterIV].forEach {
            containerView.addSubview($0)
        }
        
        // Gesture recognizer for the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerViewDidTap))
        tapGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            isGatheringMasterIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            isGatheringMasterIV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            isGatheringMasterIV.heightAnchor.constraint(equalToConstant: 18),
            isGatheringMasterIV.widthAnchor.constraint(equalToConstant: 18),
            
            gatheringIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            gatheringIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            gatheringIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            gatheringIV.widthAnchor.constraint(equalToConstant: 120),
            
            gatheringName.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 8),
            gatheringName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            
            gatheringInfo.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 8),
            gatheringInfo.topAnchor.constraint(equalTo: gatheringName.bottomAnchor, constant: 4),
            gatheringInfo.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            gatheringMasterIV.leadingAnchor.constraint(equalTo: gatheringIV.trailingAnchor, constant: 8),
            gatheringMasterIV.widthAnchor.constraint(equalToConstant: 12),
            gatheringMasterIV.heightAnchor.constraint(equalToConstant: 12),
            gatheringMasterIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            gatheringMasterName.leadingAnchor.constraint(equalTo: gatheringMasterIV.trailingAnchor, constant: 4),
            gatheringMasterName.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            gatheringMasterName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            personIV.leadingAnchor.constraint(equalTo: gatheringMasterName.trailingAnchor, constant: 8),
            personIV.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            personIV.widthAnchor.constraint(equalToConstant: 12),
            personIV.heightAnchor.constraint(equalToConstant: 12),
            personIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            memberCount.leadingAnchor.constraint(equalTo: personIV.trailingAnchor, constant: 4),
            memberCount.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            memberCount.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            calendarIV.leadingAnchor.constraint(equalTo: memberCount.trailingAnchor, constant: 8),
            calendarIV.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            calendarIV.widthAnchor.constraint(equalToConstant: 12),
            calendarIV.heightAnchor.constraint(equalToConstant: 12),
            calendarIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            createGatheringDate.leadingAnchor.constraint(equalTo: calendarIV.trailingAnchor, constant: 4),
            createGatheringDate.centerYAnchor.constraint(equalTo: gatheringMasterIV.centerYAnchor),
            createGatheringDate.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func containerViewDidTap() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = CGAffineTransform.identity
                }
            }
        )
    }
    
    func configure(with gathering: Gathering, with user: LetportsUser, with master: LetportsUser, isAnimationEnabled: Bool = true) {
        
        let date = gathering.gatheringCreateDate.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        isGatheringMasterIV.isHidden = gathering.gatheringMaster != user.uid
        gatheringName.text = truncateText(gathering.gatherName, limit: 16)
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = truncateText(master.nickname, limit: 16)
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = dateString
        
        if let gatheringUrl = URL(string: gathering.gatherImage) {
            gatheringIV.kf.setImage(with: gatheringUrl)
        } else {
            gatheringIV.image = nil
        }
        
        if let masterUrl = URL(string: master.image) {
            gatheringMasterIV.kf.setImage(with: masterUrl)
        } else {
            gatheringMasterIV.image = nil
        }
        
        // 컨테이너 뷰에 대한 제스처 설정 (애니메이션 활성화 여부에 따라)
        containerView.gestureRecognizers?.forEach { containerView.removeGestureRecognizer($0) }
        if isAnimationEnabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerViewDidTap))
            tapGesture.cancelsTouchesInView = false
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
    func configure(with gathering: Gathering, with master: LetportsUser, isAnimationEnabled: Bool = true) {
        let date = gathering.gatheringCreateDate.dateValue()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        isGatheringMasterIV.isHidden = true
        gatheringName.text = truncateText(gathering.gatherName, limit: 16)
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = truncateText(master.nickname, limit: 16)
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = dateString

        if let gatheringUrl = URL(string: gathering.gatherImage) {
            gatheringIV.kf.setImage(with: gatheringUrl)
        } else {
            gatheringIV.image = nil
        }

        if let masterUrl = URL(string: master.image) {
            gatheringMasterIV.kf.setImage(with: masterUrl)
        } else {
            gatheringMasterIV.image = nil
        }
        
        // 컨테이너 뷰에 대한 제스처 설정 (애니메이션 활성화 여부에 따라)
        containerView.gestureRecognizers?.forEach { containerView.removeGestureRecognizer($0) }
        if isAnimationEnabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerViewDidTap))
            tapGesture.cancelsTouchesInView = false
            containerView.addGestureRecognizer(tapGesture)
        }
    }
}

private func truncateText(_ text: String, limit: Int) -> String {
    return text.count > limit ? String(text.prefix(limit)) + "..." : text
}
