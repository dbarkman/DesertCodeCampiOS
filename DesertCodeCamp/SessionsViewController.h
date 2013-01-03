//
//  SessionsViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/21/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionsViewController : UITableViewController

@property (nonatomic) int filterType;
@property (nonatomic, retain) NSArray *sessionNamesArray;
@property (nonatomic, retain) NSString *filter;
@property (nonatomic, retain) NSArray *sessionsArray;
@property (nonatomic, retain) NSArray *filterNamesArray;
@property (nonatomic, retain) NSMutableDictionary *allSessionsDict;

@end
