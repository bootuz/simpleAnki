//
//  DecksScreen.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//

import Foundation
import XCTest


class DecksScreen: BaseScreen {

    private lazy var addButton = app.navigationBars["Decks"]/*@START_MENU_TOKEN@*/.buttons["addButton"]/*[[".buttons[\"add\"]",".buttons[\"addButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    private lazy var noDecksStaticText = app.staticTexts["There are no decks yet"]
    private lazy var addNewDeckAlert = AddNewDeckAlert()
    lazy var baseElement = addButton

    func tapAddButton() {
        let _ = addButton.waitForExistence(timeout: BaseTest.Constants.defaultWaitTime)
        addButton.tap()
    }
    
    func addNewDeck(with deckName: String) {
        tapAddButton()
        addNewDeckAlert.textField.typeText(deckName)
        addNewDeckAlert.addButton.tap()
    }
    
    func deleteDeck(with deckName: String) {
        let row = getRow(by: deckName)
        row.swipeLeft()
        row.buttons["Delete"].tap()
    }
    
    private func getRow(by text: String) -> XCUIElement {
        return app.tables.cells.containing(.staticText, identifier: text).element
    }
}
