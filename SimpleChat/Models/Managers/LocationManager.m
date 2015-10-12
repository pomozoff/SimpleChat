//
//  LocationManager.m
//  SimpleChat
//
//  Created by Anton Pomozov on 12.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

#pragma mark - Properties

@synthesize locationManager = _locationManager;

- (void)setLocationManager:(CLLocationManager *)locationManager {
    _locationManager = locationManager;
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //NSLog(@"%@", locations.lastObject);
}

#pragma mark - <LocationManager>

- (CLLocationCoordinate2D)currentCoordinate {
    return self.locationManager.location.coordinate;
}

@end
