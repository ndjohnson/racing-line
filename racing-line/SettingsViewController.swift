//
//  SettingsViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 29/10/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var uName: UILabel!
    
    @IBOutlet weak var rowingNotRunningValue: UISwitch!
    
    @IBOutlet weak var rowingNotRunningShow: UILabel!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rowingNotRunningChange(rowingNotRunningValue)
        
        self.uName.text = "not logged in"
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

    @IBAction func loginName(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    @IBAction func password(_ sender: UITextField) {
    
        sender.resignFirstResponder()
    }
    
    @IBAction func passwordStart(_ sender: UITextField) {
    }
    
    @IBAction func rowingNotRunningChange(_ sender: UISwitch) {
        if sender.isOn {
            self.rowingNotRunningShow.text = "Rowing"
        }
        else
        {
            self.rowingNotRunningShow.text = "Running"
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if Utils.isLoggedIn {
          Utils.clearLoggedIn()
          self.uName.text = "not logged in"
          sender.setTitle("Login", for: .normal)
        }
        else
        {
          if Utils.serverName != nil {
            var rq = URLRequest(url: URL(string: "http://" + Utils.serverName! + "/cgi-bin/appLogin.php")!)
            
            rq.httpMethod = "POST"
            let postString = "uname=\(self.username.text!)&passwd=\(self.password.text!)"
            rq.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: rq) {
                data, response, error in guard let data = data, error == nil else { print ("error=\(error)"); return }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print ("status return \(httpStatus.statusCode)")
                    print ("response is \(response)")
                }
                
                do {
                    let str = String(data: data, encoding: .utf8)
                    print ("responseStr = \(str)")
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    print ("jsonObject = \(jsonObject)")
                    let responseDict = jsonObject as! [String:Any]
                    let loginSucceeded = responseDict["loginSucceeded"] as! Bool
                    let uName = responseDict["uname"]
                    let rName = responseDict["realname"]
                    let errMsg = responseDict["errMsg"]
                    
                    DispatchQueue.main.async {
                      if loginSucceeded {
                        self.uName.text = "Logged in as: \(uName!) (\(rName!))"
                        Utils.setLoggedIn(uName as! String?)
                        sender.setTitle("Logout", for: .normal)
                      }
                      else {
                        Utils.clearLoggedIn()
                        self.uName.text = "not logged in"
                      }
                    }
                    
                    if errMsg != nil {
                        print (errMsg!)
                    }
                }
                catch let error as NSError {
                    print ("error reading login response: \(error)")
                }
            }
            task.resume()
          }
        }
        username.resignFirstResponder()
        password.resignFirstResponder()
        
    }
}
