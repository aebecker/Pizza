//
//  ICOViewController.m
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//

#import "ICOViewController.h"

#import "ICODeviceLocation.h"
#import "ICOPizzaLocation.h"

#import "ICOPizzaAnnotation.h"

#import "ICODirectionsPopupTableViewController.h"

#define DISTANCE 15000.0

@interface ICOViewController ()

// local storage of my utility classes
@property ICODeviceLocation *myDeviceLocation;
@property ICOPizzaLocation *myPizzaLocation;

// local storage of the map region
@property MKCoordinateRegion region;

// my table view of directions to Pizza Place
@property (strong, nonatomic) ICODirectionsPopupTableViewController *directionsTableView;

@property (strong, nonatomic) NSMutableArray *directions;

@end

@implementation ICOViewController

- (void)viewDidLoad
{
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 
    // setup my singletons
//    _myDeviceLocation = [ICODeviceLocation sharedICODeviceLocation]; // not needed on device - MapKit will update by itself
    _myPizzaLocation = [ICOPizzaLocation sharedICOPizzaLocation];
    _myPizzaLocation.delegate = self; // should make up a protocol
    
    _myMapView.showsUserLocation = YES; // note: set in storyboard too
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapView Delegate
/**
 *  Main Callback that fires everything off
 *
 *  @param mapView      <#mapView description#>
 *  @param userLocation <#userLocation description#>
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    CLLocationCoordinate2D coord = _myMapView.userLocation.location.coordinate;
    _region = MKCoordinateRegionMakeWithDistance(coord, DISTANCE, DISTANCE);
    
    _myMapView.region = _region;
    _myPizzaLocation.region = _region; // sync these up (simuulator)
    [_myPizzaLocation find:_region.center];

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
}

/**
 *  User selected a Pizza location.
 *  Go get a route (and directions)
 *
 *  @param mapView <#mapView description#>
 *  @param view    <#view description#>
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
        CLLocationCoordinate2D coord = ((ICOPizzaAnnotation *)view.annotation).coordinate;
    
        request.source = [MKMapItem mapItemForCurrentLocation];
        
        request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil]];
        request.requestsAlternateRoutes = NO;
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        
        // Async with Completion Block
        [directions calculateDirectionsWithCompletionHandler:
         ^(MKDirectionsResponse *response, NSError *error) {
             if (error) {
                 if(extraLogging)NSLog(@"%s %d Error: %@", __PRETTY_FUNCTION__, __LINE__, error);
             } else {
                 [self showRoute:response];
             }
         }];

}

/**
 *  For map view to show our pizza locations
 *  Called early and often.
 *
 *  @param mapView    <#mapView description#>
 *  @param annotation <#annotation description#>
 *
 *  @return <#return value description#>
 */
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if(extraLogging)NSLog(@"%s %d %@", __PRETTY_FUNCTION__, __LINE__, annotation);
    // Is it one of mine?
    if( [annotation isKindOfClass:[ICOPizzaAnnotation class]] ) {
        ICOPizzaAnnotation *icopa = (ICOPizzaAnnotation *)annotation;
        return icopa.annotationView;
    }
    return nil; // User Location?
}

/**
 *  Add a Pizza Location. Called from PizzaLocation (Four Square)
 *
 *  @param annotation <#annotation description#>
 */
-(void) addAnnotation:(ICOPizzaAnnotation *)annotation {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    [_myMapView addAnnotation:annotation];
}

// Test code. No longer called
-(void) redraw {
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    _myMapView.region = _region; // update /w annotations
}

/**
 *  Show the directions from current location to selected pizza
 *  Note directions built when route built
 */
-(void)showDirections
{
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    
    // create a (single) table view to show directions.
    if( !_directionsTableView ) {
        _directionsTableView = [ICODirectionsPopupTableViewController new];
        CGRect frame = _directionsTableView.view.frame;
        frame.origin.x += 20.0;
        frame.origin.y += 20.0;
        _directionsTableView.view.frame = frame; // tweek the offset. I miss iPad popovers.
    }
    // load up the directions for the table view
    _directionsTableView.directions = _directions;
    [_directionsTableView.tableView reloadData]; // for second time (view did load only called once)
    
    [self.view addSubview:_directionsTableView.view]; // how to make go away...
    
}

/**
 *  Show the route from current location to selected pizza
 *  Note that we build the driving directions here too
 *  Note that this takes a while.
 */
-(void)showRoute:(MKDirectionsResponse *)response
{
    if(extraLogging)NSLog(@"%s %d %@", __PRETTY_FUNCTION__, __LINE__, response);
    _directions = [NSMutableArray new];
    
    // clear any previous overlays (directions)
    if (_myMapView.overlays.count > 0)
        [_myMapView removeOverlay:[_myMapView.overlays objectAtIndex:0]];
    
    // loop through all lines and draw over roads
    for (MKRoute *route in response.routes)
    {
        // setup overlay
        [_myMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        // Build driving directions, to be displayed later.
        for (MKRouteStep *step in route.steps)
        {
            if(extraLogging)NSLog(@"%s %d %@", __PRETTY_FUNCTION__, __LINE__, step.instructions);
            [_directions addObject:step.instructions];
        }
    }
}

/**
 *  Build up a local renderer, small blue line for map to Pizza Place
 *
 *  @param mapView <#mapView description#>
 *  @param overlay <#overlay description#>
 *
 *  @return return MKOverlayRenderer rendered for blue line map to destination
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

@end
