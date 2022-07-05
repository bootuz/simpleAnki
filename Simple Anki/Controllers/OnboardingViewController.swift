//
//  OnboardingViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 18.06.2022.
//

import UIKit

class OnboardingViewController: UIViewController {

    let models: [Feature] = [
        Feature(
            title: "Create collections",
            desription: "Add decks and cards with minimum taps",
            image: UIImage(systemName: "tray.full")
        ),
        Feature(
            title: "Import collections",
            desription: "Upload other anki decks in .apkg and .csv formats",
            image: UIImage(systemName: "tray.and.arrow.down")
        ),
        Feature(
            title: "Record pronunciation",
            desription: "Add voice recording of the words you want to learn",
            image: UIImage(systemName: "mic")
        ),
        Feature(
            title: "Set up reminders",
            desription: "Turn on notifications and study according to your schedule",
            image: UIImage(systemName: "bell")
        )
    ]

    let createFeature = FeatureView()
    let importFeature = FeatureView()
    let recordFeature = FeatureView()
    let reminderFeature = FeatureView()

    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 44, y: 0, width: 300, height: 300)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        let attrString = NSMutableAttributedString(string: "Welcome to Simple Anki")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.systemBlue
        ]
        attrString.addAttributes(attributes, range: NSRange(location: 11, length: 11))
        label.attributedText = attrString
        return label
    }()

    lazy var getStartedButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton(title: "Get started")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        getStartedButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)

    }

    @objc private func didTapContinue() {
        dismiss(animated: true) {
            OnboardingManager.shared.setIsNotNewUser()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createFeature.configure(model: models[0])
        importFeature.configure(model: models[1])
        recordFeature.configure(model: models[2])
        reminderFeature.configure(model: models[3])

        view.addSubview(createFeature)
        view.addSubview(importFeature)
        view.addSubview(recordFeature)
        view.addSubview(reminderFeature)
        view.addSubview(welcomeLabel)
        view.addSubview(getStartedButton)

        createFeature.frame = CGRect(
            x: 44,
            y: 260,
            width: view.bounds.width,
            height: 30
        )
        importFeature.frame = CGRect(
            x: 44,
            y: createFeature.frame.origin.y + createFeature.frame.height + 50,
            width: view.bounds.width,
            height: 30)
        recordFeature.frame = CGRect(
            x: 44,
            y: importFeature.frame.origin.y + importFeature.frame.height + 50,
            width: view.bounds.width,
            height: 30
        )
        reminderFeature.frame = CGRect(
            x: 44,
            y: recordFeature.frame.origin.y + recordFeature.frame.height + 50,
            width: view.bounds.width,
            height: 30
        )

        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getStartedButton.widthAnchor.constraint(equalToConstant: 300),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.safeTopAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -100)
        ])
    }
}
