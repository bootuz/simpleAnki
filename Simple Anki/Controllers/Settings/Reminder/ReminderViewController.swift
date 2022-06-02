//
//  ReminderViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 24.04.2022.
//

import UIKit

class ReminderViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(DatePickerViewCell.self, forCellReuseIdentifier: DatePickerViewCell.identifier)
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.isScrollEnabled = false
        return table
    }()

    var models = [Section]()
    let remonderOn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.reminder)
    let reminderTime = UserDefaults.standard.string(forKey: K.UserDefaultsKeys.reminderTime) ?? "00:00"
    let reminderIcon = ReminderManager.shared.isReminderOn() ? UIImage(systemName: "bell") : UIImage(systemName: "bell.slash")

    var selectedDays = [Weekday]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminder"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.frame.origin.y = tableView.frame.origin.y - 20
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDays.removeAll()
        selectedDays = ReminderManager.shared.collectSelectedWeekdays()
    }

    private func configure() {
        models.append(Section(title: "", options: [
            .switchCell(model: SwitchOption(
                title: K.Settings.reminderOn,
                icon: reminderIcon,
                isOn: remonderOn,
                handler: nil
            )),
            .datePickerCell(model: DatePickerOption(
                date: reminderTime
            )),
            .staticCell(model: Option(
                title: "Repeat",
                icon: UIImage(systemName: "repeat"),
                handler: {
                    self.showWeekdaysViewController()
            }))
        ]))
    }

    private func showWeekdaysViewController() {
        let weekdaysVC = WeekdaysViewController()
        navigationController?.pushViewController(weekdaysVC, animated: true)
    }


    @objc private func doneButtonTapped() {
        let notifications = ReminderManager.shared.getNotificationsCredentials(weekdays: selectedDays)
        if ReminderManager.shared.isReminderOn() {
            ReminderManager.shared.scheduleNotifications(notifications: notifications)
        } else {
            ReminderManager.shared.removeAllNotifications()
        }
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
                cell.delegate = self
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell

            case .datePickerCell(let model):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: DatePickerViewCell.identifier,
                    for: indexPath
                ) as? DatePickerViewCell else { return UITableViewCell() }
                cell.delegate = self
                cell.selectionStyle = .none
                cell.configure(with: model)
                return cell
        }
    }
}

extension ReminderViewController: SwitchViewCellDelegate {
    func switchAction(with cell: UITableViewCell) {
        guard let switchCell = cell as? SwitchTableViewCell else { return }
        if switchCell.mySwitch.isOn {
            ReminderManager.shared.setReminderOn()
            switchCell.iconImageView.image = UIImage(systemName: "bell")
        } else {
            ReminderManager.shared.setReminderOff()
            switchCell.iconImageView.image = UIImage(systemName: "bell.slash")
        }
    }
}

extension ReminderViewController: DatePickerViewCellDelegate {
    func datePicker(with cell: UITableViewCell) {
        guard let datePickerCell = cell as? DatePickerViewCell else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: datePickerCell.datePicker.date)
        UserDefaults.standard.set(timeString, forKey: K.UserDefaultsKeys.reminderTime)
    }
}
