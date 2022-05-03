//
//  SettingsTableViewCell.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2021.
//

import UIKit

class SwitchTableViewCell: BaseSettingsCell {
    static let identifier = "SwitchTableViewCell"
    weak var delegate: SwitchViewCellDelegate?
    
    let mySwitch: UISwitch = {
        return UISwitch()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mySwitch)
        accessoryType = .none
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mySwitch.sizeToFit()
        mySwitch.frame = CGRect(
            x: contentView.frame.size.width - mySwitch.frame.size.width - 20,
            y: (contentView.frame.size.height - mySwitch.frame.size.height) / 2,
            width: mySwitch.frame.size.width,
            height: mySwitch.frame.size.height)
        mySwitch.addTarget(self, action: #selector(switchAction), for: .valueChanged)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mySwitch.isOn = false
    }
    
    public func configure(with model: SwitchOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconImageView.tintColor = .systemGray
        mySwitch.isOn = model.isOn
    }
    
    @objc func switchAction() {
        delegate?.switchAction(with: self)
    }
}


