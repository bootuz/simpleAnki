//
//  PaywallViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 21.06.2022.
//

import UIKit
import Qonversion
import FirebaseAnalytics

class PaywallViewController: UIViewController {

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            PaywallViewController.createStackViewWith(text: "Record pronunciation"),
            PaywallViewController.createStackViewWith(text: "Set up reminders"),
            PaywallViewController.createStackViewWith(text: "Import .apkg and .csv decks")
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }()

    var activityIndicator = UIActivityIndicatorView(style: .medium)

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
        button.configureDefaultButton()
        return button
    }()

    lazy var sixMonthButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton()
        return button
    }()

    lazy var annualButton: UIButton = {
        let button = UIButton()
        button.configureDefaultButton()
        return button
    }()

    lazy var tosButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.titleAlignment = .center
        button.configuration?.baseForegroundColor = .link
        let container = AttributeContainer([.font : UIFont.systemFont(ofSize: 14)])
        let attrStr = AttributedString("Terms of Service", attributes: container)
        button.configuration?.attributedTitle = attrStr
        return button
    }()

    lazy var privacyPolicyButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.titleAlignment = .center
        button.configuration?.baseForegroundColor = .link
        let container = AttributeContainer([.font : UIFont.systemFont(ofSize: 14)])
        let attrStr = AttributedString("Privacy Policy", attributes: container)
        button.configuration?.attributedTitle = attrStr
        return button
    }()

    lazy var andLabel: UILabel = {
        let label = UILabel()
        label.text = "and"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    lazy var tosAndPpStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = -3
        return stack
    }()

    lazy var trialLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemOrange
        label.text = "Start with a 7-day free trial"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()

    weak var delegate: DoneDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        let rightButton = UIBarButtonItem(
            title: "Restore",
            style: .done,
            target: self,
            action: #selector(didTapRestore)
        )
        leftButton.tintColor = .systemGray
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        tosAndPpStackView.addArrangedSubview(privacyPolicyButton)
        view.addSubview(tosAndPpStackView)
        view.addSubview(stackView)
        view.addSubview(annualButton)
        view.addSubview(trialLabel)
        view.addSubview(unlockLabel)
        view.addSubview(monthButton)

        tosButton.addTarget(self, action: #selector(didTapTOSButton), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(didTapPPButton), for: .touchUpInside)
        monthButton.addTarget(self, action: #selector(didTapMonthSubscription(sender:)), for: .touchUpInside)
        annualButton.addTarget(self, action: #selector(didTapAnnualSubscription(sender:)), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            IAPManager.shared.checkTrial(completion: { [weak self] isEligible in
                if isEligible {
                    self?.trialLabel.isHidden = false
                } else {
                    self?.trialLabel.isHidden = true
                }
            })

            IAPManager.shared.getOfferings { [weak self] products in
                guard let products = products else {
                    self?.showAlert(with: "Error", message: "Could not load offerings")
                    return
                }
                self?.annualButton.configuration?.subtitle = "Save 50%"
                self?.monthButton.setTitle("\(products[0].prettyPrice) / \(products[0].prettyDuration)", for: .normal)
                self?.annualButton.setTitle("\(products[1].prettyPrice) / \(products[1].prettyDuration)", for: .normal)
            }
        }

    }

    @objc private func didTapAnnualSubscription(sender: UIButton) {
        didTapBuyButton(sender: sender, productID: IAPManager.shared.products[1].qonversionID)
    }

    @objc private func didTapMonthSubscription(sender: UIButton) {
        didTapBuyButton(sender: sender, productID: IAPManager.shared.products[0].qonversionID)
    }

    private func didTapBuyButton(sender: UIButton, productID: String?) {
        view.isUserInteractionEnabled = false
        guard let productID = productID else { return }
        sender.configuration?.showsActivityIndicator = true
        sender.isEnabled = false
        IAPManager.shared.purchase(productID: productID) { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.vewController(isDismissed: true)
                })
            } else {
                sender.isEnabled = true
                self?.view.isUserInteractionEnabled = true
                sender.configuration?.showsActivityIndicator = false
            }

            Analytics.logEvent("subscription", parameters: [
                "prod_id": productID as NSObject,
                "success": success as NSObject
            ])
        }
    }

    @objc private func didTapRestore(sender: UIBarButtonItem) {
        view.isUserInteractionEnabled = false
        showActivityIndicator()
        activityIndicator.startAnimating()
        IAPManager.shared.restorePurchases { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showAlert(with: "Error", message: error.localizedDescription)
            case .success(let success):
                if success {
                    self?.showAlert(with: "Success", message: "Subscription is restored", toDismiss: true)
                } else {
                    self?.showAlert(with: "Error", message: "No purchased items")
                    self?.activityIndicator.stopAnimating()
                    self?.showRestoreButton()
                    self?.view.isUserInteractionEnabled = true
                }
            }
        }
    }

    private func showActivityIndicator() {
        let activity = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = activity
    }

    private func showRestoreButton() {
        let restoreButton = UIBarButtonItem(
            title: "Restore",
            style: .done,
            target: self,
            action: #selector(didTapRestore)
        )
        navigationItem.rightBarButtonItem = restoreButton

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unlockLabel.frame = CGRect(x: 0, y: 140, width: view.frame.width, height: 144)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        trialLabel.translatesAutoresizingMaskIntoConstraints = false
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        annualButton.translatesAutoresizingMaskIntoConstraints = false
        tosAndPpStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 340),

            trialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trialLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),

            annualButton.heightAnchor.constraint(equalToConstant: 50),
            annualButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 140),
            annualButton.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16),
            annualButton.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16),

            monthButton.heightAnchor.constraint(equalToConstant: 50),
            monthButton.bottomAnchor.constraint(equalTo: annualButton.topAnchor, constant: -30),
            monthButton.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16),
            monthButton.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16),

            tosAndPpStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tosAndPpStackView.topAnchor.constraint(equalTo: annualButton.bottomAnchor, constant: 30)
        ])
    }

    @objc private func didTapTOSButton() {
        openURL(link: "https://www.hackingwithswift.com")
    }

    @objc private func didTapPPButton() {
        openURL(link: "https://www.hackingwithswift.com")
    }

    private func openURL(link: String) {
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.vewController(isDismissed: true)
        }
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

    private func showAlert(with title: String, message: String, toDismiss: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            if toDismiss {
                self?.dismiss(animated: true) {
                    self?.delegate?.vewController(isDismissed: true)
                }
            }
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
      }

    static func paywallVC() -> UINavigationController {
        let paywallVC = PaywallViewController()
        let navVC = UINavigationController(rootViewController: paywallVC)
        navVC.modalPresentationStyle = .fullScreen
        return navVC
    }
}
