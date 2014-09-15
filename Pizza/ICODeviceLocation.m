//
//  ICODeviceLocation.m
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//

#import "ICODeviceLocation.h"

@implementation ICODeviceLocation

// Singleton
+(ICODeviceLocation *) sharedICODeviceLocation
{
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    static ICODeviceLocation *sharedInstance = nil;
    static dispatch_once_t once = 0;
    
    if( !sharedInstance ) {
        dispatch_once(&once,^{
            sharedInstance = [ICODeviceLocation new];
        });
    }
    
    return sharedInstance;
}

/**
 *  Initialize the class
 *
 *  @return The Class Instance
 */
-(id)init {
    if ((self = [super init])) {
        if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
        _location = nil;
        // Start up a core location manager
        _locationManager = [[CLLocationManager alloc] init]; // Create new instance of a location manager
        _locationManager.delegate = self;
        // New for iOS 8.0
        // Also new .plist key
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];

    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if(extraLogging)NSLog(@"[%@ %@] %@", [self class], NSStringFromSelector(_cmd), newLocation);
    _location = newLocation;
}

/**
 *  Location manager Failed. Normally Due to running on simulator.
 *  Insert a "home" location.
 *
 *  @param manager <#manager description#>
 *  @param error   <#error description#>
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(extraLogging)NSLog(@"[%@ %@] %@", [self class], NSStringFromSelector(_cmd), error);
    
    _location = [[CLLocation alloc] initWithLatitude:26.085824 longitude:-80.195606]; // simulator
    
}

// Once we've got a bunch, turn it off
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    if(extraLogging)NSLog(@"[%@ %@] %@", [self class], NSStringFromSelector(_cmd), locations);
    [_locationManager stopUpdatingLocation]; // timer for updates?
}


@end
