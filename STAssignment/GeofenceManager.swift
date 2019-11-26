//
//  GeofenceManager.swift
//  STAssignment
//
//  Created by Arsalan Akhtar on 11/23/19.
//  Copyright © 2019 Arsalan Akhtar. All rights reserved.
//

import Foundation
import CoreLocation
import Network

extension Notification.Name {
	static let enterRegion = Notification.Name("enterRegion")
	static let exitRegion = Notification.Name("exitRegion")
	static let stoppedMonitoring = Notification.Name("stoppedMonitoring")
}

class GeofenceManager: NSObject {
	
	private override init() {
		super.init()
		locationManager.delegate = self
		wifiMonitoring()
	}
	
	private let locationManager = CLLocationManager()
	
	private var monitoringLocations = [Location]()
	
	class func sharedInstance() -> GeofenceManager {
		struct Static {
			static let instance = GeofenceManager()
		}
		return Static.instance
	}
	
	func startMonitoring(location:Location) {
		let fenceRegion = region(location: location)
		locationManager.startMonitoring(for: fenceRegion)
		locationManager.requestState(for: fenceRegion)
		monitoringLocations.append(location)
	}
	
	func stopMonitoring(location:Location?, forAll:Bool = false) {
		for region in locationManager.monitoredRegions {
	
			guard let circularRegion = region as? CLCircularRegion,
				circularRegion.identifier == location?.identifier || forAll else {
					continue
			}
			
			locationManager.stopMonitoring(for: circularRegion)
			if let loc = location, let index = monitoringLocations.firstIndex(of: loc) {
				monitoringLocations.remove(at: index)
			}
		}
		
		if forAll {
			monitoringLocations.removeAll()
		}
		
	}
	
	internal func region(location: Location) -> CLCircularRegion {
		let region = CLCircularRegion(center: location.coordinate ,
									  radius: location.radius,
									  identifier: location.identifier)
		
		return region
	}
		
	internal func wifiMonitoring() {
		let wifiMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
		wifiMonitor.pathUpdateHandler = { _ in
			self.updateLocationStatusOnWifiSwitch()
		}
		let queue = DispatchQueue(label: "Monitor")
		wifiMonitor.start(queue: queue)
	}
	
	internal func updateLocationStatusOnWifiSwitch() {
		
		let currentNetworkName = getConnectedWifiName()
		
		let mappedLocations = monitoringLocations.map { (loc) -> Location in

			guard let wifiName = loc.wifiNetworkName, let status = loc.status else {
				return loc
			}
			
			var location = loc
			switch (status,wifiName) {
			case (Location.Status.outside,currentNetworkName) :
				location.status = .wifiConnectionOnly
				notifyChangeInRegion(state: .inside, identifier:location.identifier)
			case (Location.Status.wifiConnectionOnly,currentNetworkName) :
				break
			case (Location.Status.wifiConnectionOnly,_) :
				location.status = .outside
				notifyChangeInRegion(state: .outside, identifier:location.identifier)
			case (_, _):
				break
			}
		
			return location
		}
		
		monitoringLocations = mappedLocations
	}
	
	internal func updateLocationStatusOnRegionChange(state:CLRegionState, identifier:String) {
		
		let currentNetworkName = getConnectedWifiName()
		
		let mappedLocations = monitoringLocations.map { (loc) -> Location in

			guard loc.identifier == identifier else {
				return loc
			}
			
			var location = loc
			switch (location.status,state,location.wifiNetworkName) {
			case (Location.Status.inside?,.outside, currentNetworkName) :
				location.status = .wifiConnectionOnly
			case (_, .inside, _) :
				location.status = .inside
				notifyChangeInRegion(state: .inside, identifier:location.identifier)
				break
			case (Location.Status.wifiConnectionOnly?,.outside, currentNetworkName):
				break
			case (Location.Status.wifiConnectionOnly?,.outside, _) :
				notifyChangeInRegion(state: state, identifier:identifier)
				location.status = .outside
				break
			case (_,.outside, _) :
				notifyChangeInRegion(state: state, identifier:identifier)
				location.status = .outside
				break
			case (_, _, _):
				break
			}
		
			return location
		}
		
		monitoringLocations = mappedLocations
	}
}
	
extension GeofenceManager: CLLocationManagerDelegate {
	
	internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			print("Allowed")
		default:
			stopMonitoring(location:nil, forAll:true)
			notifyStoppedMonitoring()
		}
	}
	
	internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		if region is CLCircularRegion {
			updateLocationStatusOnRegionChange(state:.inside, identifier:region.identifier)
		}
	}
	
	internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		if region is CLCircularRegion {
			updateLocationStatusOnRegionChange(state:.outside, identifier:region.identifier)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		if region is CLCircularRegion {
			updateLocationStatusOnRegionChange(state: state, identifier:region.identifier)
		}
	}
	
}

// Notification Senders
extension GeofenceManager {

	internal func notifyChangeInRegion(state: CLRegionState, identifier:String) {
		switch state {
		case .inside:
			NotificationCenter.default.post(name: .enterRegion, object: self, userInfo: ["identifier":identifier])
		case .outside:
			NotificationCenter.default.post(name: .exitRegion, object: self, userInfo: ["identifier":identifier])
		case .unknown:
			break
		}
	}
	
	internal func notifyStoppedMonitoring() {
		NotificationCenter.default.post(name: .stoppedMonitoring, object: self, userInfo: nil)
	}
	
}
