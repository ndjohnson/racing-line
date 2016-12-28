//
//  utils.swift
//  racing-line
//
//  Created by Nick Johnson on 04/11/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import Foundation
import UIKit

class Utils {

    static var isLoggedIn: Bool = false
    static var allowHttps: Bool = true
    static var clearLoginOnExit: Bool = false
    static var loggedInUser: String?
    static var loggedInPassword: String?
    static var serverName: String?
    static var cameraHeight: Double = 100.0
    static var cameraPitch:Double = 45.0
    static var distanceFilter = 10.0
    static var desiredAccuracy = 5.0
    static var isRowingNotRunning = true
    static var isProductionNotTest = true
    static var panStartCoord:CGPoint = CGPoint.zero
    

    static func setProductionMode(_ isProdNotTest:Bool = true)
    {
        isProductionNotTest = isProdNotTest
        initServerName()
        post(to: "appLogin.php", ssl: true, postString: "uname=\(loggedInUser!)&passwd=\(loggedInPassword!)", onSuccess: validateLogin)
        
    }
    
    static func setTestMode()
    {
        setProductionMode(false)
    }
    
    static func checkLoginAtStartup ()
    {
        let userDefaults = UserDefaults.standard
        
        if let loginDetails = userDefaults.dictionary(forKey: "loginDetails") as? [String:Any?]
        {
            print ("found login details")
            
            if let isLi = loginDetails["isLoggedIn"] as? Bool
            {
                isLoggedIn = isLi
                
                if let li = loginDetails["uName"] as? String
                {
                    loggedInUser = li
                    loggedInPassword = KeychainWrapper.standard.string(forKey: loggedInUser!)
                }
            }
            else
            {
                clearLoggedIn()
            }
        }
        else
        {
            print ("login details not found")
        }

        if let settings = userDefaults.dictionary(forKey: "settings") as? [String:Any?]
        {
            print ("settings found")
            if let ch = settings["cameraHeight"] as? Double
            {
                cameraHeight = ch
            }
            if let cp = settings["cameraPitch"] as? Double
            {
                cameraPitch = cp
            }
            if let df = settings["distanceFilter"] as? Double
            {
                distanceFilter = df
            }
            if let da = settings["desiredAccuracy"] as? Double
            {
                desiredAccuracy = da
            }
            if let ir = settings["isRowingNotRunning"] as? Bool
            {
                isRowingNotRunning = ir
            }
            if let ip = settings["isProductionNotTest"] as? Bool
            {
                isProductionNotTest = ip
            }
        }
        else
        {
            print("settings not found")
        }
    }

    
    static func persistLogin (_ password: String?)
    {
        let userDefaults = UserDefaults.standard
        
        if isLoggedIn
        {
            var loginDetails = [String:Any]()
            
            loginDetails["isLoggedIn"] = isLoggedIn
            loginDetails["uName"] = loggedInUser!
            userDefaults.set(loginDetails, forKey: "loginDetails")

            guard KeychainWrapper.standard.set(password!, forKey: loggedInUser!)
            else
            {
                print ("password save failed")
                return
            }
        }
    }
    
    static func persistSettings()
    {
        let userDefaults = UserDefaults.standard
        
        var settings = [String:Any]()
        
        settings["cameraHeight"] = cameraHeight
        settings["cameraPitch"] = cameraPitch
        settings["distanceFilter"] = distanceFilter
        settings["desiredAccuracy"] = desiredAccuracy
        settings["isRowingNotRunning"] = isRowingNotRunning
        settings["isProductionNotTest"] = isProductionNotTest
        
        userDefaults.set(settings, forKey: "settings")
        
        print ("saved settings")
    }
    
    static func clearLoginDetailsIfNecessary ()
    {
        if clearLoginOnExit
        {
            let userDefaults = UserDefaults.standard
        
            userDefaults.set(nil, forKey: "loginDetails")
            if let user = loggedInUser
            {
              KeychainWrapper.standard.set("", forKey: user)
            }
        }
    }
    
    static func validateLogin(_ jsonObject: Any?)
    {
        let responseDict = jsonObject as! [String:Any]
        let loginSucceeded = responseDict["loginSucceeded"] as! Bool
        let uName = responseDict["uname"]
        let errMsg = responseDict["errMsg"]
        
        if loginSucceeded
        {
            setLoggedIn(uName as! String?)
        }
        else
        {
            clearLoggedIn()
            print ("login on startup failed, message = \(errMsg!)")
        }
    }
    
    static func setLoggedIn (_ uName: String?) {
          isLoggedIn = (uName != nil)
          loggedInUser = uName
    }
    
    static func clearLoggedIn () {
        isLoggedIn = false
        loggedInUser = nil
    }
    
    static func initServerName() {
        if let infoPlist = Bundle.main.infoDictionary,
            let envDict = infoPlist["LSEnvironment"] as? Dictionary<String, String>
        {
            serverName = isProductionNotTest ? envDict["ProductionServer"] : envDict["TestServer"]
            allowHttps = isProductionNotTest
            
            if serverName == nil {
                print("couldn't find server name")
            }else{
                print("server name is \(serverName!)")
            }
        }
        else{
            serverName = nil
        }
    }
    
    static func post(to: String?, ssl: Bool, postString: String?, activityIndicator: UIActivityIndicatorView? = nil, onSuccess: @escaping (_ jsonObject: Any?) -> Void)
    {
        let protocolStr = (ssl && allowHttps) ? "https://" : "http://"
        var rq = URLRequest(url: URL(string: protocolStr + Utils.serverName! + "cgi-bin/" + to!)!)
        rq.httpMethod = "POST"
        rq.httpBody = postString!.data(using: .utf8)
        
        print ("rq.Data is \(rq.allHTTPHeaderFields),")
        
        if activityIndicator != nil
        {
            DispatchQueue.main.async{activityIndicator?.startAnimating()}
        }
        
        let task = URLSession.shared.dataTask(with: rq)
        {
        data, response, error in

            if activityIndicator != nil
            {
                DispatchQueue.main.async{activityIndicator?.stopAnimating()}
            }
            
            guard let data = data, error == nil else
            {
                print ("error=\(error)")
                return
            }
                
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {
                print ("status return \(httpStatus.statusCode)")
                print ("response is \(response)")
            }
                
            do
            {
                let str = String(data: data, encoding: .utf8)
                print("responseStr: \(str)")
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                print("jsonObject = \(jsonObject)")
                
                onSuccess(jsonObject)
            }
            catch let error as NSError
            {
                print("error = \(error)")
            }
        }
        task.resume()
    }
    
    static func pan(_ sender: UIPanGestureRecognizer, parentView:UIView)
    {
        if sender.state == .began
        {
            
        }
        let translation = sender.translation(in: parentView)
        if let view = sender.view
        {
            if sender.state == .began
            {
                panStartCoord = view.center
            }
            if sender.state == .ended
            {
                view.center = panStartCoord
            }
            else
            {
                view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
            }
        }
        sender.setTranslation(CGPoint.zero, in: parentView)
    }
}
