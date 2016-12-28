//
//  LoginViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 05/11/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var keepLoggedInButton: UIButton!
    
    @IBOutlet weak var loginMeInButton: UIButton!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var advisoryText: UILabel!
    
    @IBOutlet weak var loggingIn: UIActivityIndicatorView!
    
    var accountName: String?
    
    var isKeepLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginMeInButton.layer.cornerRadius = 4
        
        if Utils.isLoggedIn
        {
            Utils.post(to: "appLogin.php", ssl: true, postString: "uname=\(Utils.loggedInUser!)&passwd=\(Utils.loggedInPassword!)", activityIndicator: loggingIn, onSuccess: validateLogin)
            
            username.text = Utils.loggedInUser!
            password.text = Utils.loggedInPassword!
            keepLoggedInButton.setImage(#imageLiteral(resourceName: "greyButtonChecked-1"), for: .normal)
            isKeepLoggedIn = true
        }
        else
        {
            loginMeInButton.setTitle("Login", for: .normal)
            advisoryText.text = ""
            let pwItem = KeychainWrapper.standard.string(forKey: username.text!)
            
            if let pw = pwItem
            {
              password.text = pw
            }
        }
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

    func validateLogin(_ jsonObject: Any?)
    {
        let responseDict = jsonObject as! [String:Any]
        let loginSucceeded = responseDict["loginSucceeded"] as! Bool
        let uName = responseDict["uname"]
        let errMsg = responseDict["errMsg"]
        
        DispatchQueue.main.async
        {
            if loginSucceeded
            {
                Utils.setLoggedIn(uName as! String?)
                self.advisoryText.text = "login succeeded"
                self.loginMeInButton.setTitle("Logout", for: .normal)
                if self.isKeepLoggedIn
                {
                    Utils.persistLogin(self.password.text)
                }
                self.performSegue(withIdentifier: "autoLoginSegue", sender: self)
            }
            else
            {
                print ("login of \(self.username.text) failed: \(errMsg)")
                self.advisoryText.text = "login failed"
                self.keepLoggedInButton.setImage(#imageLiteral(resourceName: "greyButtonUnchecked"), for: .normal)
                Utils.clearLoggedIn()

            }
        }
    }
    
    @IBAction func logMeIn(_ sender: UIButton)
    {
        if Utils.isLoggedIn
        {
            Utils.clearLoggedIn()
            loginMeInButton.setTitle("Login", for: .normal)
            username.text = nil
            password.text = nil
            advisoryText.text = "logged out"
        }
        else
        {
            Utils.post(to: "appLogin.php", ssl: true, postString: "uname=\(username.text!)&passwd=\(password.text!)", activityIndicator: loggingIn, onSuccess: validateLogin)
        }
    }
    
    @IBAction func showPassword(_ sender: UIButton)
    {
        if sender.isSelected
        {
            sender.isSelected = false
            password.isSecureTextEntry = true
        }
        else
        {
            sender.isSelected = true
            password.isSecureTextEntry = false
        }
    }
    
    @IBAction func keepLoggedIn(_ sender: UIButton) {
        
        if isKeepLoggedIn {
            isKeepLoggedIn = false
            keepLoggedInButton.setImage(#imageLiteral(resourceName: "greyButtonUnchecked"), for: .normal)
            Utils.clearLoginOnExit = true
        }
        else
        {
            isKeepLoggedIn = true
            keepLoggedInButton.setImage(#imageLiteral(resourceName: "greyButtonChecked-1"), for: .normal)
            Utils.clearLoginOnExit = false
        }
    }
    @IBAction func selectCourse(_ sender: UIButton)
    {
    }
    
    @IBAction func usernameUpdate(_ sender: UITextField)
    {
        if let candidatePassword = KeychainWrapper.standard.string(forKey: sender.text!)
        {
            password.text = candidatePassword
        }
    }
    
    @IBAction func unwindToLoginScreen(unwindSegue: UIStoryboardSegue)
    {
        Utils.clearLoggedIn()
        loginMeInButton.setTitle("Login", for: .normal)
        advisoryText.text = ""
        print ("logout Segue to home screen")
    }
    
    @IBAction func swipeToLogin(_ sender: UISwipeGestureRecognizer)
    {
        Utils.post(to: "appLogin.php", ssl: true, postString: "uname=\(username.text!)&passwd=\(password.text!)", activityIndicator: loggingIn, onSuccess: validateLogin)
        
    }
}
