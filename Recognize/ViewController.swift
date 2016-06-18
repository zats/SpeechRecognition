//
//  ViewController.swift
//  Recognize
//
//  Created by Sash Zats on 6/15/16.
//  Copyright © 2016 Sash Zats. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(localeIdentifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var player = AVQueuePlayer()
    private let playerLayer = AVPlayerLayer()

    private var tap: MYAudioTapProcessor!

    @IBOutlet weak var captionsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // There is open radar rdar://26870006 if you forget to request authorization, any use of speech recognition API silently fails
        SFSpeechRecognizer.requestAuthorization { status in
            assert(status == .authorized)
            DispatchQueue.main.async {
                self.setupVideo()
                self.setupRecognition()
            }
        }
    }

    private func setupVideo() {
        // Asset
        let URL = Bundle.main().urlForResource("video", withExtension: "mp4")!
        let asset = AVURLAsset(url: URL)
        let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!

        // Tap
        // Slightly modified audio tap sample https://developer.apple.com/library/ios/samplecode/AudioTapProcessor/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012324-Intro-DontLinkElementID_2
        // Takes AVAssetTrack and produces AVAudioPCMBuffer
        // great thanks to AVFoundation, CoreFoundation and SpeechKit engineers for helping to figure this out!
        // especially to Eric Lee for explaining how to convert AudioBufferList -> AVAudioPCMBuffer
        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
        tap.delegate = self

        // Video playback
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: nil)
        player.play()
        player.currentItem?.audioMix = tap.audioMix

        // Player view
        let playerView: UIView! = view
        playerLayer.player = player
        playerLayer.frame = playerView.bounds
        playerView.layer.insertSublayer(playerLayer, at: 0)
    }

    private func setupRecognition() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        // we want to get continuous recognition and not everything at once at the end of the video
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            self.captionsLabel.text = result?.bestTranscription.formattedString

            // once in about every minute recognition task finishes so we need to set up a new one to continue recognition
            if result?.isFinal == true {
                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.setupRecognition()
            }
        }
        self.recognitionRequest = recognitionRequest
    }

    override func viewDidLayoutSubviews() {
        playerLayer.frame = view.bounds
    }
}

extension ViewController: MYAudioTabProcessorDelegate {
    // getting audio buffer back from the tap and feeding into speech recognizer
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, didReceive buffer: AVAudioPCMBuffer!) {
        recognitionRequest?.append(buffer)
    }
}

