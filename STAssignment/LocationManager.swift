//
//  LocationManager.swift
//  STAssignment
//
//  Created by Arsalan Akhtar on 11/22/19.
//  Copyright © 2019 Arsalan Akhtar. All rights reserved.
//

import UIKit
import CoreLocation

//possible errors
enum LocationManagerErrors: Int {
	case AuthorizationDenied
	case AuthorizationNotDetermined
	case InvalidLocation
}

class LocationManager: NSObject, CLLocationManagerDelegate {
	
	//location manager
	private var locationManager: CLLocationManager?
	
	//destroy the manager
	deinit {
		locationManager?.delegate = nil
		locationManager = nil
	}
	
	typealias LocationClosure = ((_ location: CLLocation?, _ error: Error?)->())
	private var didComplete: LocationClosure?
	
	//location manager returned, call didcomplete closure
	private func _didComplete(location: CLLocation?, error: Error?) {
		locationManager?.stopUpdatingLocation()
		didComplete?(location, error)
		locationManager?.delegate = nil
		locationManager = nil
	}
	
	//location authorization status changed
	
	
	internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .authorizedWhenInUse:
			self.locationManager!.startUpdatingLocation()
		case .denied:
			_didComplete(location: nil, error: NSError(domain:self.classForCoder.description(), code: LocationManagerErrors.AuthorizationDenied.rawValue, userInfo: nil))
		default:
			break
		}
	}

	
	internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		_didComplete(location: nil, error: error)
	}
	
	internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		_didComplete(location: locations[0], error: nil)
	}
	
	//ask for location permissions, fetch 1 location, and return
	func fetchWithCompletion(completion: @escaping LocationClosure) {
		//store the completion closure
		didComplete = completion
		
		//fire the location manager
		locationManager = CLLocationManager()
		locationManager!.delegate = self
		locationManager!.requestWhenInUseAuthorization()
	}
	
}

