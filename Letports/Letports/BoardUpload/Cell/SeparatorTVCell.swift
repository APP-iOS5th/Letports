//
//  SeparatorTVCell.swift
//  Letports
//
//  Created by Chung Wussup on 8/9/24.
//

import UIKit

class SeparatorTVCell: UITableViewCell {

    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lp_separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    func setupUI() {
        self.contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    
    func configureCell(height: CGFloat) {
        separatorView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
