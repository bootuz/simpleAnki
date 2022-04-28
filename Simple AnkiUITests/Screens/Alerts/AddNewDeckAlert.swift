//
//  AddNewDeckAlert.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//

import Foundation
import XCTest

class AddNewDeckAlert: BaseScreen {
    lazy var alert = app.alerts["Add new deck"]
    lazy var elementsQuery = alert.scrollViews.otherElements
    lazy var addButton = elementsQuery.buttons["Add"]
    lazy var cancelButton = elementsQuery.buttons["Cancel"]
    lazy var textField = elementsQuery.collectionViews.textFields["Give deck a name"]
}
