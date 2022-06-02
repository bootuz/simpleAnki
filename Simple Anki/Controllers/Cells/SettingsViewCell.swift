//
//  SettingsTableViewCell.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2021.
//

import UIKit

class SettingsTableViewCell: BaseSettingsCell {
    static let identifier = "SettingsTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with model: Option) {
        label.text = model.title
        iconImageView.image = model.icon
        iconImageView.tintColor = .systemGray
    }
}
