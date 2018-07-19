# iOS Beacon Tools

This project contains iOS utilities to scan for and decode beacons using AltBeacon and
Eddystone formats that are not natively supported by iOS.

This code detects AltBeacon, Eddystone-UID, Eddystone-URL, Eddystone-TLM and Eddystone-EID (without resolution)

## Overview

By copying this code into your project, you can use the singleton `RNLBeaconScanner` class to
scan for bluetooth beacon and then periodically read out the beacons that are detected.  Detected
beacons can be access from an array on the `scanner.trackedBeacons()` method.  

This list of detected beacons is updated internally as beacons come in, and the code provides no callbacks.  You'll
need to some way to run code periodically to read the list of detected beacons.

## Example

```
class Sample {
    var scanner: RNLBeaconScanner?
    func sample() {
        scanner = RNLBeaconScanner.shared()
        scanner?.startScanning()
        
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
                    // some other beacon type
                }
            }
        }        
    }
}
```

## TODOs:

1. Add better documentation
2. Convert the code into Swift
3. Make this a framework so you don't have to copy the source

## License

This code is open source under the Apache 2 license.  See LICENSE file in this repo.

## Bugs?  Problems?

Open an issue on this project, or a question on StackOverflow.com
