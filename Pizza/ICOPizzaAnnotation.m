//
//  ICOPizzaAnnotation.m
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//
// Baby Annotation class to draw Pizza Icon, Annocation View popup

#import "ICOPizzaAnnotation.h"

#import "ICOAppDelegate.h"
#import "ICOViewController.h"

@interface ICOPizzaAnnotation ()
@end

@implementation ICOPizzaAnnotation

static UIImage *driving = nil;
static UIImage *pizza = nil;

-(id)initWithTitle:(NSString *)title address:(NSString *)address location:(CLLocationCoordinate2D)location {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    self = [super init];
    if(self) {
        _title = title;
        _subtitle = address;
        _coordinate = location;
        if( !driving )
            driving = [UIImage imageNamed:@"Directions"];
        if( !pizza )
            pizza = [UIImage imageNamed:@"Pizza"];
    }
    return self;
}

// Build an interactive view to be placed on the map.
-(MKAnnotationView *)annotationView {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    
    // Reuse if possible
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"PizzaAnnotation"];
    
    // Button with Driving directions Icon
    _infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_infoButton setBackgroundImage:driving forState:UIControlStateNormal];
    CGSize imageSize = driving.size;
    CGRect buttonFrame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    _infoButton.frame = buttonFrame;
    
    [_infoButton addTarget: self
              action: @selector(buttonClicked:)
    forControlEvents: UIControlEventTouchUpInside];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = pizza;
    annotationView.rightCalloutAccessoryView = _infoButton;
    annotationView.annotation = self; // used later to get coordinate, and then route
    return annotationView;
}

-(void) buttonClicked:(id)sendor {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
//    [self getDirections];
    [(ICOViewController *)_delegate showDirections];

}

//-(void) annotationClicked:(id)sendor {
//    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
//    [self getDirections];
//}

//- (void)getDirections
//{
//    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
//    MKDirectionsRequest *request =
//    [[MKDirectionsRequest alloc] init];
//    
//    request.source = [MKMapItem mapItemForCurrentLocation];
//    
//    request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:_coordinate addressDictionary:nil]];
//    request.requestsAlternateRoutes = NO;
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//    
//    // Async with Completion Block
//    [directions calculateDirectionsWithCompletionHandler:
//     ^(MKDirectionsResponse *response, NSError *error) {
//         if (error) {
//             if(extraLogging)NSLog(@"%s %d Error: %@", __PRETTY_FUNCTION__, __LINE__, error);
//         } else {
//             [(ICOViewController *)_delegate showRoute:response];
//         }
//     }];
//}
@end
