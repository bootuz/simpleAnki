//
//  UIButtonExtension.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 13.05.2022.
//

import Foundation
import UIKit


extension UIButton {
    func configureDefaultButton(title: String, image: UIImage? = nil) -> UIButton {
        self.configuration = .filled()
        self.configuration?.baseBackgroundColor = .systemBlue
        self.configuration?.baseForegroundColor = .white
        self.configuration?.title = title
        self.configuration?.cornerStyle = .large
        self.configuration?.titleAlignment = .center
        if let image = image {
            self.configuration?.image = image
            self.configuration?.imagePlacement = .trailing
            self.configuration?.imagePadding = 10
        }
        return self
    }
    
    func configureTintedButton(title: String, image: UIImage? = nil, color: UIColor? = .systemBlue) -> UIButton {
        self.configuration = .tinted()
        self.configuration?.baseBackgroundColor = color
        self.configuration?.baseForegroundColor = color
        self.configuration?.title = title
        self.configuration?.cornerStyle = .large
        self.configuration?.titleAlignment = .center
        return self
    }
    
    
    
    func configureIconButton(configuration: UIButton.Configuration, image: UIImage?) -> UIButton {
        self.configuration = configuration
        self.configuration?.cornerStyle = .large
        self.configuration?.image = image
        self.configuration?.titleAlignment = .center
        self.configuration?.baseForegroundColor = .systemBlue
        return self
    }
}
