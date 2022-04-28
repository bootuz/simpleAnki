//
//  BaseTest.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//

import XCTest


class BaseTest: XCTestCase {
    private var baseScreen = BaseScreen()
    
    public enum Constants {
        public static let defaultWaitTime = 10.0
        public static let defaultLoadingTime = 30.0
    }

    lazy var app = baseScreen.app

    open override func setUp() {
        app.launch()
        app.launchArguments = ["enable-testing"]
        continueAfterFailure = false
    }

    open override func tearDown() {
        app.terminate()
    }
}
