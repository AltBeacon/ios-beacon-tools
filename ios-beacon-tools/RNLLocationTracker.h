//
//  SHKALocationTracker.h
//  Schicka
//
//  Created by James Nebeker on 11/4/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNLBeaconTracker.h"
#import "RNLBeacon.h"

@interface RNLLocationTracker : NSObject 
@property (readonly) RNLBeacon *closestBeacon;
@property Boolean useCoreLocationRanging;
@property RNLBeaconTracker *beaconTracker;

+ (id)sharedLocationTracker;
- (void)didRangeBeaconsInRegion:(NSArray *)beacons;

@end