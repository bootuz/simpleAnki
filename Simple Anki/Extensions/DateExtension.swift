//
//  DateExtension.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 03.05.2022.
//

import Foundation

extension Date {
    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
}
