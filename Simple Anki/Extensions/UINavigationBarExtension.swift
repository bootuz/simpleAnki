//
//  UINavigationBarExtension.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 28.04.2022.
//

import UIKit

extension UINavigationBar {
    @available(iOS 14, *)
    func cleanNavigationBarForiOS14() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.layoutIfNeeded()
    }
}
