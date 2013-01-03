//
//  MyScheduleViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/29/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "MyScheduleViewController.h"
#import "AboutViewController.h"
#import "SessionDetailViewController.h"
#import "Session.h"
#import "Flurry.h"

#define FONT_SIZE 17.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation MyScheduleViewController

@synthesize message, filterNamesArray, allSessionsDict, masterSessionObjectsDict;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		model = [NSManagedObjectModel mergedModelFromBundles:nil];

		NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

		NSString *path = [self itemArchivePath];
		NSURL *storageURL = [NSURL fileURLWithPath:path];

		NSError *error = nil;

		[psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storageURL options:nil error:&error];

		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:psc];
		[context setUndoManager:nil];

		
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
		
		UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutClicked)];
		NSArray *items = [NSArray arrayWithObject:about];
		self.toolbarItems = items;
		
		UIImage *image = [UIImage imageNamed:@"Watch.png"];
		self.tabBarItem.image = image;
		
		UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTable)];
		[[self navigationItem] setRightBarButtonItem:edit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (NSString *)itemArchivePath
{
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"DesertCodeCamp.sqlite"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self loadAllSessions];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if ([self isEditing]) {
		[self doneEditTable];
	}
}

- (void)loadAllSessions
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Session"];
	[request setEntity:e];
	
	NSError *error;
	NSArray *result = [context executeFetchRequest:request error:&error];
	
	allSessions = [[NSMutableArray alloc] initWithArray:result];
	
	[self parseAllSessions];
}

- (void)parseAllSessions
{
	allSessionsDict = [[NSMutableDictionary alloc] init];
	masterSessionObjectsDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tempFilterNamesArray = [[NSMutableArray alloc] init];
	
	NSError *error;
	int sessionCount = [allSessions count];
	for (int i = 0; i < sessionCount; i++) {
		Session *session = [allSessions objectAtIndex:i];
		[masterSessionObjectsDict setObject:session forKey:[session name]];
		NSString *sessionString = [session dictionary];
		NSDictionary *sessionDict = [NSJSONSerialization JSONObjectWithData:[sessionString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
		
		NSString *filterName;
		if (sessionDict[@"Time"] == [NSNull null]) {
			filterName = @"Not Scheduled";
		} else {
			filterName = sessionDict[@"Time"][@"Name"];
			NSString *startDate = sessionDict[@"Time"][@"StartDate"];
			NSString *endDate = sessionDict[@"Time"][@"EndDate"];
			NSRange range = NSMakeRange (6, 10);
			NSString *unixStartDate = [startDate substringWithRange:range];
			NSString *unixEndDate = [endDate substringWithRange:range];
			filterName = [NSString stringWithFormat:@"%@-%@", unixStartDate, unixEndDate];
		}
		
		if (![tempFilterNamesArray containsObject:filterName]) {
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray addObject:sessionDict];
			[allSessionsDict setObject:tempArray forKey:filterName];
			
			[tempFilterNamesArray addObject:filterName];
		} else {
			NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[allSessionsDict objectForKey:filterName]];
			[allSessionsDict removeObjectForKey:filterName];
			[tempArray addObject:sessionDict];
			[allSessionsDict setObject:tempArray forKey:filterName];
		}
	}
	
	filterNamesArray = [NSMutableArray arrayWithArray:[tempFilterNamesArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	
	if ([filterNamesArray count] == 0) {
		[Flurry logEvent:@"MyScheduleEmpty"];
		message = @"This screen is used to manage your schedule for sessions you might want to attend at Desert Code Camp. To add sessions to your schedule, go to the All Sessions or My Sessions tab and navigate into the details of a session.  Once in the session details, tap the \"Add Session To My Schedule\" button. Then return to this screen to view you selected sessions by time.";
		
		[filterNamesArray addObject:@""];
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:message forKey:@"Name"];
		NSArray *tempArray = [NSArray arrayWithObject:tempDict];
		[allSessionsDict setObject:tempArray forKey:@""];
	} else {
		[Flurry logEvent:@"MySchedule"];
	}
	
	[self.tableView reloadData];
}

- (IBAction)aboutClicked
{
	AboutViewController *aboutViewController = [[AboutViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
	
	NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"dccOrange"];
	UIColor *dccOrange = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
	
	[[navController navigationBar] setTintColor:dccOrange];
	[navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	
	[self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)editTable
{
	UIBarButtonItem *edit = [[self navigationItem] rightBarButtonItem];
	[edit setTitle:@"Done"];
	[edit setAction:@selector(doneEditTable)];
	
	[self setEditing:YES animated:YES];
}

- (IBAction)doneEditTable
{
	UIBarButtonItem *done = [[self navigationItem] rightBarButtonItem];
	[done setTitle:@"Edit"];
	[done setAction:@selector(editTable)];
	
	[self setEditing:NO animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [filterNamesArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *filterName = [filterNamesArray objectAtIndex:section];
	if (filterName == @"Not Scheduled"){
		return filterName;
	} else if ([filterName length] == 0) {
		return filterName;
	} else {
		return [self formatTimeFilterLabel:filterName];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *tempArray = [allSessionsDict objectForKey:[filterNamesArray objectAtIndex:section]];
	return [tempArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
	}
	
	NSArray *tempArray = [allSessionsDict objectForKey:[filterNamesArray objectAtIndex:[indexPath section]]];
	NSDictionary *tempDict = [tempArray objectAtIndex:[indexPath row]];
	
	NSString *sessionName = tempDict[@"Name"];
	if (sessionName == message) {
		[cell setUserInteractionEnabled:NO];
	} else {
		[cell setUserInteractionEnabled:YES];
	}

	[[cell textLabel] setText:sessionName];
	
	return cell;
}

- (void)tableView:(UITableView *) tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *tempArray = [allSessionsDict objectForKey:[filterNamesArray objectAtIndex:[indexPath section]]];
		[allSessionsDict removeObjectForKey:[filterNamesArray objectAtIndex:[indexPath section]]];
		NSDictionary *sessionDict = [tempArray objectAtIndex:[indexPath row]];
		NSString *sessionName = sessionDict[@"Name"];
		[tempArray removeObjectAtIndex:[indexPath row]];
		if ([tempArray count] == 0) {
			[filterNamesArray removeObjectAtIndex:[indexPath section]];
		} else {
			[allSessionsDict setObject:tempArray forKey:[filterNamesArray objectAtIndex:[indexPath section]]];
		}
		
		[context deleteObject:[masterSessionObjectsDict objectForKey:sessionName]];
		[self saveChanges];
		
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:sessionName, @"sessionName", nil];
		[Flurry logEvent:@"SessionRemovedFromSchedule" withParameters:dictionary timed:NO];
		
		[tableView beginUpdates];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		if ([tempArray count] == 0) [tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:YES];
		[tableView endUpdates];
		
		[tableView reloadData];
	}
}

- (BOOL)saveChanges
{
	NSError *err = nil;
	BOOL successful = [context save:&err];
	return successful;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSArray *tempArray = [allSessionsDict objectForKey:[filterNamesArray objectAtIndex:[indexPath section]]];
	NSDictionary *tempDict = [tempArray objectAtIndex:[indexPath row]];
	NSString *sessionName = tempDict[@"Name"];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [sessionName sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SessionDetailViewController *sessionDetailViewController = [[SessionDetailViewController alloc] init];
	NSArray *tempArray = [allSessionsDict objectForKey:[filterNamesArray objectAtIndex:[indexPath section]]];
	[sessionDetailViewController setSessionDict:[tempArray objectAtIndex:[indexPath row]]];
	[sessionDetailViewController setMySceduleIsParent:YES];
	[[self navigationController] pushViewController:sessionDetailViewController animated:YES];
}

- (NSString *)formatTimeFilterLabel:(NSString *)filterName
{
	NSRange startDateRange = NSMakeRange (0, 10);
	NSRange endDateRange = NSMakeRange (11, 10);
	
	NSString *startTime = [filterName substringWithRange:startDateRange];
	NSString *endtime = [filterName substringWithRange:endDateRange];
	
	NSString *start = [self unixTimestampToString:startTime];
	NSString *end = [self unixTimestampToString:endtime];
	
	return [NSString stringWithFormat:@"%@ - %@", start, end];
}

- (NSString *)unixTimestampToString:(NSString *)filterName
{
	NSString *meridiem = @"am";
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[filterName doubleValue]];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
	[calendar setTimeZone:timeZone];
	NSDateComponents *comps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
	
	NSInteger hour = ([comps hour] > 12) ? [comps hour] - 12 : [comps hour];
	NSString *minute = ([comps minute] == 0) ? [NSString stringWithFormat:@"00"] : [NSString stringWithFormat:@"%i", [comps minute]];
	if ([comps hour] >= 12) meridiem = @"pm";
	
	return [NSString stringWithFormat:@"%i:%@%@", hour, minute, meridiem];
}

@end
