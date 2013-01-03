//
//  SessionDetailViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/22/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "SessionDetailViewController.h"
#import "Session.h"
#import "Flurry.h"

#define FONT_SIZE 17.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation SessionDetailViewController

@synthesize presentersCount, mySceduleIsParent, sessionDict, displayedPresenters, sessionName, sessionAbstract, sessionRoom, sessionTime, twitterHandle, emailAddress, presenterTwitterHandles, presenterEmails;

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

- (void)viewDidLoad
{
	UIBarButtonItem *changeUsernameButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tweet)];
	[changeUsernameButton setImageInsets:UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f)];
	[[self navigationItem] setRightBarButtonItem:changeUsernameButton];
	
	if (mySceduleIsParent == NO) {
		UIBarButtonItem *addSession = [[UIBarButtonItem alloc] initWithTitle:@"Add Session To My Schedule" style:UIBarButtonItemStyleBordered target:self action:@selector(addSession)];
		self.toolbarItems = [NSArray arrayWithObject:addSession];
	}

	NSArray *presenters = [[NSArray alloc] initWithArray:sessionDict[@"Presenters"]];
	presentersCount = [presenters count];

	sessionName = sessionDict[@"Name"];
	sessionAbstract = sessionDict[@"Abstract"];
	
	if (sessionDict[@"Room"] == [NSNull null]) {
		sessionRoom = @"TBD";
	} else {
		sessionRoom = sessionDict[@"Room"][@"Name"];
	}
	if (sessionDict[@"Time"] == [NSNull null]) {
		sessionTime = @"Not Scheduled";
	} else {
		sessionTime = sessionDict[@"Time"][@"Name"];
	}
	
	displayedPresenters = [[NSMutableArray alloc] init];
	presenterTwitterHandles = [[NSMutableArray alloc] init];
	presenterEmails = [[NSMutableArray alloc] init];
	for (int i = 0; i < presentersCount; i++) {
		NSString *firstName = (sessionDict[@"Presenters"][i][@"FirstName"] == [NSNull null]) ? @"" : sessionDict[@"Presenters"][i][@"FirstName"];
		NSString *lastName = (sessionDict[@"Presenters"][i][@"LastName"] == [NSNull null]) ? @"" : sessionDict[@"Presenters"][i][@"LastName"];
		NSString *presenterName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		NSString *presenterEmail = (sessionDict[@"Presenters"][i][@"Email"] == [NSNull null]) ? @"" : sessionDict[@"Presenters"][i][@"Email"];
		NSString *presenterTwitter;
		if (sessionDict[@"Presenters"][i][@"TwitterHandle"] == [NSNull null] || [sessionDict[@"Presenters"][i][@"TwitterHandle"] isEqualToString:@"@"]) {
			presenterTwitter = @"";
		} else {
			presenterTwitter = sessionDict[@"Presenters"][i][@"TwitterHandle"];
		}
		[presenterEmails addObject:presenterEmail];
		[presenterTwitterHandles addObject:presenterTwitter];
		NSString *presenter = [NSString stringWithFormat:@"%@\n%@\nTwitter: %@", presenterName, presenterEmail, presenterTwitter];
		[displayedPresenters addObject:presenter];

		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:sessionName, @"sessionName", nil];
		if (mySceduleIsParent == YES) {
			[Flurry logEvent:@"SessionDetailFromMySchedule" withParameters:dictionary timed:NO];
		} else {
			[Flurry logEvent:@"SessionDetailFromSessionList" withParameters:dictionary timed:NO];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (mySceduleIsParent == YES) {
		[[self navigationController] setToolbarHidden:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[self navigationController] setToolbarHidden:NO];
}

- (Session *)addSession
{
	NSError *error;
	NSString *jsonString;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sessionDict options:0 error:&error];
	jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Session"];
	[request setEntity:e];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", sessionName];
	[request setPredicate:predicate];
	NSArray *result = [context executeFetchRequest:request error:&error];
	
	Session *ses = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:context];
	if ([result count] == 0) {
		[ses setName:sessionName];
		[ses setDictionary:jsonString];
		[allSessions addObject:ses];
		
		[self saveChanges];
		
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:sessionName, @"sessionName", nil];
		[Flurry logEvent:@"SessionAddedToSchedule" withParameters:dictionary timed:NO];
	}
	return ses;
}

- (BOOL)saveChanges
{
	NSError *err = nil;
	BOOL successful = [context save:&err];
	return successful;
}

- (IBAction)tweet
{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
			[slComposer dismissViewControllerAnimated:YES completion:nil];
		};
		
		NSMutableString *twitterHandles = [NSMutableString string];
		for (int i = 0; i < presentersCount; i++) {
			if (i > 0) [twitterHandles appendString:@" and "];
			[twitterHandles appendString:[presenterTwitterHandles objectAtIndex:i]];
		}
		
		[slComposer setInitialText:[NSString stringWithFormat:@"In session: %@ by %@ at #dcc12", sessionName, twitterHandles]];
		[slComposer setCompletionHandler:completionHandler];
		[self presentViewController:slComposer animated:YES completion:nil];
		[Flurry logEvent:@"TweetSentForSession"];
	}
}

- (IBAction)contactPresenter
{
	UIActionSheet *contactActionSheet = [[UIActionSheet alloc] initWithTitle:@"Contact Presenter" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Email Presenter", nil];
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && [twitterHandle length] > 0) {
		[contactActionSheet addButtonWithTitle:@"Tweet Presenter"];
	}
	[contactActionSheet addButtonWithTitle:@"Cancel"];
	[contactActionSheet setCancelButtonIndex:[contactActionSheet numberOfButtons] - 1];

	[contactActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[contactActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", emailAddress]]];
			[Flurry logEvent:@"EmailSentToPresenter"];
			break;
		case 1:
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && [twitterHandle length] > 0) {
				SLComposeViewController *slComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
					[slComposer dismissViewControllerAnimated:YES completion:nil];
				};
				
				[slComposer setInitialText:[NSString stringWithFormat:@"#dcc12 %@ ", twitterHandle]];
				[slComposer setCompletionHandler:completionHandler];
				[self presentViewController:slComposer animated:YES completion:nil];
				[Flurry logEvent:@"TweetSentToPresenter"];
			}
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Session:";
			break;
		case 1:
			if (presentersCount == 1) {
				return @"Presenter: (tap to contact)";
			} else {
				return @"Presenters: (tap to contact)";
			}
			break;
		case 2:
			return @"Details:";
			break;
		default:
			return nil;
			break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return presentersCount;
			break;
		case 2:
			return 2;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setNumberOfLines:0];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
	}
	
	switch ([indexPath section]) {
		case 0:
			[cell setUserInteractionEnabled:NO];
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:sessionName];
					break;
				case 1:
					[[cell textLabel] setText:sessionAbstract];
					break;
			}
			break;
		case 1:
			[cell setUserInteractionEnabled:YES];
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			[[cell textLabel] setText:[displayedPresenters objectAtIndex:[indexPath row]]];
			break;
		case 2:
			[cell setUserInteractionEnabled:NO];
			switch ([indexPath row]) {
				case 0:
					[[cell textLabel] setText:[NSString stringWithFormat:@"Room: %@", sessionRoom]];
					break;
				case 1:
					[[cell textLabel] setText:[NSString stringWithFormat:@"Time: %@", sessionTime]];
					break;
			}
			break;
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSString *text = nil;
	
	switch ([indexPath section]) {
		case 0:
			switch ([indexPath row]) {
				case 0:
					text = sessionName;
					break;
				case 1:
					text = sessionAbstract;
					break;
			}
			break;
		case 1:
			text = [displayedPresenters objectAtIndex:[indexPath row]];
			break;
		case 2:
			switch ([indexPath row]) {
				case 0:
					text = [NSString stringWithFormat:@"Room: %@", sessionRoom];
					break;
				case 1:
					text = [NSString stringWithFormat:@"Time: %@", sessionTime];
					break;
			}
			break;
	}

	CGSize frameSize = self.view.frame.size;
	CGSize constraint = CGSizeMake(frameSize.width - 20 - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];

	return size.height + (CELL_CONTENT_MARGIN * 2);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 1) {
		twitterHandle = [presenterTwitterHandles objectAtIndex:[indexPath row]];
		emailAddress = [presenterEmails objectAtIndex:[indexPath row]];
		[self contactPresenter];
	}
}

@end
