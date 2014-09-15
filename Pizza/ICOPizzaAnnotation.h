//
//  ICOPizzaAnnotation.h
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface ICOPizzaAnnotation : NSObject <MKAnnotation>

// Pizza Place Location
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@property (weak, nonatomic) id delegate; // Callback for route and directions

@property (strong, nonatomic) UIButton *infoButton; // directions

-(id)initWithTitle:(NSString *)title address:(NSString *)address location:(CLLocationCoordinate2D)location;
-(MKAnnotationView *)annotationView;

@end
