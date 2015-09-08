//
//  SHKASignalMeasurement.h
//  Schicka
//
//  Created by David Young on 12/10/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNLSignalMeasurement : NSObject
@property NSNumber *rssi;
@property NSDate *timestamp;
@end
