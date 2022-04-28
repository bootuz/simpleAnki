//
//  ReminderViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 24.04.2022.
//

import UIKit

class ReminderViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(DatePickerViewCell.self, forCellReuseIdentifier: DatePickerViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.isScrollEnabled = false
        table.layoutMargins = UIEdgeInsets.zero
        table.separatorInset = UIEdgeInsets.zero
        return table
    }()
    
    var models = [Section]()
    let remonderOn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.reminder)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminder"
        view.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        configureCloseButton()
        configure()
    }
    
    private func configure() {
        models.append(Section(title: "", options: [
            .switchCell(model: SwitchOption(title: K.Settings.reminderOn, icon: UIImage(systemName: "bell"), isOn: remonderOn, switchType: .reminder, handler: nil)),
            .datePickerCell,
            .staticCell(model: Option(title: "Repeat", icon: UIImage(systemName: "repeat"), handler: {
                
            }))
        ]))
    }
    
    @objc
    private func handleDateSelection() {
        
    }
    
    private func configureCloseButton() {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension ReminderViewController: UITableViewDelegate {
    
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


extension ReminderViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = models[section]
        return model.title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.section].options[indexPath.row]
        switch model.self {
            case .datePickerCell:
                return 200
            default:
                break
        }
        return UITableViewCell().frame.height
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
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell
            
            case .datePickerCell:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: DatePickerViewCell.identifier,
                    for: indexPath
                ) as? DatePickerViewCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
        }
    }
}

