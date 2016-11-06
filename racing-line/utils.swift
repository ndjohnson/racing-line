//
//  utils.swift
//  racing-line
//
//  Created by Nick Johnson on 04/11/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import Foundation

class Utils {

    static var isLoggedIn: Bool = false
    static var allowHttps: Bool = true
    static var clearLoginOnExit: Bool = false
    static var loggedInUser: String?
    static var loggedInPassword: String?
    static var serverName: String?
    static var cameraHeight: Double = 100.0
    static var cameraPitch:Double = 45.0
    static var isRowingNotRunning = true

    static func checkLoginAtStartup ()
    {
        let userDefaults = UserDefaults.standard
        
        if let loginDetails = userDefaults.dictionary(forKey: "loginDetails") as? [String:Any?]
        {
            isLoggedIn = loginDetails["isLoggedIn"] as! Bool
        
            if isLoggedIn
            {
                loggedInUser = loginDetails["uName"] as? String
                loggedInPassword = loginDetails["pWord"] as? String
                
//                post(to: "appLogin.php", ssl: true, postString: "uname=\(uName)&passwd=\(pWord)", onSuccess: validateLogin)
            }
            else
            {
                clearLoggedIn()
            }
        }
    }

    
    static func persistLogin (_ password: String?)
    {
        if isLoggedIn
        {
            let userDefaults = UserDefaults.standard
            
            var loginDetails = [String:Any]()
            
            loginDetails["isLoggedIn"] = isLoggedIn
            loginDetails["uName"] = loggedInUser!
            loginDetails["pWord"] = password!
            
            userDefaults.set(loginDetails, forKey: "loginDetails")
        }
        
    }
    
    static func clearLoginDetailsIfNecessary ()
    {
        if clearLoginOnExit
        {
            let userDefaults = UserDefaults.standard
        
            userDefaults.set(nil, forKey: "loginDetails")
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
            let envDict = infoPlist["LSEnvironment"] as? Dictionary<String, String> {
            serverName = envDict["ProductionServer"]
            allowHttps = true
            
            if serverName == nil {
                print("couldn't find server name")
            }else{
                print("server name is \(serverName)")
            }
        }
        else{
            serverName = nil
        }
    }
    
    static func post(to: String?, ssl: Bool, postString: String?, onSuccess: @escaping (_ jsonObject: Any?) -> Void)
    {
        let protocolStr = (ssl && allowHttps) ? "https://" : "http://"
        var rq = URLRequest(url: URL(string: protocolStr + Utils.serverName! + "cgi-bin/" + to!)!)
        rq.httpMethod = "POST"
        rq.httpBody = postString!.data(using: .utf8)
        
        print ("rq.Data is \(rq.allHTTPHeaderFields),")
        
        let task = URLSession.shared.dataTask(with: rq)
        {
        data, response, error in
            guard let data = data, error == nil else { print ("error=\(error)"); return }
                
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
    
    
}
