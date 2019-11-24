//
//  Location.swift
//  STAssignment
//
//  Created by Arsalan Akhtar on 11/22/19.
//  Copyright © 2019 Arsalan Akhtar. All rights reserved.
//

import CoreLocation

struct Region: Equatable {
	
	enum Status {
		case inside
		case outside
		case wifiConnectionOnly
	}
	
	let radius: CLLocationDistance
	let coordinate: CLLocationCoordinate2D
	let identifier = UUID().uuidString
	let wifiNetworkName = getConnectedWifiName()
	var status:Status? = nil
	
	static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	mutating func setStatus(status:Status){
		self.status = status
	}
}
