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
    static var loggedInUser: String?
    static var serverName: String?

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
            serverName = envDict["TestServer"]
            
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
    
    
    
}
