//
//  ReviewViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 05.03.2021.
//

import UIKit
import StoreKit
import RealmSwift
import AVFoundation

class ReviewViewController: UIViewController {
    
    var deckLenght: Int?
    var progress: Progress?
    var reviewManager: ReviewManager?
    var audioPlayer : AVAudioPlayer!
    var audioFilePath: URL?
    
    let topWordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(36))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    let bottomWordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(36))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()
    
    let speakerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        let image = UIImage(systemName: "speaker.wave.2.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(64), weight: .thin))
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    let progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = .systemGray5
        return bar
    }()

    let finishLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(36))
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "Finished!\nWant to repeat?"
        return label
    }()
    
    let repeatButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        let image = UIImage(systemName: "repeat",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: CGFloat(64), weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speakerButton.addTarget(self, action: #selector(speakerButtonPressed), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(repeatButtonPressed), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .lightGray
        finishLabel.isHidden = true
        repeatButton.isHidden = true
        guard let numberOfCards = reviewManager?.numberOfCards else { return }
        progress = Progress(totalUnitCount: numberOfCards)
        topWordLabel.text = reviewManager?.currentCard?.front
        bottomWordLabel.text = nil
        setupSpeakerButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.frame.size.width - 32
        let height = view.frame.size.height / 3 - 50
        topWordLabel.frame = CGRect(x: 16,
                                    y: 150,
                                    width: width,
                                    height: height)
        bottomWordLabel.frame = CGRect(x: 16,
                                       y: view.frame.size.height / 2 - 40,
                                       width: width,
                                       height: height)
        speakerButton.frame = CGRect(x: (view.frame.size.width - 70) / 2,
                                     y: height * 2 + 180,
                                     width: 70,
                                     height: 70)
        progressBar.frame = CGRect(x: 16,
                                   y: view.frame.size.height - 32,
                                   width: view.frame.size.width - 32,
                                   height: 0)
        finishLabel.frame = CGRect(x: 0,
                                   y: view.frame.size.height / 2 - 100,
                                   width: view.frame.size.width,
                                   height: 100)
        repeatButton.frame = CGRect(x: view.frame.size.width / 2 - 25,
                                    y: view.frame.size.height / 2 + 50,
                                    width: 50,
                                    height: 40)
        view.addSubview(topWordLabel)
        view.addSubview(bottomWordLabel)
        view.addSubview(speakerButton)
        view.addSubview(progressBar)
        view.addSubview(finishLabel)
        view.addSubview(repeatButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        navigationController?.navigationBar.cleanNavigationBarForiOS14()
    }
    
    
    private func setupSpeakerButton() {
        if let _ = getAudioFilePathForCurrentCard() {
            speakerButton.isHidden = false
        } else {
            speakerButton.isHidden = true
        }
    }
    
    @objc func screenTapped() {
        if bottomWordLabel.text == nil {
            bottomWordLabel.text = reviewManager?.currentCard?.back
            updateProgressBar()
        } else {
            reviewManager?.pickCard()
            if let card = reviewManager?.currentCard {
                setupSpeakerButton()
                topWordLabel.text = card.front
                bottomWordLabel.text = nil
            } else {
                finishLabel.isHidden = false
                repeatButton.isHidden = false
//                doneButton.isHidden = false
//
                topWordLabel.isHidden = true
                bottomWordLabel.isHidden = true
                speakerButton.isHidden = true
                RateManager.showRatesAlert(withoutCounter: false)
            }
        }
    }
    
    
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    
    @objc func repeatButtonPressed(_ sender: Any) {
        finishLabel.isHidden = true
        repeatButton.isHidden = true
        topWordLabel.isHidden = false
        bottomWordLabel.isHidden = false

        progressBar.setProgress(0.0, animated: false)
        progress?.completedUnitCount = 0
        progressBar.tintColor = UIColor(named: "systemBlue")

        reviewManager?.repeatReview()
        reviewManager?.pickCard()
        if let card = reviewManager?.currentCard {
            setupSpeakerButton()
            topWordLabel.text = card.front
            bottomWordLabel.text = nil
        }
    }
    
    
    @objc private func speakerButtonPressed() {
        if let audioName = reviewManager?.currentCard?.audioName {
            let audioFilePath = Utils.getAudioFilePath(with: audioName)
            if audioFilePath.exists() {
                play(recordFilePath: audioFilePath)
            }
        }
    }
    
    
    private func getAudioFilePathForCurrentCard() -> URL? {
        if let audioName = reviewManager?.currentCard?.audioName {
            let audioFilePath = Utils.getAudioFilePath(with: audioName)
            if audioFilePath.exists() {
                return audioFilePath
            }
        }
        return nil
    }

    
    private func updateProgressBar() {
        progress?.completedUnitCount += 1
        guard let fractionCompleted = progress?.fractionCompleted else { return }
        let progressFloat = Float(fractionCompleted)
        progressBar.setProgress(progressFloat, animated: true)
        
        if progress?.completedUnitCount == progress?.totalUnitCount {
            progressBar.tintColor = #colorLiteral(red: 0.2039215686, green: 0.7803921569, blue: 0.3490196078, alpha: 1)
        }
    }
}


extension ReviewViewController: AVAudioPlayerDelegate {
    func play(recordFilePath: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordFilePath)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            print("error: \(error)")
        }
    }
}

