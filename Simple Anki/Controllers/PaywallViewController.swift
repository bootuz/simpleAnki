//
//  PaywallViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.06.2022.
//

import UIKit

class PaywallViewController: UIViewController {

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            PaywallViewController.createStackViewWith(text: "Unlimited decks and cards"),
            PaywallViewController.createStackViewWith(text: "Record pronunciation"),
            PaywallViewController.createStackViewWith(text: "Unlimited reviews per day"),
            PaywallViewController.createStackViewWith(text: "Set up reminders"),
            PaywallViewController.createStackViewWith(text: "Import decks in .csv format")
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }()

    lazy var unlockLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        let attrString = NSMutableAttributedString(string: "Unlock\nall features")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.systemBlue
        ]
        attrString.addAttributes(attributes, range: NSRange(location: 0, length: 6))
        label.attributedText = attrString
        return label
    }()

    lazy var subscribeButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton(title: "Subscribe")
        return button
    }()

    lazy var monthButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.titleLabel?.textAlignment = .center
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }()

    lazy var sixMonthButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.titleLabel?.textAlignment = .center
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }()

    lazy var yearButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.titleAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }()

    lazy var trialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.text = "Start with a 7 days free trial"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let rightButton = UIBarButtonItem(title: "Restore", style: .done, target: self, action: #selector(didTapRestore))
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        leftButton.tintColor = .systemGray
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton

        subscribeButton.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        view.addSubview(unlockLabel)
        view.addSubview(stackView)
        view.addSubview(subscribeButton)
        view.addSubview(monthButton)
        view.addSubview(sixMonthButton)
        view.addSubview(yearButton)
        view.addSubview(trialLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IAPManager.shared.checkTrial { [weak self] success in
            print(success)
            if success {
                self?.trialLabel.isHidden = false
            } else {
                self?.trialLabel.isHidden = true
            }
        }

        IAPManager.shared.getOfferings { [weak self] offering in
            guard let offering = offering else { return }
            self?.monthButton.setTitle("\(offering.products[0].prettyPrice) \(offering.products[0].prettyDuration)", for: .normal)
            self?.sixMonthButton.setTitle("\(offering.products[1].prettyPrice) \(offering.products[1].prettyDuration)", for: .normal)
            self?.yearButton.setTitle("\(offering.products[2].prettyPrice) \(offering.products[2].prettyDuration)", for: .normal)
        }
    }

    @objc private func didTapSubscribe() {
        subscribeButton.configuration?.showsActivityIndicator = true
        subscribeButton.isEnabled = false
        IAPManager.shared.purchase { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.subscribeButton.isEnabled = true
                self?.subscribeButton.configuration?.showsActivityIndicator = false
            }
        }
    }

    @objc private func didTapRestore() {
        IAPManager.shared.restorePurchases { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unlockLabel.frame = CGRect(x: 0, y: 146, width: view.frame.width, height: 144)
        monthButton.frame = CGRect(x: 16, y: 548, width: 104, height: 114)
        sixMonthButton.frame = CGRect(x: 104 + 16 + 16, y: 548, width: 104, height: 114)
        yearButton.frame = CGRect(x: 104 * 2 + 16 + 16 + 16, y: 548, width: 104, height: 114)

        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        trialLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 354.0),

            subscribeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            subscribeButton.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 50),

            trialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trialLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 520)

        ])

    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    private static func createStackViewWith(text: String) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0

        let image = UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit

        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }

    private func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
      }

}
