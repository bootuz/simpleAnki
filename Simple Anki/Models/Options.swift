//
//  Section.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2021.
//

import UIKit

struct Option {
	let title: String
	let icon: UIImage?
	let handler: (() -> Void)?
}

struct DatePickerOption {
    let picker: UIDatePicker
}

struct SwitchOption {
	let title: String
	let icon: UIImage?
	let isOn: Bool
    let switchType: SwitchType
    let handler: (() -> Void)?
}

enum OptionType {
	case staticCell(model: Option)
	case switchCell(model: SwitchOption)
    case datePickerCell
}

enum SwitchType {
    case darkMode
    case reminder
}

struct Section {
	let title: String
	let options: [OptionType]
}
