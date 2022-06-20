//
//  FeatureView.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 18.06.2022.
//

import Foundation
import UIKit

struct Feature {
    let title: String
    let desription: String
    let image: UIImage?
}

class FeatureView: UIView {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var featureTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    lazy var featureDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(featureTitle)
        addSubview(featureDescription)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(
            x: 0,
            y: 10,
            width: 60,
            height: 50
        )
        featureTitle.frame = CGRect(
            x: 70,
            y: 0,
            width: 210,
            height: 32
        )
        featureDescription.frame = CGRect(
            x: 70,
            y: featureTitle.frame.origin.y + 14,
            width: 230,
            height: 64
        )
    }

    func configure(model: Feature) {
        imageView.image = model.image
        featureTitle.text = model.title
        featureDescription.text = model.desription
    }
}
