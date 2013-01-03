//
//  TracksViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/21/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "TracksViewController.h"
#import "SessionsViewController.h"
#import "AboutViewController.h"
#import "Flurry.h"

#define FONT_SIZE 18.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation TracksViewController

@synthesize filterNamesArray, allSessionsDict, filterType, url;

- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		[[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil]];

		UIImage *image = [UIImage imageNamed:@"Cactus.png"];
		self.tabBarItem.image = image;
		
		[Flurry logEvent:@"AllTracks"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}

- (void)viewDidLoad
{
	[[self navigationItem] setTitle:@"Desert Code Camp"];
	
	[self fetchDesertCodeCamp];
	
	UIBarButtonItem *changeUsernameButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tweet)];
	[changeUsernameButton setImageInsets:UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f)];
	[[self navigationItem] setRightBarButtonItem:changeUsernameButton];

	UIBarButtonItem *flexiableSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutClicked)];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
	[refresh setStyle:UIBarButtonItemStyleBordered];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Tracks", @"Times", nil]];
	UIBarButtonItem *segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl setSelectedSegmentIndex:0];
	[segmentedControl addTarget:self action:@selector(filterChange:) forControlEvents:UIControlEventValueChanged];
	
	NSArray *items = [NSArray arrayWithObjects:about, flexiableSpace, segmentedControlItem, flexiableSpace, refresh, nil];
	self.toolbarItems = items;
}

- (void)filterChange:(id)sender
{
	switch ([sender selectedSegmentIndex]) {
		case 0:
			filterType = 0;
			[Flurry logEvent:@"AllTracks"];
			[self fetchDesertCodeCamp];
			break;
		case 1:
			filterType = 1;
			[Flurry logEvent:@"AllTimes"];
			[self fetchDesertCodeCamp];
			break;
	}
}

- (IBAction)tweet
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
			[slComposer dismissViewControllerAnimated:YES completion:nil];
		};
		
		[slComposer setInitialText:[NSString stringWithFormat:@"#dcc12 "]];
		[slComposer setCompletionHandler:completionHandler];
		[self presentViewController:slComposer animated:YES completion:nil];
		[Flurry logEvent:@"TweetSentForDCC12"];
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
	NSString *filter = (filterType == 0) ? @"Tracks" : @"Times";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:filter, @"filter", nil];
	[Flurry logEvent:@"RefreshAllSessions" withParameters:dictionary timed:NO];
	[self fetchDesertCodeCamp];
}

- (void)fetchDesertCodeCamp
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[Flurry logEvent:@"FetchingAllSessions" timed:YES];
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
			[Flurry endTimedEvent:@"FetchingAllSessions" withParameters:nil];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			[self.tableView reloadData];
		});
	});
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [filterNamesArray count];
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
	
	NSString *filterName = [filterNamesArray objectAtIndex:[indexPath row]];

	switch (filterType) {
		case 0:
			[[cell textLabel] setText:filterName];
			break;
		case 1:
			if (filterName == @"Not Scheduled"){
				[[cell textLabel] setText:filterName];
			} else {
				[[cell textLabel] setText:[self formatTimeFilterLabel:filterName]];
			}
			break;
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSString *filterName = [filterNamesArray objectAtIndex:[indexPath row]];
	
	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [filterName sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
	
	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SessionsViewController *sessionsViewController = [[SessionsViewController alloc] init];
	NSString *filterName = [filterNamesArray objectAtIndex:[indexPath row]];
	[sessionsViewController setFilter:(filterType == 1 && filterName != @"Not Scheduled") ? [self formatTimeFilterLabel:filterName] : filterName];
	[sessionsViewController setFilterType:filterType];
	[sessionsViewController setSessionsArray:[allSessionsDict objectForKey:filterName]];
	
	[[self navigationController] pushViewController:sessionsViewController animated:YES];
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
