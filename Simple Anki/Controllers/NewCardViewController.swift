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
    let indicatorView = SPIndicatorView(title: "Card added", preset: .done)
    var recordFilePath: URL?

    var reloadData: (() -> Void)?
    var isRecording: Bool = false

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()

    private lazy var frontField: UITextField = {
        let field = UITextField()
        field.placeholder = "Front word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .next
        return field
    }()

    private lazy var backField: UITextField = {
        let field = UITextField()
        field.placeholder = "Back word"
        field.font = .systemFont(ofSize: 26, weight: .bold)
        field.returnKeyType = .done
        return field
    }()

    private lazy var frontLabel: UILabel = {
        let label = UILabel()
        label.text = "Front"
        label.textColor = .systemGray
        return label
    }()

    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.text = "Back"
        label.textColor = .systemGray
        return label
    }()

    private lazy var separationLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()

    private lazy var addAndNext: UIButton = {
        let button = UIButton()
        button.configureDefaultButton(title: "Add")
        return button
    }()

    private lazy var recordButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "mic")
        button.configureIconButton(configuration: .tinted(), image: image)
        return button
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "speaker.wave.3")
        button.configureIconButton(configuration: .tinted(), image: image)
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Update",
                style: .done,
                target: self,
                action: #selector(didSaveTapped)
            )
            recordButton.isEnabled = true
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

        if frontField.text!.isEmpty {
            addAndNext.isEnabled = false
            recordButton.isEnabled = false
        } else {
            addAndNext.isEnabled = true
            recordButton.isEnabled = true
        }
        playButton.isHidden = true

        view.addSubview(addAndNext)
        view.addSubview(recordButton)
        view.addSubview(playButton)

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.safeTrailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: -16).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        addAndNext.translatesAutoresizingMaskIntoConstraints = false
        addAndNext.safeLeadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: 16).isActive = true
        addAndNext.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -16).isActive = true
        addAndNext.heightAnchor.constraint(equalToConstant: 50).isActive = true

        recordButton.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
        playButton.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
        addAndNext.safeBottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).isActive = true
        configureCardView()
        setupEditScreen()
    }

    private func configureCardView() {
        view.addSubview(cardView)
        cardView.addSubview(separationLine)
        cardView.addSubview(frontLabel)
        cardView.addSubview(backLabel)
        cardView.addSubview(frontField)
        cardView.addSubview(backField)

        let leftPadding = 16.0
        let rightPadding = leftPadding * 2.0
        let labelHeight = 15.0
        let labelWidth = 100.0

        cardView.frame = CGRect(
            x: leftPadding,
            y: 100.0,
            width: view.bounds.width - rightPadding,
            height: 200.0
        )
        separationLine.frame = CGRect(
            x: leftPadding,
            y: 200 / 2.0,
            width: cardView.frame.width - rightPadding,
            height: 1.0
        )
        frontLabel.frame = CGRect(
            x: leftPadding,
            y: 15.0,
            width: labelWidth,
            height: labelHeight
        )
        backLabel.frame = CGRect(
            x: leftPadding,
            y: separationLine.frame.origin.y + 15.0,
            width: labelWidth,
            height: labelHeight
        )
        frontField.frame = CGRect(
            x: leftPadding,
            y: 50.0,
            width: cardView.frame.width - rightPadding,
            height: 40.0
        )
        backField.frame = CGRect(
            x: leftPadding,
            y: separationLine.frame.origin.y + 50.0,
            width: cardView.frame.width - rightPadding,
            height: 40.0
        )
    }

    private func setupMenuForPlayButton() {
        let delete = UIAction(title: "Delete",
          image: UIImage(systemName: "trash")) { _ in
            if let audioFilePath = self.recordFilePath {
                Utils.deleteAudioFile(at: audioFilePath)
            }
            self.playButton.isHidden = true
            self.recordButton.isHidden = false
            self.recordButton.configuration?.baseForegroundColor = .systemBlue
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

    private func loadRecordingUI() {
        UIView.animate(withDuration: 0.2) {
            self.addAndNext.setTitle("Recording...", for: .normal)
            self.recordButton.configuration?.image = UIImage(systemName: "square.fill")
            self.recordButton.configuration?.baseForegroundColor = .systemRed
            self.recordButton.configuration?.cornerStyle = .capsule
        }
        addAndNext.isEnabled = false
    }

    private func loadPlaybackUI() {
        guard let isEmpty = frontField.text?.isEmpty else { return }
        if !isEmpty {
            addAndNext.isEnabled = true
        }
        recordButton.configuration?.image = UIImage(systemName: "mic")
        self.recordButton.configuration?.cornerStyle = .large
        recordButton.isHidden = true
        playButton.isHidden = false
        addAndNext.setTitle("Add", for: .normal)
    }

    // MARK: - Button handlers

    @objc func recordButtonTapped() {
        IAPManager.shared.checkPermissions { [weak self] isActive in
            if isActive {
                switch self?.recordingSession.recordPermission {
                case .granted:
                    HapticManager.shared.vibrate(for: .success)
                    if !self!.isRecording {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                            self?.isRecording = true
                            self?.loadRecordingUI()
                            self?.startRecording()
                        }
                    } else {
                        self?.finishRecording()
                        self?.loadPlaybackUI()
                        self?.isRecording = false
                    }
                case .denied:
                    HapticManager.shared.vibrate(for: .error)
                    self?.showSettingsAlert()
                case .undetermined:
                    self?.recordingSession.requestRecordPermission { _ in }
                default:
                    break
                }
            } else {
                self?.present(PaywallViewController.paywallVC(), animated: true)
            }
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
        reloadData?()
        dismiss(animated: true)
        indicatorView.present(duration: 0.5, haptic: .success)
    }

    @objc private func didSaveAndNextTapped() {
        updateUIafterAddCard()
    }

    private func updateUIafterAddCard() {
        saveCard()
        frontField.text?.removeAll()
        backField.text?.removeAll()
        frontField.becomeFirstResponder()
        indicatorView.present(duration: 0.5, haptic: .success)
        addAndNext.isEnabled = false
        recordButton.isEnabled = false
        recordButton.isHidden = false
        recordButton.configuration?.baseForegroundColor = .systemBlue
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

// MARK: - TextFieldDelegate Extension

extension NewCardViewController: UITextFieldDelegate {

    @objc func textFieldChanged() {
        if frontField.text?.isEmpty == false {
            addAndNext.isEnabled = true
            recordButton.isEnabled = true
        } else {
            addAndNext.isEnabled = false
            recordButton.isEnabled = false
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
            try recordingSession.setCategory(.record, mode: .spokenAudio)
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
