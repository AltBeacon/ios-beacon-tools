/*
 * Radius Networks, Inc.
 * http://www.radiusnetworks.com
 *
 * @author David G. Young
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
#import "RNLExtraBeaconDataTracker.h"

@implementation RNLExtraBeaconDataTracker {
  NSMutableDictionary *_trackedExtraBeaconDictionary;
}

- (id)init {
  if (self = [super init]) {
    _trackedExtraBeaconDictionary = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (RNLBeacon *) extraDataBeaconForBeacon: (RNLBeacon *) beacon {
  return [_trackedExtraBeaconDictionary objectForKey:beacon.bluetoothIdentifier];
}

- (NSArray *) extraDataFieldsForBeacon: (RNLBeacon *) beacon {
  return [self extraDataBeaconForBeacon:beacon].dataFields;
}

-(void) updateWithRangedBeacon: (RNLBeacon *) beacon {
  [_trackedExtraBeaconDictionary setObject:beacon forKey:beacon.bluetoothIdentifier];
  NSLog(@"Tracking %d extra data beacons", (unsigned int)_trackedExtraBeaconDictionary.count);
}
@end
