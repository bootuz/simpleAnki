//
//  DatePickerViewCellDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 01.05.2022.
//

import Foundation
import UIKit

protocol DatePickerViewCellDelegate: AnyObject {
    func datePicker(with cell: UITableViewCell)
}
