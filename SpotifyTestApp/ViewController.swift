//
//  ViewController.swift
//  SpotifyTestApp
//
//  Created by Daniel Yo on 2/5/19.
//  Copyright © 2019 Daniel Yo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let textfieldInput: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = UITextField.BorderStyle.roundedRect
        return textfield
    }()
    
    var player: AVPlayer = AVPlayer()
    
    @IBOutlet weak var buttonSubmit: UIButton!
    
    private var value: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfieldInput.delegate = self
        textfieldInput.frame = CGRect(x: 50, y: 100, width: 300, height: 40)
        self.view.addSubview(textfieldInput)
    }
    
    
    @IBAction func buttonSubmitTouchUpInside(_ sender: Any) {
        self.textfieldInput.resignFirstResponder()
        self.player.pause()
        SpotifyManager().getSongData(withTitle: self.value!, success: { (previewURL) in
            self.PlaySong(fromURL: previewURL)
        }) { (errorMessage) in
            let alert = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func PlaySong(fromURL url:String) {
        
        do {
            guard let URL = URL(string: url) else { return }
            let playerItem = AVPlayerItem(url: URL)
            self.player = AVPlayer(playerItem: playerItem)
            
            let playerLayer = AVPlayerLayer(player: player)
            
            playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
            self.view.layer.addSublayer(playerLayer)
            self.player.play()
            
        } catch {
            print("FAILED")
        }
    }
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.value = textField.text
        print(self.value ?? "")
    }
}
