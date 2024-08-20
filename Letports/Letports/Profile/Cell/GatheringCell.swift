import UIKit

class GatheringCell: UITableViewCell {
     lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
         view.backgroundColor = .lp_white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
     lazy var gatheringIV: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     lazy var gatheringName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var gatheringInfo: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor(named: "lp_gray")
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
     lazy var gatheringMasterIV: UIImageView = {
        let iv = UIImageView()
         iv.layer.cornerRadius = 5
         iv.contentMode = .scaleAspectFill
         iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     lazy var gatheringMasterName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textAlignment = .left
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var personIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.2.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     lazy var memberCount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = UIColor(named: "lp_black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var calendarIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar.circle.fill")
        iv.tintColor = UIColor(named: "lp_black")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     lazy var createGatheringDate: UILabel = {
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
            gatheringIV.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            gatheringIV.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
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
    
   
    
}
