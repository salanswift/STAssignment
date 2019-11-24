//
//  Utilities.swift
//  STAssignment
//
//  Created by Arsalan Akhtar on 11/24/19.
//  Copyright © 2019 Arsalan Akhtar. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

func getConnectedWifiName() -> String? {
	var ssid: String?
	if let interfaces = CNCopySupportedInterfaces() as NSArray? {
		for interface in interfaces {
			if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
				ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
				break
			}
		}
	}
	return "ssid"
}
