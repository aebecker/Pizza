//
//  PizzaTests.m
//  PizzaTests
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ICOPizzaLocation.h"

#define DISTANCE 1000

@interface PizzaTests : XCTestCase

@property (assign) int count;

@end

@implementation PizzaTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _count = 0;

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPizzasLocation
{
    
    CLLocationCoordinate2D home = CLLocationCoordinate2DMake(26.085824, -80.195606);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(home, DISTANCE, DISTANCE);
    ICOPizzaLocation *pizzas = [ICOPizzaLocation sharedICOPizzaLocation];
    pizzas.region = region; // load location;
    pizzas.delegate = self;
    [pizzas find:region.center];

    // wait for it... Off of this thread 8-(
    
    XCTAssertTrue(_count > 0, @"No pizza locations returned for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)addAnnotation:(id)anObject {
    NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    _count++;
}


@end
