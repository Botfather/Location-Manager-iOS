//
//  TMLocationManager.m
//  WebserviceTrial
//
//  Created by Tushar Mohan on 12/10/16.
//  Copyright © 2016 Tushar Mohan. All rights reserved.
//


#import "TMLocationManager.h"
@interface TMLocationManager ()
{
    BOOL _updateContinously;
    BOOL _isLocationSent;
    void (^newLocationTrigger)(CLLocation* location);
}
@end

@implementation TMLocationManager

#pragma mark - Location Services Check Methods

/*
 if([TMLocationManager isLocationAllowedForApp])
 {
    *perform the SUCCESS action here*
 }
 else
 {
    if([TMLocationManager isActiveFromSettings])
        {
            *location disbaled specifically for this application*
            *Ask user to grant the app the location access*
        }
    else
        {
            *location disbaled from the settings*
            *Ask user to turn on the location services in settings*
        }
 }
 */

//to check if the location is specifically disabled for the current app or not
+ (BOOL)isLocationAllowedForApp
{
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        return YES;
    }
    return NO;
}

//to check if the location is set from settings or not
+ (BOOL) isActiveFromSettings
{
    NSLog(@"%i",[CLLocationManager locationServicesEnabled]);
    return [CLLocationManager locationServicesEnabled];
}


#pragma mark - Instantiate and Instance retreival methods

//returns the saved instance of the TMLocationManager
+ (instancetype)getInstance{
    static TMLocationManager *sSharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sSharedInstance = [[TMLocationManager alloc] init];
    });
    return sSharedInstance;
}

- (id)init{
    self = [super init];
    self.delegate = self;
    self.distanceFilter = kCLDistanceFilterNone;
    self.desiredAccuracy = kCLLocationAccuracyBest;
        if ([self respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self requestWhenInUseAuthorization];
        }
    return self;
}



#pragma mark - Location Access Methods

//sets the continous location iVar and calls the startUpdatingLocation method in CLLocationManager
- (void)fetchCurrentLocationWithContinousUpdates:(BOOL)isContinous withCompletion:(void (^)(CLLocation *))handler{
    _updateContinously = isContinous;
    [self startUpdatingLocation];
    //save the handler block received in a global property
    newLocationTrigger = handler;
    _isLocationSent = NO;
}

- (void)stopFetchingLocation{
    [self stopUpdatingLocation];
}



#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{   if((!_isLocationSent)||(_isLocationSent&&_updateContinously))
{
    if (locations.count < 1)
    {
        return;
    }
    CLLocation *newLocation = [locations lastObject];
    if ( ! _updateContinously)
    {
        [self stopUpdatingLocation];
    }
    self.currentLocation = newLocation;
    newLocationTrigger(newLocation);
    _isLocationSent = YES;
}
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    newLocationTrigger(nil);
}

#pragma mark - Reverse Geo Coding
- (void)getAddressFromLocation:(CLLocation*)location
                             isCurrent:(BOOL)isCurrentLocation
                          onCompletion:(void (^)(CLPlacemark*))throwBackAddress
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc]init];
    if(isCurrentLocation)
    {
        [geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray* placemarks, NSError* error) {
            CLPlacemark *addressReceived = [placemarks lastObject];
        if(error)
        {
            NSLog(@"%@", [error localizedDescription]);
            addressReceived=nil;
        }
        throwBackAddress(addressReceived);
    }];
    }
    else
    {   
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error) {
            CLPlacemark *addressReceived = [placemarks lastObject];
        if(error)
        {
            NSLog(@"%@", [error localizedDescription]);
            addressReceived=nil;
        }
        throwBackAddress(addressReceived);
        }];
    }
}


@end
