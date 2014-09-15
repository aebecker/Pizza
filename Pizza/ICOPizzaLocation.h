//
//  ICOPizzaLocations.h
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//
// Callout to Four Square for Pizza Locations around User
//
#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

#import "ICOAppDelegate.h"

@interface ICOPizzaLocation : NSObject

@property MKCoordinateRegion region; // struct

+(ICOPizzaLocation *) sharedICOPizzaLocation;

@property (weak, nonatomic) id delegate; // For Adding Annotations

-(BOOL)find:(CLLocationCoordinate2D)location; // Center to search from

@end
