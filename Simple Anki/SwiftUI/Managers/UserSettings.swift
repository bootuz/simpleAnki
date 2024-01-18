//
//  UserSettings.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.08.2023.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("colorScheme") var colorScheme: Bool = false
}
