//
//  WaitUtillities.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//

import Foundation
import XCTest



func waitForPageLoading(element: XCUIElement) {
    XCTAssertTrue(element.waitForExistence(timeout: BaseTest.Constants.defaultLoadingTime))
}
