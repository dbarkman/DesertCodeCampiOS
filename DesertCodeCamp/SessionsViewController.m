//
//  SessionsViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/21/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "SessionsViewController.h"
#import "SessionDetailViewController.h"
#import "AboutViewController.h"
#import "Flurry.h"

#define FONT_SIZE 18.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation SessionsViewController

@synthesize filterType, sessionNamesArray, filter, sessionsArray, filterNamesArray, allSessionsDict;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];

		UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutClicked)];
		
		NSArray *items = [NSArray arrayWithObject:about];
		self.toolbarItems = items;
	}
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[self navigationItem] setTitle:filter];
	
	if (filterType == 0) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:filter, @"for", nil];
		[Flurry logEvent:@"SessionsListForTrackByTime" withParameters:dictionary timed:NO];
	} else if (filterType == 1) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:filter, @"for", nil];
		[Flurry logEvent:@"SessionsListForTimeByTrack" withParameters:dictionary timed:NO];
	}
}

- (void)viewDidLoad
{
	[self parseSessionsArray];
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

- (void)parseSessionsArray
{
	allSessionsDict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tempFilterNamesArray = [[NSMutableArray alloc] init];
	
	int sessionsCount = [sessionsArray count];
	for (int i = 0; i < sessionsCount; i++) {
		NSDictionary *tempDict = [sessionsArray objectAtIndex:i];
		
		NSString *filterName;
		switch (filterType) {
			case 0:
				if (tempDict[@"Time"] == [NSNull null]) {
					filterName = @"Not Scheduled";
				} else {
					filterName = tempDict[@"Time"][@"Name"];
					NSString *startDate = tempDict[@"Time"][@"StartDate"];
					NSString *endDate = tempDict[@"Time"][@"EndDate"];
					NSRange range = NSMakeRange (6, 10);
					NSString *unixStartDate = [startDate substringWithRange:range];
					NSString *unixEndDate = [endDate substringWithRange:range];
					filterName = [NSString stringWithFormat:@"%@-%@", unixStartDate, unixEndDate];
				}
				break;
			case 1:
				filterName = tempDict[@"Track"][@"Name"];
				break;
		}
		if (![tempFilterNamesArray containsObject:filterName]) {
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray addObject:tempDict];
			[allSessionsDict setObject:tempArray forKey:filterName];
			
			[tempFilterNamesArray addObject:filterName];
		} else {
			NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[allSessionsDict objectForKey:filterName]];
			[allSessionsDict removeObjectForKey:filterName];
			[tempArray addObject:tempDict];
			[allSessionsDict setObject:tempArray forKey:filterName];
		}
	}
	filterNamesArray = [tempFilterNamesArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [filterNamesArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *filterName = [filterNamesArray objectAtIndex:section];
	switch (filterType) {
		case 0:
			if (filterName == @"Not Scheduled"){
				return filterName;
			} else {
				return [self formatTimeFilterLabel:filterName];
			}
			break;
		case 1:
			return filterName;
			break;
		default:
			return @"";
			break;
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
	[[cell textLabel] setText:sessionName];
	
	return cell;
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
