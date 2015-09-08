//
//  AltbeaconScanner.m
//  Locatron
//
//  Created by Scott Yoder on 12/24/14.
//  Copyright (c) 2014 David Young. All rights reserved.
//

#import "RNLBeaconScanner.h"
#import "RNLBeaconParser.h"
#import "RNLBeaconTracker.h"
#import "RNLBeacon.h"
#import "RNLBeacon+Distance.h"

#define SECONDS_BEFORE_DROPOFF 5

@interface RNLBeaconScanner ()
@property (strong, nonatomic) CBCentralManager *cbManager;
@property (nonatomic) BOOL scanning;
@property (strong, nonatomic) NSArray *beaconParsers;
@property (strong, nonatomic) RNLBeaconTracker *beaconTracker;
@end

@implementation RNLBeaconScanner

+ (instancetype)sharedBeaconScanner {
  static RNLBeaconScanner *sharedBeaconScanner = nil;
  if (sharedBeaconScanner == nil) {
    sharedBeaconScanner = [[RNLBeaconScanner alloc] init];
  }
  return sharedBeaconScanner;
}

- (instancetype) init {
  self = [super init];
  self.beaconParsers = [[NSMutableArray alloc] init];
  RNLBeaconParser *altBeaconParser = [[RNLBeaconParser alloc] init];
  [altBeaconParser setBeaconLayout:@"m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25" error: Nil ];
  RNLBeaconParser *uidBeaconParser = [[RNLBeaconParser alloc] init];
  [uidBeaconParser setBeaconLayout:@"s:0-1=feaa,m:2-2=00,p:3-3:-41,i:4-13,i:14-19" error: Nil];
  self.beaconParsers = @[ altBeaconParser, uidBeaconParser ];
  self.debugEnabled = NO;
  
  self.beaconTracker = [[RNLBeaconTracker alloc] init];

  [self startScanningAltbeacons];
  return self;
}
- (void) dealloc {
  [self stopScanningAltbeacons];
}

- (void)startScanningAltbeacons {
  if (!self.cbManager) {
    self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    self.scanning = YES;
  }
}

- (void)stopScanningAltbeacons {
  [self.cbManager stopScan];
}

- (NSArray *)trackedBeacons {
  return self.beaconTracker.trackedBeacons;
}

- (NSNumber *)calibratedRSSIFor:(RNLBeacon *)beacon {
  NSString *key = [NSString stringWithFormat:@"%@ %@ %@", beacon.id1, beacon.id2, beacon.id3];
  for (RNLBeacon *trackedBeacon in self.trackedBeacons) {
    NSString *trackedBeaconKey = [NSString stringWithFormat:@"%@ %@ %@", trackedBeacon.id1, trackedBeacon.id2, trackedBeacon.id3];
    if ([trackedBeaconKey isEqualToString:key]) {
      return trackedBeacon.rssi;
    }
  }
  return Nil;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  if (central.state == CBCentralManagerStatePoweredOn && self.scanning) {
    [self.cbManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  NSDictionary *serviceData = advertisementData[@"kCBAdvDataServiceData"];
  
  RNLBeacon *beacon = Nil;
  NSData *adData = advertisementData[@"kCBAdvDataManufacturerData"];
  
  for (RNLBeaconParser *beaconParser in self.beaconParsers) {
    if (adData) {
      if (self.debugEnabled) {
        NSLog(@"didDiscoverPeripheral with manufacturer data");
      }
      beacon = [beaconParser fromScanData: adData withRssi: RSSI forDevice: peripheral serviceUuid: Nil];
    }
    else if (serviceData != Nil) {
      if (self.debugEnabled) {
        NSLog(@"didDiscoverPeripheral with service data");
      }
      for (NSObject *key in serviceData.allKeys) {
        NSString *uuidString = [(CBUUID *) key UUIDString];
        NSScanner* scanner = [NSScanner scannerWithString: uuidString];
        unsigned long long uuidLongLong;
        
        [scanner scanHexLongLong: &uuidLongLong];
        NSNumber *uuidNumber = [NSNumber numberWithLongLong:uuidLongLong];
        if (self.debugEnabled) {
          NSLog(@"Service data has length %lu", (unsigned long)((NSData *)[serviceData objectForKey:key]).length);
        }

        NSData *adServiceData = [serviceData objectForKey:key];
        if (adServiceData) {
          beacon = [beaconParser fromScanData: adServiceData withRssi: RSSI forDevice: peripheral serviceUuid: uuidNumber];
        }
      }
    }
    if (beacon != Nil) {
      break;
    }
  }

  if (beacon != Nil) {
    NSString *key = [NSString stringWithFormat:@"%@ %@ %@", beacon.id1, beacon.id2, beacon.id3];
    [self.beaconTracker updateWithRangedBeacons: @[beacon]];
    NSLog(@"Detected beacon: %@", key);
  }
  
  
}

@end
