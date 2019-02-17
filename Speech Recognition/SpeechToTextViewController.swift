//
//  SpeechToTextViewController.swift
//  Speech Recognition
//
//  Created by Brendan Krekeler on 2/14/19.
//  Copyright © 2019 Brendan Krekeler. All rights reserved.
//

import UIKit
import Speech

class SpeechToTextViewController: UIViewController {

    @IBOutlet weak var recordedTextView: UITextView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    
    let recognizer = SFSpeechRecognizer()
    let audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var recording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SFSpeechRecognizer.authorizationStatus() != .authorized {
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.recordButton.isEnabled = true
                default:
                    self.recordButton.isEnabled = false
                    let alert = UIAlertController(title: "Unable to access speech recognizer", message: "You need to grant permission for speech recognition. You can do this in your settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func toggleRecord(_ sender: Any) {
        if recording {
            self.recordButton.title = "Record"
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            request.endAudio()
            recognitionTask?.cancel()
        } else {
            guard let recognizer = recognizer, recognizer.isAvailable else {
                return
            }
            let node = audioEngine.inputNode
            let recordingFormat = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.request.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print(error.localizedDescription)
                return
            }
            
            recognitionTask = recognizer.recognitionTask(with: request) { result, _ in
                if let transcription = result?.bestTranscription {
                    self.recordedTextView.text = transcription.formattedString
                }
            }
            self.recordButton.title = "Stop"
        }
        recording = !recording
    }
}
