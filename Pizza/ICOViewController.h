//
//  ICOViewController.h
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "ICOAppDelegate.h"
#import "ICOPizzaAnnotation.h"

@interface ICOViewController : UIViewController <MKMapViewDelegate, UIPopoverControllerDelegate>

@property IBOutlet MKMapView *myMapView;


// Add an Annotation (address) of Pizza Place
-(void) addAnnotation:(ICOPizzaAnnotation *)annotation;
// Show route to Pizza Place
-(void) showRoute:(MKDirectionsResponse *)response;
// Show directions to Pizza Place
-(void) showDirections;

@end
