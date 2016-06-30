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
#import "RNLURLBeaconCompressor.h"
#import "RNLBeacon.h"
@implementation RNLURLBeaconCompressor

+ (NSString *)URLStringFromEddystoneURLIdentifier:(NSString *)identifier {
  NSData *data = [RNLBeacon dataFromIdentifier: identifier];

  return [RNLURLBeaconCompressor URLStringFromEddystoneURLData:data];
}


+ (NSString *)URLStringFromEddystoneURLData:(NSData *)URLData
{
  NSMutableString *URLString;
  for (int i = 0; i < URLData.length; i++)
  {
    NSArray *prefixes = @[@"http://www.", @"https://www.", @"http://", @"https://"];
    NSArray *expansions = @[@".com/", @".org/", @".edu/", @".net/", @".info/", @".biz/", @".gov/", @".com", @".org", @".edu", @".net", @".info", @".biz", @".gov"];
    
    Byte aByte;
    [URLData getBytes:&aByte range:NSMakeRange(i, 1)];
    NSInteger index = aByte;
    if (i == 0)
    {
      // this is the prefix byte
      if (index < prefixes.count)
      {
        URLString = [NSMutableString stringWithString:prefixes[index]];
      }
      else
      {
        return nil;
      }
    }
    else if ( index <= 13)
    {
      [URLString appendString:expansions[index]];
    }
    else if ((index >= 14) && (index <= 32))
    {
      // this is a reserved value
      return nil;
    }
    else if ((index >= 127) && (index <= 255))
    {
      // this is a reserved value
      return nil;
    }
    else
    {
      [URLString appendString:[[NSString alloc]initWithBytes:&aByte length:1 encoding:NSUTF8StringEncoding]];
    }
    
  }
  
  return URLString;
}

@end
