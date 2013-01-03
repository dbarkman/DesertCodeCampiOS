//
//  SessionDetailViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/22/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Social/Social.h>

@interface SessionDetailViewController : UITableViewController <UIActionSheetDelegate>
{
	NSMutableArray *allSessions;
	NSManagedObjectContext *context;
	NSManagedObjectModel *model;
}

@property (nonatomic) int presentersCount;
@property (nonatomic) BOOL mySceduleIsParent;
@property (nonatomic, retain) NSDictionary *sessionDict;
@property (nonatomic, retain) NSMutableArray *displayedPresenters;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSString *sessionAbstract;
@property (nonatomic, retain) NSString *sessionRoom;
@property (nonatomic, retain) NSString *sessionTime;
@property (nonatomic, retain) NSString *twitterHandle;
@property (nonatomic, retain) NSString *emailAddress;
@property (nonatomic, retain) NSMutableArray *presenterTwitterHandles;
@property (nonatomic, retain) NSMutableArray *presenterEmails;

- (IBAction)contactPresenter;

@end
