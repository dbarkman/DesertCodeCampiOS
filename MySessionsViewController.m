//
//  MySessionsViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/29/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "MySessionsViewController.h"
#import "SessionDetailViewController.h"
#import "AboutViewController.h"
#import "UsernameViewController.h"
#import "Flurry.h"

#define FONT_SIZE 18.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation MySessionsViewController

@synthesize filterType, url, message, filterNamesArray, allSessionsDict;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];
		
		UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutClicked)];
		NSArray *items = [NSArray arrayWithObject:about];
		self.toolbarItems = items;
		
		UIImage *image = [UIImage imageNamed:@"IM.png"];
		self.tabBarItem.image = image;

		[Flurry logEvent:@"MyInterestedSessions"];
	}
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (void)viewDidLoad
{
	[[self navigationItem] setTitle:@"My Sessions"];
	
	[self buildView];
}

- (void)buildView
{
	NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
	if (login == nil || [login length] == 0) {
		[Flurry logEvent:@"No Username Set"];
		
		[self buildToolbar:NO];
		
		if ([[self navigationItem] rightBarButtonItem]) [[self navigationItem] setRightBarButtonItem:nil];
		
		message = @"This screen will display sessions you've marked as Interested on the DesertCodeCamp.com website and sessions you've volunteered to present. In order to view those sessions, please tap the Enter Login button below and enter your DesertCodeCamp.com login on the next screen.";

		filterNamesArray = [NSArray arrayWithObject:@""];
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
		[tempDict setObject:message forKey:@"Name"];
		NSArray *tempArray = [NSArray arrayWithObject:tempDict];
		allSessionsDict = [[NSMutableDictionary alloc] init];
		[allSessionsDict setObject:tempArray forKey:@""];
		
		[self.tableView reloadData];

	} else {
		[Flurry logEvent:@"Username Set"];
		
		UIBarButtonItem *changeUsernameButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Person.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(enterUsername)];
		[changeUsernameButton setImageInsets:UIEdgeInsetsMake(4.0f, 0.0f, 4.0f, 0.0f)];
		[[self navigationItem] setRightBarButtonItem:changeUsernameButton];
		
		[self buildToolbar:YES];
		
		NSString *shortName = [[NSUserDefaults standardUserDefaults] objectForKey:@"shortName"];
		NSString *getMyInterestedInSessionsByLoginURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"getMyInterestedInSessionsByLoginURL"];
		url = [NSString stringWithFormat:getMyInterestedInSessionsByLoginURL, login, shortName];

		[self fetchDesertCodeCamp];
	}
}

- (void)buildToolbar:(BOOL)displayAll
{
	UIBarButtonItem *flexiableSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *enterUsername = [[UIBarButtonItem alloc] initWithTitle:@"Enter Login" style:UIBarButtonItemStyleBordered target:self action:@selector(enterUsername)];
	UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutClicked)];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Interested", @"Presenting", nil]];
	UIBarButtonItem *segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl setSelectedSegmentIndex:0];
	[segmentedControl addTarget:self action:@selector(filterChange:) forControlEvents:UIControlEventValueChanged];
	
	NSArray *items;
	if (displayAll == YES) {
		items = [NSArray arrayWithObjects:about, flexiableSpace, segmentedControlItem, flexiableSpace, refresh, nil];
	} else {
		items = [NSArray arrayWithObjects:about, flexiableSpace, enterUsername, nil];
	}
	self.toolbarItems = items;
}

- (IBAction)enterUsername
{
	[Flurry logEvent:@"Entering Username"];
	
	UsernameViewController *usernameViewController = [[UsernameViewController alloc] init];
	usernameViewController.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:usernameViewController];
	
	NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"dccOrange"];
	UIColor *dccOrange = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
	
	[[navController navigationBar] setTintColor:dccOrange];
	[navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)usernameEntered:(NSString *)username
{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"login"];
	if ([username length] > 0) {
		[Flurry logEvent:@"Username Saved"];
	} else {
		[Flurry logEvent:@"Blank Username Saved"];
	}
	[self buildView];
}

- (void)filterChange:(id)sender
{
	NSString *getMyPresentationsByLoginURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"getMyPresentationsByLoginURL"];
	NSString *getMyInterestedInSessionsByLoginURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"getMyInterestedInSessionsByLoginURL"];
	NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
	NSString *shortName = [[NSUserDefaults standardUserDefaults] objectForKey:@"shortName"];
	switch ([sender selectedSegmentIndex]) {
		case 0:
			url = [NSString stringWithFormat:getMyInterestedInSessionsByLoginURL, login, shortName];
			filterType = 0;
			[Flurry logEvent:@"MyInterestedSessions"];
			[self fetchDesertCodeCamp];
			break;
		case 1:
			url = [NSString stringWithFormat:getMyPresentationsByLoginURL, login, shortName];
			filterType = 1;
			[Flurry logEvent:@"MyPresentingSessions"];
			[self fetchDesertCodeCamp];
			break;
	}
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

- (IBAction)refreshClicked
{
	NSString *filter = (filterType == 0) ? @"Interested" : @"Presenting";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:filter, @"filter", nil];
	[Flurry logEvent:@"RefreshMySessions" withParameters:dictionary timed:NO];
	[self fetchDesertCodeCamp];
}

- (void)fetchDesertCodeCamp
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (filterType == 0) {
			[Flurry logEvent:@"FetchingMyInterestedSessions" timed:YES];
		} else if (filterType == 1) {
			[Flurry logEvent:@"FetchingMyPresentingSessions" timed:YES];
		}

		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		NSData *dccData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
		
		NSArray *json = nil;
		if (dccData) {
			json = [NSJSONSerialization JSONObjectWithData:dccData options:0 error:nil];
			
			@try {
				allSessionsDict = [[NSMutableDictionary alloc] init];
				NSMutableArray *tempFilterNamesArray = [[NSMutableArray alloc] init];
				
				int jsonCount = [json count];
				for (int i = 0; i < jsonCount; i++) {
					NSMutableDictionary *tempDict = json[i];
					NSNumber *isApproved = (NSNumber *)[tempDict objectForKey:@"IsApproved"];
					if (isApproved && [isApproved boolValue] == NO) continue;
					
					NSString *filterName;
					switch (filterType) {
						case 0:
							filterName = tempDict[@"Track"][@"Name"];
							break;
						case 1:
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
			@catch (NSException *exception) {
				[[[UIAlertView alloc] initWithTitle:@"Problem Parsing\nSession Data" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
			}
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (filterType == 0) {
				[Flurry endTimedEvent:@"FetchingMyInterestedSessions" withParameters:nil];
				if ([filterNamesArray count] > 0) {
					NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[filterNamesArray count]] forKey:@"count"];
					[Flurry logEvent:@"InterestedSessionsCount" withParameters:dictionary timed:NO];
				}
			} else if (filterType == 1) {
				[Flurry endTimedEvent:@"FetchingMyPresentingSessions" withParameters:nil];
				if ([filterNamesArray count] > 0) {
					NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[filterNamesArray count]] forKey:@"count"];
					[Flurry logEvent:@"PresentingSessionsCount" withParameters:dictionary timed:NO];
				}
			}
			if ([filterNamesArray count] > 0) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			} else {
				[self displayNoDataMessage];
			}
			[self.tableView reloadData];
		});
	});
}

- (void)displayNoDataMessage
{
	switch (filterType) {
		case 0:
			message = @"This screen will display sessions you've marked as Interested on the DesertCodeCamp.com website. In order to mark sessions as Interested,  log in to your account, or create a new account, at DesertCodeCamp.com. When viewing the list of sessions, click the \"More Info\" button, review the session, and if interested, check \"I might attend\" and click \"Save\". Once you've marked some sessions as Interested, return here and tap the Refresh button.";
			
			[Flurry logEvent:@"No Interested Session Data"];
			break;
		case 1:
			message = @"This screen will display sessions you've volunteered to present. The April 2013 camp is no longer taking new sessions, but some sessions still need presenters. In order to volunteer to present a session, log in to your account, or create a new account, at DesertCodeCamp.com. When viewing the list of sessions, look for sessions marked with the \"Needs a Presenter\" icon. Click the \"More Info\" button, review the session, and if interested, check \"Teach This\" and click \"Save\". A Desert Code Camp coordinator will then contact you.";
			
			[Flurry logEvent:@"No Presenting Session Data"];
			break;
	}
	
	filterNamesArray = [NSArray arrayWithObject:@""];
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
	[tempDict setObject:message forKey:@"Name"];
	NSArray *tempArray = [NSArray arrayWithObject:tempDict];
	allSessionsDict = [[NSMutableDictionary alloc] init];
	[allSessionsDict setObject:tempArray forKey:@""];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self.tableView reloadData];
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
			return filterName;
			break;
		case 1:
			if (filterName == @"Not Scheduled"){
				return filterName;
			} else if ([filterName length] == 0) {
				return filterName;
			} else {
				return [self formatTimeFilterLabel:filterName];
			}
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
	if (sessionName == message) {
		[cell setUserInteractionEnabled:NO];
	} else {
		[cell setUserInteractionEnabled:YES];
	}

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
