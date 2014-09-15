//
//  ICODeviceLocation.h
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//
//  Utility Singleton to manage user location
// Not used - MapKit Does it all

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import "ICOAppDelegate.h"

@interface ICODeviceLocation : NSObject <CLLocationManagerDelegate> {}

@property CLLocationManager *locationManager;
@property CLLocation *location;

+(ICODeviceLocation *) sharedICODeviceLocation;

@end
