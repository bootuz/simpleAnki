//
//  DatePickerViewCell.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 24.04.2022.
//

import Foundation
import UIKit

class DatePickerViewCell: UITableViewCell {
    static let identifier = "DatePickerViewCell"
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.date = Date()
        picker.datePickerMode = .time
        picker.locale = .current
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(datePicker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        datePicker.date = Date()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        datePicker.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 200)
    }
}
