//
//  NavigationViewController.swift
//  racing-line
//
//  Created by Nick Johnson on 29/10/2016.
//  Copyright © 2016 Nick Johnson. All rights reserved.
//

import UIKit
import MapKit

class NavigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{

    @IBOutlet weak var followMeMap: MKMapView!
    var followMeCamera: MKMapCamera!
    var locationManager: CLLocationManager!
    var headingOffset: CLHeading!
    var cPath: MKPolyline?
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var mapModeButton: UISegmentedControl!
    @IBOutlet weak var mapScaleButton: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopButton.layer.cornerRadius = 4
        mapModeButton.layer.cornerRadius = 4
        mapScaleButton.layer.cornerRadius = 4
        
        // Do any additional setup after loading the view.
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .restricted || authStatus == .denied {
            print("authStatus is restricted or denied")
        }
        else
        {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            
            if authStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
            setLocationManagerAttributes (authStatus)
        }
        
        followMeMap.delegate = self
        followMeMap.mapType = .hybrid
        followMeMap.showsUserLocation = true
        followMeMap.add(cPath!)
        followMeCamera = MKMapCamera()
        followMeCamera.altitude = Utils.cameraHeight
        followMeCamera.pitch = CGFloat(Utils.cameraPitch)
        
        UIApplication.shared.isIdleTimerDisabled = true
        print ("disabling idle timer in navigationVC.viewDidLoad()")


    }
    
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
    
    func setLocationManagerAttributes(_ status: CLAuthorizationStatus)
    {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                print ("location services enabled - huzzah!")
                self.locationManager.desiredAccuracy = Utils.desiredAccuracy
                self.locationManager.distanceFilter = Utils.distanceFilter
                self.locationManager.startUpdatingLocation()
            }
            else {
                print("location services not enabled - boo!")
            }
            if CLLocationManager.headingAvailable() {
                print ("heading available - huzzah!")
                self.locationManager.startUpdatingHeading()
            }
            else{
                print ("heading not available - booo!")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if manager == self.locationManager {
            print ("now authorised: \(status)")
            setLocationManagerAttributes(status)
        }
        else
        {
            print("delegate called with wrong manager")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let groundCentre = locations.last!.coordinate

        self.followMeCamera.centerCoordinate = groundCentre
        
        self.followMeCamera.heading = Utils.isRowingNotRunning ? (locations.last!.course + 180.0).truncatingRemainder(dividingBy: 360.0) : locations.last!.course

        self.followMeMap.setCamera(self.followMeCamera, animated: true)
        
        print("new location in followMe")
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if manager == self.locationManager {
            headingOffset = newHeading
        }
        else
        {
            print("delegate called with wrong manager")
        }
        
    }
    
    func pass(coursePath path: MKPolyline?)
    {
        cPath = path
    }
    
    @IBAction func mapScale(_ sender: UISegmentedControl)
    {
      let action = sender.selectedSegmentIndex
      let alt = self.followMeCamera.altitude
      
      switch action
      {
        case 0:
          if alt > 10.0
          {
            followMeCamera.altitude = alt - 10.0
          }
        case 1:
            followMeCamera.altitude = alt + 10.0
        default:
            break
        }
        followMeMap.setCamera(followMeCamera, animated: true)
    }
    
    @IBAction func mapType(_ sender: UISegmentedControl)
    {
      let newType = sender.selectedSegmentIndex
        
      print ("new slider = \(newType)")
        
      switch(newType)
      {
        case 0:
          followMeMap.mapType = MKMapType.standard
        case 1:
          followMeMap.mapType = MKMapType.satellite
        case 2:
          followMeMap.mapType = MKMapType.hybrid
        default: break
      }
    }
}
