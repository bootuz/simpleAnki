import UIKit

extension UITableView {

    func setEmptyState(_ message: String, imageName: String) {
        let imageView = UIImageView(image: UIImage(systemName: imageName))
        imageView.center = CGPoint(x: self.bounds.size.width / 2,
                                   y: self.bounds.size.height / 2)
        imageView.bounds.size = CGSize(width: imageView.bounds.size.width * 4,
                                       height: imageView.bounds.size.height * 4)
        imageView.tintColor = .systemGray3


        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        messageLabel.center = CGPoint(x: self.bounds.size.width / 2,
                                      y: self.bounds.size.height / 2 + 55)
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "System", size: 50)
        messageLabel.textColor = .systemGray

        let button = UIButton()
        button.layer.cornerRadius = 10
        button.setTitle("Create your first deck", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView()
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(button)

        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.safeTopAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -100).isActive = true

        self.backgroundView = view
        self.isScrollEnabled = false
    }

    func restore() {
        self.backgroundView = nil
        self.isScrollEnabled = true
    }
}

