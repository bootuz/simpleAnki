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
//        table.separatorStyle = .none
        return table
    }()
    
    var models = [Section]()
    let remonderOn = UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.reminder)
    let reminderTime = UserDefaults.standard.string(forKey: K.UserDefaultsKeys.reminderTime) ?? "00:00"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reminder"
        view.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        configure()
    }
    
    private func configure() {
        models.append(Section(title: "", options: [
            .switchCell(model: SwitchOption(
                title: K.Settings.reminderOn,
                icon: UIImage(systemName: "bell"),
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
                
            }))
        ]))
    }
    
    
    @objc private func doneButtonTapped() {
        if remonderOn  {
            
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
            UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.reminder)
        } else {
            UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.reminder)
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
 
//class ViewController: UIViewController,UNUserNotificationCenterDelegate {
//    var isGrantedNotificationAccess = false
//    var pressed = 0
//
//    @IBAction func setNotification(_ sender: UIButton) {
//        if isGrantedNotificationAccess{
//            //set content
//            let content = UNMutableNotificationContent()
//            content.title = "My Notification Management Demo"
//            content.subtitle = "Timed Notification"
//            content.body = "Notification pressed"
//            pressed += 1
//            content.body = "Notification pressed \(pressed) times"
//            content.categoryIdentifier = "message"
//
//            //set trigger
//            /*let trigger = UNTimeIntervalNotificationTrigger(
//                timeInterval: 10.0,
//                repeats: false)*/
//            let trigger = UNTimeIntervalNotificationTrigger(
//                timeInterval: 60.0,
//                repeats: true)
//
//            //Create the request
//            let request = UNNotificationRequest(
//                identifier: "my.notification",
//                content: content,
//                trigger: trigger
//            )
//            //Schedule the request
//            UNUserNotificationCenter.current().add(
//                request, withCompletionHandler: nil)
//        }
//    }
//
//    @IBAction func listNotification(_ sender: UIButton) {
//        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
//            print("\(requests.count) requests -------")
//            for request in requests{
//                print(request.identifier)
//            }
//        })
//        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifications -> () in
//            print("\(deliveredNotifications.count) Delivered notifications-------")
//            for notification in deliveredNotifications{
//                print(notification.request.identifier)
//            }
//        })
//
//    }
//
//    @IBAction func removeNotification(_ sender: UIButton) {
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["my.notification"])
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: [.alert,.sound,.badge],
//            completionHandler: { (granted,error) in
//                self.isGrantedNotificationAccess = granted
//                if !granted{
//                    //add alert to complain
//                }
//        })
//        UNUserNotificationCenter.current().delegate = self
//    }
//    //MARK: Delegates
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert,.sound])
//
//        /* Not a very good way to do this, just here to give you ideas.
//         let alert = UIAlertController(
//         title: notification.request.content.title,
//         message: notification.request.content.body,
//         preferredStyle: .alert)
//         let okAction = UIAlertAction(
//         title: "OK",
//         style: .default,
//         handler: nil)
//         alert.addAction(okAction)
//         present(alert, animated: true, completion: nil)
//         */
//    }
//}
