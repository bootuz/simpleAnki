//
//  UILabelExtension.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.06.2022.
//

import UIKit

extension UILabel {

    func addTrailing(image: UIImage, text: String) {
        let attachment = NSTextAttachment()
        attachment.image = image

        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])

        string.append(attachmentString)
        self.attributedText = string
    }

    func addLeading(image: UIImage, text: String) {
        let attachment = NSTextAttachment()
        attachment.image = image

        let attachmentString = NSMutableAttributedString(attachment: attachment)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.systemBlue
        ]
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)

        let string = NSMutableAttributedString(string: text, attributes: [:])
        mutableAttributedString.append(string)
        mutableAttributedString.addAttributes(attributes, range: NSRange(location: 0, length: attachmentString.length))
        self.attributedText = mutableAttributedString
    }

    func generateProFeatureLabel(text: String) -> UILabel {
        let checkMarkImage = UIImage(systemName: "checkmark")!
        self.addLeading(image: checkMarkImage, text: text)
        return self
    }
}
