//
//  File.swift
//  Simple AnkiUITests
//
//  Created by Астемир Бозиев on 14.02.2022.
//

import Foundation

final class RandomGenerator {
    
    static func randomDeckName(nameLength: Int) -> String {
        return randomString(length: nameLength)
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map{ _ in letters.randomElement()! })
    }
}
