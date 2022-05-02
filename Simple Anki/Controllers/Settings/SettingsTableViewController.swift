//
//  SettingsViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 22.06.2021.
//

import UIKit
import StoreKit


class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        return table
    }()
    
    let notificationCenter = UNUserNotificationCenter.current()
    var models = [Section]()
    
    let darkMode = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.darkMode)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        configure()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    func configure() {
        models.append(Section(title: K.Settings.appearence, options: [
            .switchCell(model: SwitchOption(title: K.Settings.darkMode, icon: UIImage(systemName: K.Icon.lefthalf), isOn: darkMode, handler: nil))
        ]))
        
        models.append(Section(title: K.Settings.support, options: [
            .staticCell(model: Option(title: K.Settings.rateThisApp, icon: UIImage(systemName: K.Icon.star)) {
                RateManager.rateApp()
            }),
            .staticCell(model: Option(title: K.Settings.reportBug, icon: UIImage(systemName: K.Icon.ladybug)) {
                EmailManager.prepareEmailForBugReport()
            }),
            .staticCell(model: Option(title: K.Settings.suggestFeature, icon: UIImage(systemName: K.Icon.chevron)) {
                EmailManager.prepareEmailForFeatureSuggestion()
            }),
            .staticCell(model: Option(title: K.Settings.shareThisApp, icon: UIImage(systemName: K.Icon.share)) {
                self.showActivityViewController()
            }),

        ]))
        
        models.append(Section(title: K.Settings.notifications, options: [
            .staticCell(model: Option(title: "Reminder", icon: UIImage(systemName: K.Icon.bell), handler: {
                self.notificationCenter.requestAuthorization(options: [.alert, .sound]) { permissionGranted, error in
                    if permissionGranted {
                        self.presentReminderViewController()
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }))
        ]))
    }
    
    private func presentReminderViewController() {
        DispatchQueue.main.async {
            let reminderVC = ReminderViewController()
            let nav = UINavigationController(rootViewController: reminderVC)
            nav.isModalInPresentation = true
            if #available(iOS 15, *) {
                if let sheetController = nav.sheetPresentationController {
                    sheetController.detents = [.medium()]
                    sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
                }
            } else {
                // Fallback on earlier versions
            }
            self.present(nav, animated: true)
        }
    }
    
    private func showActivityViewController() {
        let items: [Any] = ["Check this out!", URL(string: K.appURL)!]
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        
        switch type.self {
            case .staticCell(let model):
                model.handler?()
            default:
                break
        }
    }
}


extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = models[section]
        return model.title
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
            case .staticCell(let model):
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SettingsTableViewCell.identifier,
                        for: indexPath
                ) as? SettingsTableViewCell else { return UITableViewCell() }
                cell.configure(with: model)
                return cell
            
            case .switchCell(let model):
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SwitchTableViewCell.identifier,
                        for: indexPath
                ) as? SwitchTableViewCell else { return UITableViewCell() }
                cell.delegate = self
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell
            
            default:
                return UITableViewCell()
        }
    }
}

extension SettingsViewController: SwitchViewCellDelegate {
    func switchAction(with cell: UITableViewCell) {
        guard let switchCell = cell as? SwitchTableViewCell else { return }
        if switchCell.mySwitch.isOn {
            UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.darkMode)
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        } else {
            UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.darkMode)
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
    }
}

