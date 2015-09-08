//
//  RNLBeacon+Distance.h
//  Schicka
//
//  Created by James Nebeker on 12/17/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNLSignalMeasurement.h"
#import "RNLBeacon.h"
#import <CoreLocation/CoreLocation.h>

@interface RNLBeacon (Distance)

@property NSMutableArray *signalMeasurements;
@property NSDate *lastDetected;
@property NSDate *lastCalculated;
@property NSNumber *runningAverageRssi;
@property (readonly) CLLocationAccuracy distance;

-(void) applyRssiMeasurements: (RNLBeacon *)beacon;
+(double) secondsToAverage;
+(void) secondsToAverage: (double) seconds;

@end
