//
//  GatheringBoardUploadMainTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit
import Kingfisher

class GatheringUploadMainTVCell: UITableViewCell {
    private(set) var teamLogo: UIImageView = {
        let iv = UIImageView(frame: .init())
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private(set) var teamName: UILabel = {
        let label = UILabel()
		label.font = .lp_Font(.regular, size: 28)
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Setup UI
    private func setupUI() {
        [teamLogo, teamName].forEach {
            self.contentView.addSubview($0)
        }
                
        NSLayoutConstraint.activate([
            teamLogo.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 11),
            teamLogo.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            teamLogo.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            teamLogo.heightAnchor.constraint(equalToConstant: 70),
            teamLogo.widthAnchor.constraint(equalToConstant: 70),
            
            teamName.leadingAnchor.constraint(equalTo: teamLogo.trailingAnchor, constant: 25),
            teamName.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            teamName.centerYAnchor.constraint(equalTo: teamLogo.centerYAnchor)
        ])
        
    }
    
    func configureCell(sportsTeam: SportsTeam) {
        self.teamName.text = sportsTeam.teamName
        let url = URL(string: sportsTeam.teamLogo)
        self.teamLogo.kf.setImage(with: url, options: [.cacheOriginalImage])
        
    }
}
