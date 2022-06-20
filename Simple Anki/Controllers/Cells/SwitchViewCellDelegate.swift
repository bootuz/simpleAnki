//
//  CustomViewCellDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 27.04.2022.
//

import Foundation
import UIKit

protocol SwitchViewCellDelegate: AnyObject {
    func switchAction(with cell: UITableViewCell)
}
