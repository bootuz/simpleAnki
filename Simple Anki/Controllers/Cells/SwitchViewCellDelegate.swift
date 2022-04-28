//
//  CustomViewCellDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 27.04.2022.
//

import Foundation


protocol SwitchViewCellDelegate: AnyObject {
    func whenSwitchIsOn()
    func whenSwitchIsOff()
}
