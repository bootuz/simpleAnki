//
//  EmptyStateDelegate.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.04.2022.
//

import Foundation


protocol EmptyStateDelegate {
    func setEmptyState()
    func setEmptyStateForMemorizedCards()
    func restore()
}

extension EmptyStateDelegate {
    func setEmptyStateForMemorizedCards() {}
}
