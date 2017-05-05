//
//  ViewController.swift
//  Metro
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.isAdditive = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.5
        animation.values = [-15.0, 15.0, -13.0, 13.0, -8.0, 8.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func change(color: UIColor, delay: Double = 0.2){
        UIView.animate(withDuration: 0.75, delay: delay, animations: {
            self.backgroundColor = color
        }, completion:nil)
    }
    
    func flash() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        }, completion: nil)
    }
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var fromStationButton: UIButton!
    @IBOutlet weak var toStationButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var fromStationLineIcon: UIImageView!
    @IBOutlet weak var toStationLineIcon: UIImageView!
    
    var model: Model!
    
    var language = Language.English
    
    var id: Int8 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Language
        let defaults = UserDefaults.standard
        if let lang = defaults.object(forKey: "Language") as? Int {
            model = Model(language: Language(rawValue: lang)!)
            set(language: Language(rawValue: lang)!)
        }
        // goButton Settings
        goButton.layer.borderColor =  #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1).cgColor
        goButton.layer.borderWidth = 3
        goButton.layer.cornerRadius = goButton.bounds.size.width / 2 // Circle goButton
        
        // Hide Icons
        toStationLineIcon.isHidden = true
        fromStationLineIcon.isHidden = true
        
        // Start and End Stations Seletion
        fromStationButton.layer.cornerRadius = 10
        toStationButton.layer.cornerRadius = 10
    }
    
    // MARK: UIPickerViewDelegate
    // TODO: Make prepare more readable
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromStation" {
            if let chooseStationController = segue.destination as? ChooseStationController {
                id = 1;
                chooseStationController.delegate = self
            }
        } else if segue.identifier == "toStation" {
            if let chooseStationController = segue.destination as? ChooseStationController {
                id = 2;
                chooseStationController.delegate = self
            }
        } else if segue.identifier == "ShowPaths" {
            if let pathsTableViewController = segue.destination as? PathsTableViewController {
                let start = fromStationButton.currentTitle!
                let end = toStationButton.currentTitle!
                pathsTableViewController.paths = model.search(from: start, to: end)
            }
        } else if segue.identifier == "SettingsSegue" {
            if let settings = segue.destination as? SettingsTableViewController {
                settings.delegate = self
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !(identifier == "ShowPaths") || goUpdate()
    }
    
    func makeButtonStyle(button: UIButton, text: String, color: UIColor =  #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)) {
        button.setTitle(text, for: .normal)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 3
        button.setTitleColor(.black, for: .normal)
    }
    
    func goUpdate() -> Bool {
        let isValid1 = model.isValidStation(station: fromStationButton.currentTitle ?? "")
        let isValid2 = model.isValidStation(station: toStationButton.currentTitle ?? "")
        let notEqual = toStationButton.currentTitle != fromStationButton.currentTitle
        
        if isValid1 && isValid2 && notEqual {
            goButton.change(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        } else {
            goButton.backgroundColor = .lightGray
            goButton.shake()
        }
        return isValid1 && isValid2 && notEqual
    }
    
    // fromStationButton and toStationButton defult views
    func defaultStyle(button: UIButton, text: String) {
        button.setTitle(text, for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.layer.borderWidth = 0
    }
}

extension ViewController : ChooseStationControllerDelegate {
    
    var stations: [Station] {
        return model.stations
    }
    
    func set(station: Station) {
      switch id {
        case 1:
            makeButtonStyle(button: fromStationButton, text: station.station)
            fromStationLineIcon.image = UIImage(named: String(station.line.characters.first!))
            fromStationLineIcon.isHidden = false;
        case 2:
            makeButtonStyle(button: toStationButton, text: station.station)
            toStationLineIcon.image = UIImage(named: String(station.line.characters.first!))
            toStationLineIcon.isHidden = false;
        default: break
        }
        
        let _ = goUpdate()
    }
}

extension ViewController: SettingDelegate {
    func set(language: Language) {
        
        guard language != self.language else {
            return
        }
        
        self.language = language
        model.changeLanguage(for: language)

        fromStationLineIcon.isHidden = true
        toStationLineIcon.isHidden = true
        
        // Language
        switch language {
        case .English:
            defaultStyle(button: fromStationButton, text: "From Station")
            defaultStyle(button: toStationButton, text: "To Station")
        case .Ukrainian:
            defaultStyle(button: fromStationButton, text: "Від станції")
            defaultStyle(button: toStationButton, text: "До станції")
        case .Russian:
            defaultStyle(button: fromStationButton, text: "От Станции")
            defaultStyle(button: toStationButton, text: "До Станации")
        }
        let _ = goUpdate()
    }
}
