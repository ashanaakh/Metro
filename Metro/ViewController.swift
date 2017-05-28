 //
//  ViewController.swift
//  Metro
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

enum OnFocus: Int {
    case from
    case to
}

extension UIColor {
    struct Button {
        static var disable: UIColor {
            return .lightGray
        }
        static var enable: UIColor {
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
        static var border: UIColor {
            return #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        }
    }
    
    struct FlashAnimation {
        static var start: UIColor {
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        static var end: UIColor {
            return #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        }
    }
}

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
            self.backgroundColor = UIColor.FlashAnimation.start
            self.backgroundColor = UIColor.FlashAnimation.end
        }, completion: nil)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var from: StationControl!
    @IBOutlet weak var to: StationControl!
    @IBOutlet weak var goButton: UIButton!
    
    var model: Model!
    var language = Language.English
    var id: OnFocus = .from
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Language
        let defaults = UserDefaults.standard
        if let lang = defaults.object(forKey: "Language") as? Int {
            model = Model(language: Language(rawValue: lang)!)
            set(language: Language(rawValue: lang)!)
        } else {
            model = Model(language: language)
        }
        
        // Hide Icons
        to.hideIcon()
        from.hideIcon()
        
        // Actions
        to.onTap = {
            self.id = .to
            self.performSegue(withIdentifier: "choose", sender: self)
        }
        from.onTap = {
            self.id = .from
            self.performSegue(withIdentifier: "choose", sender: self)
        }
    }
    
    // MARK: UIPickerViewDelegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choose" {
            if let chooseStationController = segue.destination as? ChooseStationController {
                chooseStationController.delegate = self
            }
        }  else if segue.identifier == "ShowPaths" {
            if let pathsTableViewController = segue.destination as? PathsTableViewController {
                let res = model.search(from: from.text, to: to.text)
                pathsTableViewController.paths = res
            }
        } else if segue.identifier == "SettingsSegue" {
            if let settings = segue.destination as? SettingsTableViewController {
                settings.delegate = self
            }
        }
    }
    
    var canUpdateGo: Bool {
        let isValid1 = model.isValidStation(station: from.text)
        let isValid2 = model.isValidStation(station: to.text)
        let notEqual = to.text != from.text 
        
        return isValid1 && isValid2 && notEqual
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !(identifier == "ShowPaths") || canUpdateGo
    }
    
    func setStyle(for view: StationControl, with text: String) {
        view.text = text;
        view.borderWidth = 3
    }
    
    func goUpdate() {
        guard canUpdateGo else {
            goButton.backgroundColor = UIColor.Button.disable
            goButton.shake()
            return
        }
        goButton.change(color: UIColor.Button.enable)
    }
}

extension ViewController : ChooseStationControllerDelegate {
    
    var stations: [Station] {
        return model.stations
    }
    
    func set(station: Station) {
        var view: StationControl;
        switch id {
            case .from: view = from
            case .to: view = to
        }
        
        setStyle(for: view, with: station.name)
        view.icon = UIImage(named: String(station.line.characters.first!))!
        view.showIcon()
        goUpdate()
    }
}

extension ViewController: SettingDelegate {
    func set(language: Language) {
        
        guard language != self.language else {
            return
        }
        
        self.language = language
        model.changeLanguage(for: language)

        from.clear()
        to.clear()	
        
        // Language
        switch language {
        case .English:
            from.placeholder = "From Station"
            to.placeholder = "From Station"
        case .Ukrainian:
            from.placeholder = "Від станції"
            to.placeholder = "До станції"
        case .Russian:
            from.placeholder = "От Станции"
            to.placeholder = "До Станации"
        }
        goUpdate()
    }
}
