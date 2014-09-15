//
//  ICODirectionsPopupTableViewController.h
//  Pizza
//
//  Created by Tony Becker on 9/2/14.
//  Copyright (c) 2014 Tony Becker. All rights reserved.
//
//  TableView containing list of turn by turn directions

#import <UIKit/UIKit.h>

@interface ICODirectionsPopupTableViewController : UITableViewController

// Array of string turn by turn directions.
@property (strong, nonatomic) NSArray *directions;

@end
