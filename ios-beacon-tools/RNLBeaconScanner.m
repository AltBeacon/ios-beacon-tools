/*
 * Radius Networks, Inc.
 * http://www.radiusnetworks.com
 *
 * @author Scott Yoder
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


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
@property (strong, nonatomic) NSString *rangingBluetoothIdentifier;
@property (strong, nonatomic) NSString *rangingId1;
@property (strong, nonatomic) NSString *rangingId2;
@property (strong, nonatomic) NSString *rangingId3;
@property (strong, nonatomic) NSTimer *rangingTimer;
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
  RNLBeaconParser *urlBeaconParser = [[RNLBeaconParser alloc] init];
  [urlBeaconParser setBeaconLayout:@"s:0-1=feaa,m:2-2=10,p:3-3:-41,i:4-20v" error: Nil];
  RNLBeaconParser *eidBeaconParser = [[RNLBeaconParser alloc] init];
  [eidBeaconParser setBeaconLayout:@"s:0-1=feaa,m:2-2=30,p:3-3:-41,i:4-11" error: Nil];
  RNLBeaconParser *tlmBeaconParser = [[RNLBeaconParser alloc] init];
  [tlmBeaconParser setBeaconLayout:@"x,s:0-1=feaa,m:2-2=20,d:3-3,d:4-5,d:6-7,d:8-11,d:12-15" error: Nil];

  self.beaconParsers = @[ altBeaconParser, uidBeaconParser, urlBeaconParser, eidBeaconParser, tlmBeaconParser];
  self.debugEnabled = NO;
  self.beaconTracker = [[RNLBeaconTracker alloc] init];
  [self startScanning];
  return self;
}
- (void) dealloc {
  [self stopScanning];
}

- (void)startScanning {
  [self registerSimulatedBeacons];
  if (!self.cbManager) {
    self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()
                                       options:@{ CBCentralManagerOptionRestoreIdentifierKey:
                                                    @"myCentralManagerIdentifier" }];
    self.scanning = YES;
  }
}

- (void)stopScanning {
  [self.cbManager stopScan];
}

- (NSArray *)trackedBeacons {
  [self.beaconTracker purgeExpiredBeacons];
  return self.beaconTracker.trackedBeacons;
}

- (NSArray *)extraDataFieldsForBeacon: (RNLBeacon *) beacon {
  return [self.beaconTracker.extraBeaconDataTracker extraDataFieldsForBeacon:beacon];
}

- (void) startRangingBeaconsWithBluetoothIdentifier: (NSString *) bluetoothIdentifier id1:  (NSString *) id1 id2: (NSString*) id2 id3: (NSString *) id3 {
  self.rangingBluetoothIdentifier = bluetoothIdentifier;
  self.rangingId1 = id1;
  self.rangingId2 = id2;
  self.rangingId3 = id3;
  self.rangingTimer = [NSTimer scheduledTimerWithTimeInterval:1  target: self selector: @selector(rangingTimerExpired) userInfo: nil repeats: YES];
}

- (void) stopRangingBeacons {
  if (self.rangingTimer) {
    [self.rangingTimer invalidate];
    self.rangingTimer = nil;
  }
}

- (void) rangingTimerExpired {
  NSArray *beacons = [RNLBeacon matchBeacons: self.trackedBeacons bluetoothIdentifier: self.rangingBluetoothIdentifier id1: self.rangingId1 id2: self.rangingId2 id3: self.rangingId3];
  [[NSNotificationCenter defaultCenter] postNotificationName: @"didRangeBeacons" object: nil userInfo: @{@"beacons": beacons}];
  
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
    CBUUID *eddystone16BitUUID = [CBUUID UUIDWithString:@"FEAA"];
    NSLog(@"eddy uuid is %@", [eddystone16BitUUID UUIDString]);
    [self.cbManager scanForPeripheralsWithServices:@[eddystone16BitUUID] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
    // this scans for AltBeacons
    [self.cbManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];

  }
  else {
    if (central.state == CBCentralManagerStateUnknown) {
      NSLog(@"CoreBluetooth state UNKNOWN");
    }
    else if (central.state == CBCentralManagerStateResetting)  {
      NSLog(@"CoreBluetooth state RESETTING");
    }
    else if (central.state == CBCentralManagerStateUnsupported)  {
      NSLog(@"CoreBluetooth state UNSUPPORTED");
    }
    else if (central.state == CBCentralManagerStateUnauthorized)  {
      NSLog(@"CoreBluetooth state UNAUTHORIZED");
    }
    else if (central.state == CBCentralManagerStatePoweredOff)  {
      NSLog(@"CoreBluetooth state POWERED OFF");
    }
  }
}

- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary *)state {
  
  NSArray *peripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
  NSLog(@"Bluetooth restoration with peripheral count: %ld", (unsigned long) peripherals.count);
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
      beacon.bluetoothIdentifier = [peripheral.identifier UUIDString];
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
  [self registerSimulatedBeacons];

  
}

-(void) registerSimulatedBeacons {
  if (self.simulatedBeacons != nil) {
    [self.beaconTracker updateWithRangedBeacons:self.simulatedBeacons];
  }
}

@end
