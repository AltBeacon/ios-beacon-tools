//
//  AltbeaconScanner.h
//  Locatron
//
//  Created by Scott Yoder on 12/24/14.
//  Copyright (c) 2014 David Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RNLBeacon.h"

@interface RNLBeaconScanner : NSObject <CBCentralManagerDelegate>

+ (instancetype) sharedBeaconScanner;

- (void) startScanningAltbeacons;
- (void) stopScanningAltbeacons;
- (NSNumber *) calibratedRSSIFor: (RNLBeacon *)beacon;
- (NSArray *) trackedBeacons;

@property Boolean debugEnabled;

@end
