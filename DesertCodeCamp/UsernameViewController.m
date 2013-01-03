//
//  UsernameViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/30/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "UsernameViewController.h"
#import "Flurry.h"

@implementation UsernameViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
		[[self navigationItem] setLeftBarButtonItem:cancel];
		UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
		[[self navigationItem] setRightBarButtonItem:save];
		
		[Flurry logEvent:@"Username"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
	[usernameTextField becomeFirstResponder];
	[usernameTextField setText:login];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[Flurry logEvent:@"Username Entry Saved With Done"];

	if ([delegate respondsToSelector:@selector(usernameEntered:)]) {
		[delegate usernameEntered:[usernameTextField text]];
	}
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
	return YES;
}

- (IBAction)cancel
{
	[usernameTextField resignFirstResponder];
	[Flurry logEvent:@"Username Entry Canceled"];
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save
{
	[usernameTextField resignFirstResponder];
	[Flurry logEvent:@"Username Entry Saved With Save"];
	
	if ([delegate respondsToSelector:@selector(usernameEntered:)]) {
		[delegate usernameEntered:[usernameTextField text]];
	}
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
