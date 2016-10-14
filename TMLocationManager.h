//
//  TMLocationManager.h
//  WebserviceTrial
//
//  Created by Tushar Mohan on 12/10/16.
//  Copyright © 2016 Tushar Mohan. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TMLocationManager : CLLocationManager <CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocation* currentLocation;

+ (BOOL)isLocationAllowedForApp;

+ (BOOL)isActiveFromSettings;

+ (instancetype)getInstance;

- (void)fetchCurrentLocationWithContinousUpdates:(BOOL)isContinous
                                  withCompletion:(void (^)(CLLocation*))handler;
- (void)stopFetchingLocation;

- (void)getAddressFromLocation:(CLLocation*)location
                     isCurrent:(BOOL)isCurrentLocation
                  onCompletion:(void (^)(CLPlacemark*))throwBackAddress;

@end

/*
 Dont forget to add NSLocationWhenInUseUsageDescription and/or NSLocationAlwaysUsageDescription to the info.plist while using the location services
 */
