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

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Image.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        stackView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        self.dismiss(animated: false, completion: {
            self.delegate?.vewController(isDismissed: true)
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.addArrangedSubview(simpleLabel)
        stackView.addArrangedSubview(ankiLabel)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
