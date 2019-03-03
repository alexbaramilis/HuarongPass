//
//  OptionsViewController.swift
//  华容道
//
//  Created by Alexandros Baramilis on 27/02/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import UIKit

/// The options view controller. Gets displayed when the user taps on the Options button.
class OptionsViewController: UIViewController {
    @IBOutlet weak var twoStepOptionSwitch: UISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the state of the option switch by looking for the saved value in UserDefaults (perists the setting between app runs)
        // if the key doesn't exist (ex. hasn't been set yet), it will return false, which is the default setting
        twoStepOptionSwitch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKey.AllowTwoBlockMoveInDifferentDirections), animated: false)
        // set the corresponding description
        descriptionLabel.text = twoStepOptionSwitch.isOn ? Text.Two_Step_Any_Direction : Text.Two_Step_One_Direction
    }
    
    @IBAction func twoStepOptionSwitchToggled(_ sender: UISwitch) {
        // if the switch is toggled, update the descriptiond and save the value in UserDefaults
        descriptionLabel.text = sender.isOn ? Text.Two_Step_Any_Direction : Text.Two_Step_One_Direction
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKey.AllowTwoBlockMoveInDifferentDirections)
    }
    
    @IBAction func xButtonTapped(_ sender: UIButton) {
        // dismiss the options screen
        dismiss(animated: true)
    }
}
