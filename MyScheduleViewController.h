//
//  MyScheduleViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/29/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MyScheduleViewController : UITableViewController
{
	NSMutableArray *allSessions;
	NSManagedObjectContext *context;
	NSManagedObjectModel *model;
}

- (void) loadAllSessions;

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSMutableArray *filterNamesArray;
@property (nonatomic, retain) NSMutableDictionary *allSessionsDict;
@property (nonatomic, retain) NSMutableDictionary *masterSessionObjectsDict;

@end
