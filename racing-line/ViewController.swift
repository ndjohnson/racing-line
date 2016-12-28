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
    @IBOutlet weak var courseMap: MKMapView!
    
    @IBOutlet weak var scaleControl: UISegmentedControl!

    @IBOutlet weak var mapModeControl: UISegmentedControl!
    
    @IBOutlet weak var selectCourseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var retrievingCourses: UIActivityIndicatorView!
    
    var coursePicker:CoursePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if Utils.isLoggedIn
        {
            uName.text = "logged in as " + Utils.loggedInUser!
        }
        else
        {
            uName.text = "not logged in"
        }
        scaleControl.layer.cornerRadius = 4
        mapModeControl.layer.cornerRadius = 4
        selectCourseButton.layer.cornerRadius = 4
        
        coursePicker = CoursePicker()
        coursePickerView.delegate = self.coursePicker
        coursePickerView.dataSource = self.coursePicker
        coursePicker?.courseMap = courseMap
        coursePicker?.activityIndicator = retrievingCourses
        
        courseMap.delegate = coursePicker
        
        getCourseList(Utils.loggedInUser)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func settingsButtonPress(_ sender: UIButton) {
    }

    func populatePicker(_ jsonObject: Any?)
    {
        let courseArray = jsonObject as! Array<Array<String>>
        self.coursePicker?.courseList = []
        for courseName in courseArray
        {
            self.coursePicker?.courseList.append(courseName[0])
            print(courseName[0])
            print(type(of: courseName[0]))
        }

        DispatchQueue.main.async
        {
            self.coursePickerView.reloadAllComponents()
            self.coursePicker?.loadFirstCourse()
        }
    }
    
    func getCourseList(_ uname: String?)
    {
        Utils.post(to: "readCourseList.php", ssl: false, postString: "loginName=\(uname!)&asJson=1", activityIndicator: retrievingCourses, onSuccess: populatePicker)
    }
    
    @IBAction func mapMode(_ sender: UISegmentedControl)
    {
      let newType = sender.selectedSegmentIndex
        
      print ("new slider = \(newType)")
        
      switch(newType)
      {
        case 0:
          courseMap.mapType = MKMapType.standard
        case 1:
          courseMap.mapType = MKMapType.satellite
        case 2:
          courseMap.mapType = MKMapType.hybrid
        default: break
      }
    }
    
    @IBAction func mapScale(_ sender: UISegmentedControl)
    {
      let action = sender.selectedSegmentIndex
      var region = courseMap.region
        
      switch action
      {
        case 0:
          region.span.latitudeDelta /= 2.0
          region.span.longitudeDelta /= 2.0
        case 1:
          region.span.latitudeDelta *= 2.0
          region.span.longitudeDelta *= 2.0
        default:
          break
      }
      courseMap.setRegion(region, animated: true)
    }
    
    @IBAction func unwindToHomeScreen(unwindSegue: UIStoryboardSegue) {
        
        UIApplication.shared.isIdleTimerDisabled = false
        print ("Segue to home screen: enabling idle timer")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let newVC = segue.destination as? NavigationViewController
        {
            newVC.pass(coursePath: self.coursePicker?.cPath)
        }
    }
    
    @IBAction func unwindAndSaveToHomeScreen(unwindSegue: UIStoryboardSegue) {
        
        if let sourceVC = unwindSegue.source as? SettingsViewController
        {
            sourceVC.doSave()
        }
        
        getCourseList(Utils.loggedInUser)
        print ("save Segue to home screen")
    }
    
    @IBAction func unwindAndCancelToHomeScreen(unwindSegue: UIStoryboardSegue) {
        
        getCourseList(Utils.loggedInUser)
        print ("cancel Segue to home screen")
    }
    
    @IBAction func swipeToNavigation(_ sender: UISwipeGestureRecognizer)
    {
        performSegue(withIdentifier: "segueToNavigation", sender: self)

    }
    @IBAction func swipeToLogin(_ sender: UISwipeGestureRecognizer)
    {
    }
}

class CoursePicker : NSObject, UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate {

    var courseList = [String]()
    var selectedCourseIndex:Int = 0
    var courseMap:MKMapView?
    var activityIndicator:UIActivityIndicatorView?
    var cPath:MKPolyline?
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = UIColor.red
            polyLineRenderer.lineWidth = 2
            return polyLineRenderer
        }
        else
        {
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func populateMap(_ jsonObject: Any?)
    {
        var courseDict = jsonObject as! [String:Any]
        let courseName = courseDict["course_name"]
        print("course name is \(courseName)")
        
        var minLat = Double(90.0)
        var maxLat = Double(-90.0)
        var minLng = Double(180.0)
        var maxLng = Double(-180.0)
        
        let pathData = courseDict["pathData"]
        print("pathData is \(pathData)")
        var coursePath = [CLLocationCoordinate2D]()
        for wp in pathData as! Array<Dictionary<String,Double>>
        {
            let lat = wp["lat"]
            let lng = wp["lng"]
            print("waypoint is \(lat), \(lng)")
            coursePath.append(CLLocationCoordinate2D(latitude: lat!,longitude: lng!))
            
            if (lat! < minLat) { minLat = lat! }
            if (lat! > maxLat) { maxLat = lat! }
            if (lng! < minLng) { minLng = lng! }
            if (lng! > maxLng) { maxLng = lng! }
            
        }

        cPath = MKPolyline.init(coordinates: coursePath, count: coursePath.count)
        
        let coordSpan = MKCoordinateSpanMake(maxLat - minLat, maxLng - minLng)
        let coordCentre = CLLocationCoordinate2DMake((maxLat + minLat)/2.0, (maxLng + minLng)/2.0)
        let region = MKCoordinateRegionMake(coordCentre, coordSpan)
        
        DispatchQueue.main.async {
            self.courseMap?.region = region
            if let overlays = self.courseMap?.overlays
            {
              self.courseMap?.removeOverlays(overlays)
            }
            self.courseMap?.add(self.cPath!)
        }

    }

    func loadFirstCourse()
    {
        let firstCourse = courseList[0]
        getCourseData(firstCourse)
    }
    
    func getCourseData(_ course: String?)
    {
        Utils.post(to: "readCourseData.php", ssl: false, postString: "course_name=\(course!)", activityIndicator: activityIndicator, onSuccess: populateMap)
    }
    
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
        getCourseData(courseList[row])
    }
}
