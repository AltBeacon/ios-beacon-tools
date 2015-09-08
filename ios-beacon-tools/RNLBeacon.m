//
//  RNLBeacon.m
//  Locatron
//
//  Created by David Young on 12/29/14.
//  Copyright (c) 2014 David Young. All rights reserved.
//

#import "RNLBeacon.h"
#import <CoreLocation/CoreLocation.h>

@implementation RNLBeacon
-(NSString *) id1 {
  NSString *id = Nil;
  if (self.identifiers.count > 0) {
    id = [self.identifiers objectAtIndex:0];
  }
  return id;
}
-(NSString *) id2 {
  NSString *id = Nil;
  if (self.identifiers.count > 1) {
    id = [self.identifiers objectAtIndex:1];
  }
  return id;
}
-(NSString *) id3 {
  NSString *id = Nil;
  if (self.identifiers.count > 2) {
    id = [self.identifiers objectAtIndex:2];
  }
  return id;
}

-(double) coreLocationAccuracy {
  if (self.beaconObject != Nil && [self.beaconObject isKindOfClass:[CLBeacon class]]) {
    return ((CLBeacon *)self.beaconObject).accuracy;
  }
  return -1.0;
}

@end
