//
//  RNLBeaconParser.h
//  Locatron
//
//  Created by David Young on 12/28/14.
//  Copyright (c) 2014 David Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RNLBeacon.h"

@interface RNLBeaconParser : NSObject
-(BOOL) setBeaconLayout: (NSString *)beaconLayout error:(NSError **)errorPtr;
-(RNLBeacon *) fromScanData: (NSData *)scanData withRssi: (NSNumber *) rssi forDevice: (CBPeripheral *)device serviceUuid: (NSNumber *) serviceUuid;
-(RNLBeacon *) fromScanData: (NSData *)scanData withRssi: (NSNumber *) rssi forDevice: (CBPeripheral *)device serviceUuid: (NSNumber *) serviceUuid withBeacon: (RNLBeacon *)beacon;
@end
