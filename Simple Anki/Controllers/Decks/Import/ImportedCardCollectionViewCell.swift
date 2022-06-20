//
//  ImportedCardTableViewCell.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 09.05.2022.
//

import UIKit

class ImportedCardCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImportedCardTableViewCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()

    let frontField: UITextField = {
        let field = UITextField()
        field.placeholder = "Front word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .next
        return field
    }()

    let backField: UITextField = {
        let field = UITextField()
        field.placeholder = "Back word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .done
        return field
    }()

    private let frontLabel: UILabel = {
        let label = UILabel()
        label.text = "Front"
        label.textColor = .systemGray
        return label
    }()

    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = "Back"
        label.textColor = .systemGray
        return label
    }()

    private let separationLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        cardView.addSubview(separationLine)
        cardView.addSubview(frontLabel)
        cardView.addSubview(backLabel)
        cardView.addSubview(frontField)
        cardView.addSubview(backField)
        contentView.addSubview(cardView)
        frontField.isEnabled = false
        backField.isEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let leftPadding = 16.0
        let rightPadding = leftPadding * 2.0
        let labelHeight = 15.0
        let labelWidth = 100.0

        cardView.frame = CGRect(
            x: leftPadding,
            y: 0,
            width: contentView.bounds.width - rightPadding,
            height: 200.0
        )
        separationLine.frame = CGRect(
            x: leftPadding,
            y: 200 / 2.0,
            width: cardView.frame.width - rightPadding,
            height: 1.0
        )
        frontLabel.frame = CGRect(
            x: leftPadding,
            y: 15.0,
            width: labelWidth,
            height: labelHeight
        )
        backLabel.frame = CGRect(
            x: leftPadding,
            y: separationLine.frame.origin.y + 15.0,
            width: labelWidth,
            height: labelHeight
        )
        frontField.frame = CGRect(
            x: leftPadding,
            y: 50.0,
            width: cardView.frame.width - rightPadding,
            height: 40.0
        )
        backField.frame = CGRect(
            x: leftPadding,
            y: separationLine.frame.origin.y + 50.0,
            width: cardView.frame.width - rightPadding,
            height: 40.0
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        frontField.text = nil
        backField.text = nil
    }

    public func configure(with model: APKGCard?) {
        frontField.text = model?.front
        backField.text = model?.back
    }
}
