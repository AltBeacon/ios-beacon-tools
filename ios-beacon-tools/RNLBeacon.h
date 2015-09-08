//
//  RNLBeacon.h
//  Locatron
//
//  Created by David Young on 12/29/14.
//  Copyright (c) 2014 David Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNLBeacon : NSObject
@property (strong, nonatomic) NSArray *identifiers;
@property (strong, nonatomic) NSArray *dataFields;
@property (strong, nonatomic) NSNumber *measuredPower;
@property (strong, nonatomic) NSNumber *rssi;
@property (strong, nonatomic) NSNumber *beaconTypeCode;
// This is the two byte manuracturer code, e.g. 0x0118 for Radius Networks
// Only populated for manufacturer beacon types
@property (strong, nonatomic) NSNumber *manufacturer;
// This is the bluetooth device name transmitted in the scan response
@property (strong, nonatomic) NSString *name;
// The Bluetooth Service UUID.  Only populated for service beacon types
@property (strong, nonatomic) NSNumber *serviceUuid;
@property (strong, nonatomic) id beaconObject;
@property (readonly) NSString *id1;
@property (readonly) NSString *id2;
@property (readonly) NSString *id3;
@property (readonly) double coreLocationAccuracy;

@end
