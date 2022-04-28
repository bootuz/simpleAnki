//
//  DecksScrenTests.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//
import Foundation
import XCTest

class DecksScreenTests: BaseTest {
    let decksScreen = DecksScreen()
    
    override func setUp() {
        super.setUp()
//        waitForPageLoading(element: decksScreen.baseElement)
    }

    func testAddNewDeck() throws {
        let deckName = RandomGenerator.randomDeckName(nameLength: 10)
        decksScreen.addNewDeck(with: deckName)
    
        addTeardownBlock {
            self.decksScreen.deleteDeck(with: deckName)
        }
    }
}
