//
//  sample.swift
//  ios-beacon-tools
//
//  Created by David G. Young on 7/19/18.
//  Copyright © 2018 Altbeacon.org. All rights reserved.
//

import Foundation

class Sample {
    var scanner: RNLBeaconScanner?
    func sample() {
        scanner = RNLBeaconScanner.shared()
        scanner?.startScanningAltbeacons()
        
        // Execute this code periodically (every second or so) to view the beacons detected
        if let detectedBeacons = scanner?.trackedBeacons() as? [RNLBeacon] {
            for beacon in detectedBeacons {
                if (beacon.beaconTypeCode.intValue == 0xbeac) {
                    // this is an AltBeacon
                    NSLog("Detected AltBeacon id1: %@ id2: %@ id3: %@", beacon.id1, beacon.id2, beacon.id3)
                }
                else if (beacon.beaconTypeCode.intValue == 0x00 && beacon.serviceUuid.intValue == 0xFEAA) {
                    // this is eddystone uid
                    NSLog("Detected EDDYSTONE-UID with namespace %@ instance %@", beacon.id1, beacon.id2)
                }
                else if (beacon.beaconTypeCode.intValue == 0x10 && beacon.serviceUuid.intValue == 0xFEAA) {
                    // this is eddystone url
                    NSLog("Detected EDDYSTONE-URL with %@", RNLURLBeaconCompressor.urlString(fromEddystoneURLIdentifier: beacon.id1))
                }
                else {
                    NSLog("Some other beacon detectd")
                    // some other beacon type
                }
                NSLog("The beacon is about %.1f meters away", beacon.distance)
                
            }
        }        
    }
}
