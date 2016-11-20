//
//  LoggedInViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 08/11/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {
    
    @IBOutlet weak var advisoryText: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var viewCoursesButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        logoutButton.layer.cornerRadius = 4
        viewCoursesButton.layer.cornerRadius = 4

        advisoryText.text = "logged in as " + Utils.loggedInUser!
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func logout(_ sender: UIButton)
    {
        Utils.clearLoggedIn()
    }
}
