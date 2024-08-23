import UIKit

class GatheringCell: UITableViewCell {
    
    // 셀간 간격을 만들어주는 작업
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .lp_background_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var gatheringIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .lp_sub
        iv.clipsToBounds = true
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
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = UIColor(named: "lp_black")
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
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(gatheringIV)
        containerView.addSubview(gatheringName)
        containerView.addSubview(gatheringInfo)
        containerView.addSubview(gatheringMasterIV)
        containerView.addSubview(gatheringMasterName)
        containerView.addSubview(personIV)
        containerView.addSubview(memberCount)
        containerView.addSubview(calendarIV)
        containerView.addSubview(createGatheringDate)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 361),
            containerView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            gatheringIV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            gatheringIV.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            gatheringIV.widthAnchor.constraint(equalToConstant: 120),
            gatheringIV.heightAnchor.constraint(equalToConstant: 70),
            
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
            createGatheringDate.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
    }
    
    func configure(with gathering: Gathering) {
        gatheringName.text = gathering.gatheringName
        gatheringInfo.text = gathering.gatherInfo
        gatheringMasterName.text = gathering.gatheringMaster
        memberCount.text = "\(gathering.gatherNowMember)/\(gathering.gatherMaxMember)"
        createGatheringDate.text = "2023-08-01"
        gatheringIV.image = UIImage(named: "defaultImage")
        gatheringMasterIV.image = UIImage(named: "leaderImage")
    }
    
}
