//
//  MySessionsViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/29/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsernameViewController.h"

@interface MySessionsViewController : UITableViewController <UsernameDelegate>

@property (nonatomic) int filterType;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *filterNamesArray;
@property (nonatomic, retain) NSMutableDictionary *allSessionsDict;

@end
