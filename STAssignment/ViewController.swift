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
	
	var locationManager: LocationManager?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fetchLocationAndStartMonitoring()
		NotificationCenter.default.addObserver(self, selector: #selector(onRegionExit(_:)), name: .exitRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onRegionEnter(_:)), name: .enterRegion, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onStoppedMonitoring(_:)), name: .stoppedMonitoring, object: nil)
	}
	
	func fetchLocationAndStartMonitoring(){
		
		locationManager = LocationManager()
		locationManager!.fetchWithCompletion { location, error in
			// fetch location or an error
			if let loc = location {
				
				let lox = Location(radius: 1000, coordinate: loc.coordinate)
				GeofenceManager.sharedInstance().startMonitoring(location: lox)
				
			} else if let err = error {
				print(err)
			}
			self.locationManager = nil
		}
	}
	
	@objc func onRegionEnter(_ notification: Notification)
	{
		if let data = notification.userInfo as? [String: String], let identifer = data["identifer"]
		{
			print(identifer)
		}
	}
	
	@objc func onRegionExit(_ notification: Notification)
	{
		if let data = notification.object as? String
		{
			print(data)
			
		}
	}
	
	@objc func onStoppedMonitoring(_ notification: Notification)
	{
		if let data = notification.object as? String
		{
			print(data)
			
		}
	}
	
}



