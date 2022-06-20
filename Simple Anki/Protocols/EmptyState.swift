//
//  EmptyStateDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.04.2022.
//

import Foundation

protocol EmptyState {
    func setEmptyState()
    func setEmptyStateForMemorizedCards()
    func restore()
}

extension EmptyState {
    func setEmptyStateForMemorizedCards() {}
}
