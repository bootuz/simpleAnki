//
//  NewCardViewControllerBeta.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 03.04.2022.
//

import UIKit
import RealmSwift
import AVFoundation
import SPIndicator

class NewCardViewController: UIViewController {
    
    var selectedCard: Card?
    var selectedDeck: Deck?
    
    var audioRecorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var recordingSession = AVAudioSession.sharedInstance()
    let indicatorView = SPIndicatorView(title: "Card saved", preset: .done)
    var recordFilePath: URL?
    
    var reloadData: (() -> Void)?
    var isRecording: Bool = false

    var isAudioRecordingGranted: Bool = false
    var recordingIsFinished: Bool = false
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let frontField: UITextField = {
        let field = UITextField()
        field.placeholder = "Front word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .next
        return field
    }()
    
    private let backField: UITextField = {
        let field = UITextField()
        field.placeholder = "Back word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .done
        return field
    }()
    
    private let frontLabel: UILabel = {
        let label = UILabel()
        label.text = "Front"
        label.textColor = .systemGray
        return label
    }()
    
    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = "Back"
        label.textColor = .systemGray
        return label
    }()
    
    private let separationLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let addAndNext: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add and Next", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.systemFont(ofSize: 25)
        let config = UIImage.SymbolConfiguration(font: font)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "mic", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont.systemFont(ofSize: 25)
        let config = UIImage.SymbolConfiguration(font: font)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "speaker.wave.3", withConfiguration: config), for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New card"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didDoneTapped))
        navigationItem.setHidesBackButton(true, animated: false)
        
        frontField.delegate = self
        backField.delegate = self
        
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        addAndNext.addTarget(self, action: #selector(didSaveAndNextTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        frontField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupMenuForPlayButton()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    private func setupEditScreen() {
        if let card = selectedCard {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(didSaveTapped))
            recordButton.isEnabled = true
            recordButton.backgroundColor = .systemBlue
            title = selectedCard?.front
            
            frontField.text = card.front
            backField.text = card.back
            if let name = card.audioName {
                recordFilePath = Utils.getAudioFilePath(with: name)
                playButton.isHidden = false
                recordButton.isHidden = true
            } else {
                playButton.isHidden = true
                recordButton.isHidden = false
            }
            addAndNext.isHidden = true
        } else {
            frontField.becomeFirstResponder()
        }
    }
    
    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .secondarySystemBackground
        
        addAndNext.isEnabled = false
        addAndNext.backgroundColor = .systemGray2
        recordButton.isEnabled = false
        recordButton.backgroundColor = .systemGray2
        playButton.isHidden = true

        view.addSubview(cardView)
        view.addSubview(addAndNext)
        view.addSubview(recordButton)
        view.addSubview(playButton)
        cardView.addSubview(separationLine)
        cardView.addSubview(frontLabel)
        cardView.addSubview(backLabel)
        cardView.addSubview(frontField)
        cardView.addSubview(backField)
        cardView.addSubview(bottomLine)
        
        let leftPadding = 16.0
        let rightPadding = leftPadding * 2.0
        let labelHeight = 15.0
        let labelWidth = 100.0
        
        cardView.frame = CGRect(x: leftPadding,
                             y: 100.0,
                             width: view.bounds.width - rightPadding,
                             height: 200.0)
        separationLine.frame = CGRect(x: leftPadding,
                                      y: 200 / 2.0,
                                      width: cardView.frame.width - rightPadding,
                                      height: 1.0)
        frontLabel.frame = CGRect(x: leftPadding,
                                  y: 15.0,
                                  width: labelWidth,
                                  height: labelHeight)
        backLabel.frame = CGRect(x: leftPadding,
                                 y: separationLine.frame.origin.y + 15.0,
                                 width: labelWidth,
                                 height: labelHeight)
        frontField.frame = CGRect(x: leftPadding,
                                  y: 50.0,
                                  width: cardView.frame.width - rightPadding,
                                  height: 40.0)
        backField.frame = CGRect(x: leftPadding,
                                 y: separationLine.frame.origin.y + 50.0,
                                 width: cardView.frame.width - rightPadding,
                                 height: 40.0)
        
        recordButton.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        playButton.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addAndNext.safeLeadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16).isActive = true
        addAndNext.widthAnchor.constraint(equalToConstant: 285).isActive = true
        addAndNext.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if #available(iOS 15.0, *) {
            recordButton.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
            playButton.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
            addAndNext.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
        } else {
            addAndNext.safeTopAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20).isActive = true
            recordButton.safeTopAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20).isActive = true
            playButton.safeTopAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20).isActive = true
        }
        setupEditScreen()
        navigationController?.navigationBar.cleanNavigationBarForiOS14()
    }
    
    private func setupMenuForPlayButton() {
        let delete = UIAction(title: "Delete",
          image: UIImage(systemName: "trash")) { _ in
            if let audioFilePath = self.recordFilePath {
                Utils.deleteAudioFile(at: audioFilePath)
            }
            self.playButton.isHidden = true
            self.recordButton.isHidden = false
            self.recordButton.backgroundColor = .systemBlue
        }
        playButton.menu = UIMenu(title: "", options: .destructive, children: [delete])
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(
            title: "Microphone access required",
            message: "Allow Simple Anki to use a microphone in the app settings, to be able to record the word pronounciation",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(appSettingsUrl) {
                UIApplication.shared.open(appSettingsUrl) { (success) in
                    print("Settings opened: \(success)")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func loadRecordingUI(with config: UIImage.Configuration) {
        UIView.animate(withDuration: 0.2) {
            self.addAndNext.backgroundColor = .systemGray2
            self.addAndNext.setTitle("Recording...", for: .normal)
            self.recordButton.layer.cornerRadius = 25
            self.recordButton.setImage(UIImage(systemName: "square.fill", withConfiguration: config), for: .normal)
            self.recordButton.backgroundColor = .systemRed

        }
        addAndNext.isEnabled = false
    }
    
    private func loadPlaybackUI(with config: UIImage.Configuration) {
        guard let isEmpty = frontField.text?.isEmpty else { return }
        if !isEmpty {
            addAndNext.backgroundColor = .systemBlue
            addAndNext.isEnabled = true
        }
        recordButton.layer.cornerRadius = 10
        recordButton.setImage(UIImage(systemName: "mic", withConfiguration: config), for: .normal)
        recordButton.isHidden = true
        UIView.animate(withDuration: 0.2) { [unowned self] in
            playButton.isHidden = false
            playButton.layer.cornerRadius = 10
        }
        addAndNext.setTitle("Save and Next", for: .normal)
        recordButton.tintColor = .white
    }
    
    //MARK: - Button handlers
    
    @objc func recordButtonTapped() {
        switch recordingSession.recordPermission {
            case .granted:
                HapticManager.shared.vibrate(for: .warning)
                let font = UIFont.systemFont(ofSize: 25)
                let config = UIImage.SymbolConfiguration(font: font)
                if !isRecording {
                    isRecording = true
                    loadRecordingUI(with: config)
                    startRecording()
                } else {
                    finishRecording()
                    loadPlaybackUI(with: config)
                    isRecording = false
                }
            case .denied:
                showSettingsAlert()
            case .undetermined:
                recordingSession.requestRecordPermission { _ in }
            default:
                break
        }
    }
    
    @objc func playButtonTapped() {
        guard let url = recordFilePath else { return }
        play(with: url)
        playButton.isEnabled = false
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didDoneTapped() {
        if let audioFilePath = recordFilePath {
            Utils.deleteAudioFile(at: audioFilePath)
        }
        dismiss(animated: true)
    }
    
    @objc private func didSaveTapped() {
        saveCard()
        recordFilePath = nil
        self.reloadData?()
        dismiss(animated: true)
        indicatorView.present(duration: 0.5, haptic: .success)
    }
    
    @objc private func didSaveAndNextTapped() {
        saveCard()
        frontField.text?.removeAll()
        backField.text?.removeAll()
        frontField.becomeFirstResponder()
        indicatorView.present(duration: 0.5, haptic: .success)
        addAndNext.isEnabled = false
        addAndNext.backgroundColor = .systemGray2
        recordButton.isEnabled = false
        recordButton.backgroundColor = .systemGray2
        recordButton.isHidden = false
        playButton.isHidden = true
        recordFilePath = nil
    }
    
    func saveCard() {
        let newCard = Card()
        if let fronText = frontField.text {
            newCard.front = fronText.trimmingCharacters(in: .whitespaces)
        }
        if let backText = backField.text {
            newCard.back = backText.trimmingCharacters(in: .whitespaces)
        }
        if let path = recordFilePath {
            if path.exists() {
                newCard.audioName = recordFilePath?.lastPathComponent
            }
        }
        if let card = selectedCard {
            StorageManager.update(card, with: newCard)
        } else {
            StorageManager.save(newCard, to: selectedDeck)
        }
    }
}

//MARK: - TextFieldDelegate Extension

extension NewCardViewController: UITextFieldDelegate {
    
    @objc func textFieldChanged() {
        if frontField.text?.isEmpty == false {
            addAndNext.isEnabled = true
            addAndNext.backgroundColor = .systemBlue
            recordButton.isEnabled = true
            recordButton.backgroundColor = .systemBlue
        } else {
            addAndNext.isEnabled = false
            addAndNext.backgroundColor = .systemGray2
            recordButton.isEnabled = false
            recordButton.backgroundColor = .systemGray2
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
            case .next:
                backField.becomeFirstResponder()
            case .done:
                backField.resignFirstResponder()
            default:
                break
        }
        return true
    }
}

extension NewCardViewController: AVAudioPlayerDelegate {
    func play(with url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.delegate = self
            player.play()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isEnabled = true
    }
}

extension NewCardViewController: AVAudioRecorderDelegate {

    func startRecording() {
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            let url = Utils.generateNewRecordName()
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print(error.localizedDescription)
        }
    }

    func finishRecording() {
        audioRecorder.stop()
        recordFilePath = audioRecorder.url
        do {
            try recordingSession.setCategory(.playback, mode: .default)
            try recordingSession.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording()
    }

    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        finishRecording()
    }
}
