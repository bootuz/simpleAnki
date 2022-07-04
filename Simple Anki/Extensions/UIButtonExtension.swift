//
//  UIButtonExtension.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 13.05.2022.
//

import Foundation
import UIKit

extension UIButton {
    func configureDefaultButton(title: String) {
        defaultConfiguration()
        self.configuration?.title = title
    }

    func configureDefaultButton() {
        defaultConfiguration()
    }

    func configureDefaultButton(title: String, image: UIImage?) {
        defaultConfiguration()
        self.configuration?.title = title
        self.configuration?.image = image
        self.configuration?.imagePlacement = .trailing
        self.configuration?.imagePadding = 10
    }

    private func defaultConfiguration() {
        self.configuration = .filled()
        self.configuration?.baseBackgroundColor = .systemBlue
        self.configuration?.baseForegroundColor = .white
        self.configuration?.cornerStyle = .large
        self.configuration?.titleAlignment = .center
    }

    func configureTintedButton(title: String, image: UIImage? = nil, color: UIColor? = .systemBlue) {
        self.configuration = .tinted()
        self.configuration?.baseBackgroundColor = color
        self.configuration?.baseForegroundColor = color
        self.configuration?.title = title
        self.configuration?.cornerStyle = .large
        self.configuration?.titleAlignment = .center
    }

    func configureIconButton(configuration: Configuration, image: UIImage?) {
        self.configuration = configuration
        self.configuration?.cornerStyle = .large
        self.configuration?.image = image
        self.configuration?.titleAlignment = .center
        self.configuration?.baseForegroundColor = .systemBlue
    }

}
