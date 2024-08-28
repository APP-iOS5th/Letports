import UIKit

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
    
    private  lazy var gatheringMasterIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
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
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selectionStyle = .none
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        contentView.backgroundColor = .lp_background_white
        
        [gatheringIV, gatheringName, gatheringInfo, gatheringMasterIV,gatheringMasterName,personIV,memberCount,calendarIV,createGatheringDate, isGatheringMasterIV].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
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
            gatheringMasterIV.widthAnchor.constraint(equalToConstant: 10),
            gatheringMasterIV.heightAnchor.constraint(equalToConstant: 10),
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
            createGatheringDate.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
    }
    
    func configure(with gathering: Gathering, with user: LetportsUser) {
        if gathering.gatheringMaster == user.uid {
            isGatheringMasterIV.isHidden = false
        }
        gatheringName.text = gathering.gatherName
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = gathering.gatheringMaster
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = gathering.gatheringCreateDate
        guard let url = URL(string: gathering.gatherImage) else {
            gatheringIV.image = UIImage(systemName: "person.circle")
            gatheringMasterIV.image = UIImage(systemName: "person.circle")
            return
        }
        let placeholder = UIImage(systemName: "person.circle")
        gatheringIV.kf.setImage(with: url, placeholder: placeholder)
        gatheringMasterIV.kf.setImage(with: url, placeholder: placeholder)
    }
}
