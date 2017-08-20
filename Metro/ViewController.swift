 //
//  ViewController.swift
//  Metro
//
//  Created by Ali on 4/27/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

enum ViewOnFocus: Int {
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

    func flash() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.backgroundColor = UIColor.FlashAnimation.start
            self.backgroundColor = UIColor.FlashAnimation.end
        }, completion: nil)
    }

}

class ViewController: UIViewController {

    @IBOutlet weak var from: StationView!
    @IBOutlet weak var to: StationView!
    @IBOutlet weak var goButton: CircleButton!

    var model: Model!
    var language = Language.English
    var onFocus: ViewOnFocus = .from

    var canUpdateGo: Bool {
        let isValid1 = model.isValidStation(station: from.text)
        let isValid2 = model.isValidStation(station: to.text)
        let notEqual = to.text != from.text
        return isValid1 && isValid2 && notEqual
    }

    private func languageSetup() {
        let defaults = UserDefaults.standard
        if let lang = defaults.object(forKey: "Language") as? Int {
            model = Model(language: Language(rawValue: lang)!)
            set(language: Language(rawValue: lang)!)
        } else {
            model = Model(language: language)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Language
        languageSetup()

        // Hide Icons
        to.hideIcon()
        from.hideIcon()

        // Actions
        to.onTap = {
            self.onFocus = .to
            self.performSegue(withIdentifier: "choose", sender: self)
        }

        from.onTap = {
            self.onFocus = .from
            self.performSegue(withIdentifier: "choose", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "choose":
            (segue.destination as? ChooseStationController)?.delegate = self
        case "results":
            let paths = model.search(from: from.text, to: to.text)
            (segue.destination as? PathsTableViewController)?.paths = paths
        case "settings":
            (segue.destination as? SettingsTableViewController)?.delegate = self
        default: break
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "results") { goButton.update(x: canUpdateGo) }
        return !(identifier == "results") || canUpdateGo
    }

}

extension ViewController : ChooseStationControllerDelegate {

    var stations: [Station] {
        return model.stations
    }

    func set(station: Station) {
        var view: StationView;
        switch onFocus {
            case .from: view = from
            case .to: view = to
        }
        view.set(text: station.name)
        view.icon = UIImage(named: String(station.line.characters.first!))!
        view.showIcon()
        goButton.update(x: canUpdateGo)
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
        goButton.update(x: canUpdateGo)
    }

}
