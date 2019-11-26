//
//  ViewController.swift
//  STAssignment
//
//  Created by Arsalan Akhtar on 11/21/19.
//  Copyright © 2019 Arsalan Akhtar. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
	
	@IBOutlet weak var messageLbl: UILabel!
	@IBOutlet weak var meterTextField: UITextField!
	@IBOutlet weak var startMonitoringButton: UIButton!
	var location:Location? = nil
	var locationManager:LocationManager? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(onRegionExit(_:)), name: .exitRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onRegionEnter(_:)), name: .enterRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onStoppedMonitoring(_:)), name: .stoppedMonitoring, object: nil)
		composeMessage(string: "Waiting for input!")
	}
	
	func fetchLocationAndStartMonitoring(){
		
		locationManager = LocationManager()
		locationManager!.fetchWithCompletion { fetchedLocation, error in
			// fetch location or an error
			if let loc = fetchedLocation {
				
				if let radius = Float(self.meterTextField.text!){
					self.location = Location(radius: CLLocationDistance(radius), coordinate: loc.coordinate)
					GeofenceManager.sharedInstance().startMonitoring(location: self.location!)
				}
			} else if let err = error {
				print(err)
			}
			self.locationManager = nil
		}
	}
	
	func disableInputControl() {
		startMonitoringButton.isEnabled = false
		meterTextField.isEnabled = false
		
	}
	
	func composeMessage(string:String) {
		messageLbl.text = string
	}
	
	func enableInputControl() {
		startMonitoringButton.isEnabled = true
		meterTextField.isEnabled = true
	}
	
	@objc func onRegionEnter(_ notification: Notification)
	{
		
		if let data = notification.userInfo as? [String: String], let identifer = data["identifier"], let location = self.location, identifer == location.identifier
		{
			disableInputControl()
			composeMessage(string: "Inside")
		}
	}
	
	@objc func onRegionExit(_ notification: Notification)
	{
		if let data = notification.userInfo as? [String: String], let identifer = data["identifier"], let location = self.location, identifer == location.identifier
		{
			disableInputControl()
			composeMessage(string: "Outside")
		}
	}
	
	@objc func onStoppedMonitoring(_ notification: Notification)
	{
		enableInputControl()
		composeMessage(string: "Monitoring Stopped! - Waiting for input!")
	}
	
	@IBAction func startMonitoring(_ sender: Any) {
		fetchLocationAndStartMonitoring()
		self.view.endEditing(true)
	}
	
}



