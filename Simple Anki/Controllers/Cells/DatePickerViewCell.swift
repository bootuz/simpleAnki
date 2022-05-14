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
    weak var delegate: DatePickerViewCellDelegate?
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.locale = .current
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(datePickerAction), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        datePicker.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 200)
    }
    
    @objc func datePickerAction() {
        delegate?.datePicker(with: self)
    }
    
    func configure(with model: DatePickerOption) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .current
        let date = dateFormatter.date(from: model.date) ?? Date()
        datePicker.date = date
    }
}
