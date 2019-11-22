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
	}

	func fetchLocationAndStartMonitoring(){
        
        locationManager = LocationManager()
        locationManager!.fetchWithCompletion { location, error in
            // fetch location or an error
            if let loc = location {
                
				print(loc)
                
            } else if let err = error {
               print(err)
            }
            self.locationManager = nil
        }
    }

}



