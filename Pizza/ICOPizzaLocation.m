//
//  ICOPizzaLocations.m
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//
// find all the pizza joints from the regions center location.

#import "ICOPizzaLocation.h"
#import "ICOPizzaAnnotation.h"

#import "ICOViewController.h"

// https://api.foursquare.com/v2/venues/search?client_id=MSB3H0C14BLRSSAAYGELVLAAWVKWUL5DXYVMWF2UJPUVZOMC&client_secret=ZSDRDRBEZHO4DUH5TWS2DQMOUP1MMBBMEZJBNDZZVXTUFZX1&v=20130815&ll=40.7,-74&query=pizza

@interface ICOPizzaLocation () <NSURLConnectionDelegate>

@property(nonatomic, strong) NSMutableData *receivedData;
@property(nonatomic, strong) NSDictionary *JSONDictionary;

@end


@implementation ICOPizzaLocation

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(ICOPizzaLocation *) sharedICOPizzaLocation
{
    if(extraLogging)NSLog(@"%s %d", __PRETTY_FUNCTION__, __LINE__);
    static ICOPizzaLocation *sharedInstance = nil;
    static dispatch_once_t once = 0;
    
    if( !sharedInstance ) {
        dispatch_once(&once,^{
            sharedInstance = [ICOPizzaLocation new];
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
        _receivedData = [NSMutableData new];
    }
    return self;
}

/**
 * User FourSquare query to find Pizza Joins near me
 * Client ID & Secret was supplied.
 * Maybe enhance to add search bar for other things.
 *
 *  @param location <#location description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)find:(CLLocationCoordinate2D)location {
    CGFloat lat = location.latitude;
    CGFloat lon = location.longitude;
    if(extraLogging)NSLog(@"%s %d (%f,%f)", __PRETTY_FUNCTION__, __LINE__, lat, lon);

    BOOL success = YES;
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=MSB3H0C14BLRSSAAYGELVLAAWVKWUL5DXYVMWF2UJPUVZOMC&client_secret=ZSDRDRBEZHO4DUH5TWS2DQMOUP1MMBBMEZJBNDZZVXTUFZX1&v=20130815&ll=%.1f,%.1f&query=Pizza&intent=browse&radius=15000", lat, lon];
    // Note single decimal place - otherwise nothing returned
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setTimeoutInterval:10.0];
    
    [self.receivedData setLength:0]; // clear data out old data, if any
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (!connection) {
        if(extraLogging)NSLog(@"%s %d Connection Failed", __PRETTY_FUNCTION__, __LINE__);
        success = NO;
    }
    
    if(extraLogging)NSLog(@"%s %d Connection %@", __PRETTY_FUNCTION__, __LINE__, (success ? @"Success" : @"Failed"));
    return success;
    
}

#pragma mark - NSURLConnection delegate

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(extraLogging)NSLog(@"%s %d Asynchronous connection data %lu", __PRETTY_FUNCTION__, __LINE__, (unsigned long)data.length);
	[self.receivedData appendData:data];
}

// when done, parse out the JSON into a dictionary, and build MKAnnotations.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(extraLogging)NSLog(@"%s %d Asynchronous Response Data (%lu bytes):\n%@", __PRETTY_FUNCTION__, __LINE__, (unsigned long)self.receivedData.length, [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
    
    NSError *jsonError = nil;
    _JSONDictionary = [NSJSONSerialization JSONObjectWithData:self.receivedData options:0 error:&jsonError];
    if( jsonError )
        NSLog(@"WARNING: JSON Parse error - %@", jsonError);
    
    NSArray *places = [_JSONDictionary valueForKeyPath:@"response.venues"];
    for(int i=0;i<places.count;i++) {
        // get some useful values
        NSString *name = [[places objectAtIndex:i] valueForKey:@"name"];
        if(extraLogging)NSLog(@"%s %d, found %@", __PRETTY_FUNCTION__, __LINE__, name);
        NSDictionary *loc = [[places objectAtIndex:i] valueForKey:@"location"];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[loc valueForKey:@"lat"] floatValue], [[loc valueForKey:@"lng"] floatValue]);
        NSString *address = [loc valueForKey:@"address"];
        
        // create an annotation for each
        ICOPizzaAnnotation *icopa = [[ICOPizzaAnnotation alloc] initWithTitle:name address:address location:coord];
        icopa.delegate = _delegate;
        [_delegate addAnnotation:icopa];
    }
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(extraLogging)NSLog(@"%s %d Asynchronous connection response %@", __PRETTY_FUNCTION__, __LINE__, response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(extraLogging)NSLog(@"%s %d Asynchronous connection failure %@", __PRETTY_FUNCTION__, __LINE__, error);
}

- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse {
    return inRequest; // may need to handle redirects
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

@end
