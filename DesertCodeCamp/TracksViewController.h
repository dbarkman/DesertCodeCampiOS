//
//  TracksViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/21/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface TracksViewController : UITableViewController

- (IBAction)aboutClicked;
- (IBAction)refreshClicked;

@property (nonatomic) int filterType;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *filterNamesArray;
@property (nonatomic, retain) NSMutableDictionary *allSessionsDict;

@end
