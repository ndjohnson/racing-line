//
//  ViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 29/10/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var uName: UILabel!

    @IBOutlet weak var settingsButtonImage: UIButton!
    
    @IBOutlet weak var coursePickerView: UIPickerView!
    
    var coursePicker:CoursePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.uName.text = "not logged in"
        
        self.coursePicker = CoursePicker()
        self.coursePickerView.delegate = self.coursePicker
        self.coursePickerView.dataSource = self.coursePicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func settingsButtonPress(_ sender: UIButton) {
    }

    func getCourseList(_ uname: String?) {
        if (Utils.serverName != nil) {
            var rq = URLRequest(url: URL(string: "http://" + Utils.serverName! + "cgi-bin/readCourseList.php")!)
            rq.httpMethod = "POST"
            let postString = "uname=\(uname)&asJson=1"
            rq.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: rq) {
                data, response, error in guard let data = data, error == nil else { print ("error=\(error)"); return }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print ("status return \(httpStatus.statusCode)")
                    print ("response is \(response)")
                }
                
                do {
                    let str = String(data: data, encoding: .utf8)
                    print("responseStr: \(str)")
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    print("jsonObject = \(jsonObject)")
                    let courseArray = jsonObject as! Array<Array<String>>
                    self.coursePicker?.courseList = []
                    for courseName in courseArray {
                        self.coursePicker?.courseList.append(courseName[0])
                        print(courseName[0])
                        print(type(of: courseName[0]))
                    }
                }
                catch let error as NSError {
                    print("error = \(error)")
                }
                
                DispatchQueue.main.async {self.coursePickerView.reloadAllComponents()}
                print("called readCourseList.php")
            }
            task.resume()
        }
    }
    
    @IBAction func unwindToHomeScreen(unwindSegue: UIStoryboardSegue) {
        
        if let settingsVC = unwindSegue.source as? SettingsViewController {
            self.uName.text = settingsVC.uName.text
        }
        print ("cancel Segue to home screen")
    }

    @IBAction func unwindAndSaveToHomeScreen(unwindSegue: UIStoryboardSegue) {
        
        if let settingsVC = unwindSegue.source as? SettingsViewController {
            self.uName.text = settingsVC.uName.text
            
            getCourseList(Utils.loggedInUser)
        }
        print ("save Segue to home screen")
    }
}

class CoursePicker : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

    var courseList = [String]()
    var selectedCourseIndex:Int = 0
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courseList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courseList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCourseIndex = row
    }
}
