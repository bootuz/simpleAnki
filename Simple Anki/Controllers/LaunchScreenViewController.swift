//
//  LaunchScreenViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 25.06.2022.
//

import UIKit

protocol DoneDelegate: AnyObject {
    func vewController(isDismissed: Bool)
}

class LaunchScreenViewController: UIViewController {

    weak var delegate: DoneDelegate?

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    lazy var simpleLabel: UILabel = {
        let label = UILabel()
        label.text = "Simple"
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.minimumScaleFactor = 0.5
        return label
    }()

    lazy var ankiLabel: UILabel = {
        let label = UILabel()
        label.text = "Anki"
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textColor = .systemBlue
        label.minimumScaleFactor = 0.5
        return label
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
//        activityIndicator.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        IAPManager.shared.checkPermissions { [weak self] isActive in
            print(isActive)
            self?.dismiss(animated: false, completion: {
                self?.delegate?.vewController(isDismissed: true)
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.addArrangedSubview(simpleLabel)
        stackView.addArrangedSubview(ankiLabel)
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 80)
        ])
    }
}
