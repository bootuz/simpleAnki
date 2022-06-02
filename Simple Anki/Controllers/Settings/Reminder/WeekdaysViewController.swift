//
//  WeekdaysViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 02.05.2022.
//

import UIKit

class WeekdaysViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isScrollEnabled = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose days"
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.frame.origin.y = tableView.frame.origin.y - 20
        tableView.delegate = self
        tableView.dataSource = self
    }
}


extension WeekdaysViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderManager.shared.weekdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = ReminderManager.shared.weekdays[indexPath.row].name
        cell.contentConfiguration = content
        if ReminderManager.shared.isDayInReminder(index: indexPath.row) {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if !ReminderManager.shared.isDayInReminder(index: indexPath.row) {
            ReminderManager.shared.addWeekdayToReminder(index: indexPath.row)
            cell.accessoryType = .checkmark
        } else {
            ReminderManager.shared.deleteDayFromReminder(index: indexPath.row)
            cell.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
