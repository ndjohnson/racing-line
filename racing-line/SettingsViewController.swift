//
//  SettingsViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 29/10/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var rowingNotRunningValue: UISwitch!
    
    @IBOutlet weak var rowingNotRunningShow: UILabel!
    
    @IBOutlet weak var desiredAccuracy: UITextField!
    @IBOutlet weak var cameraHeight: UITextField!
    @IBOutlet weak var distanceFilter: UITextField!
    @IBOutlet weak var cameraAngle: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var isRowingNotRunning:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rowingNotRunningChange(rowingNotRunningValue)
        cameraAngle.text = String(Utils.cameraPitch)
        cameraHeight.text = String(Utils.cameraHeight)
        distanceFilter.text = String(Utils.distanceFilter)
        desiredAccuracy.text = String(Utils.desiredAccuracy)
        
        cancelButton.layer.cornerRadius = 4
        saveButton.layer.cornerRadius = 4
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.3
        
        isRowingNotRunning = Utils.isRowingNotRunning
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func doSave()
    {
        Utils.cameraPitch = Double(cameraAngle.text!)!
        Utils.cameraHeight = Double(cameraHeight.text!)!
        Utils.desiredAccuracy = Double(desiredAccuracy.text!)!
        Utils.distanceFilter = Double(distanceFilter.text!)!
        Utils.isRowingNotRunning = isRowingNotRunning!
        
        Utils.persistSettings()
    }
    
    @IBAction func editedSomething(_ sender: UITextField)
    {
        saveButton.isEnabled = true
        saveButton.alpha = 1.0
    }
    
    @IBAction func rowingNotRunningChange(_ sender: UISwitch)
    {
        saveButton.isEnabled = true
        saveButton.alpha = 1.0
        
        if sender.isOn {
            self.rowingNotRunningShow.text = "Rowing"
            isRowingNotRunning = true
        }
        else
        {
            self.rowingNotRunningShow.text = "Running"
            isRowingNotRunning = false
        }
    }
    
}
