//
//  AboutViewController.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/22/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "AboutViewController.h"
#import "Flurry.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		[[self navigationItem] setLeftBarButtonItem:doneItem];
		[[self navigationItem] setTitle:@"Desert Code Camp"];
		
		[Flurry logEvent:@"About"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	double nextY = 5.0;
	CGSize size = self.view.frame.size;
	UINavigationController *navCon = [self navigationController];
	int navHeight = navCon.navigationBar.frame.size.height;
	
	UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, (size.height - navHeight))];
	
	UITextView *dccDescription = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[dccDescription setText:@"Code Camps have been taking place all over the country. This is a free, one-day event put on by the local Phoenix community to help promote software development in general.\nThere is no right or wrong language, platform, or technology. If a topic relates in any way to the code that causes a machine to produce a desired result, it\'s welcome here."];
	[dccDescription setFont:[UIFont systemFontOfSize:15.0f]];
	[dccDescription sizeToFit];
	[dccDescription setEditable:NO];
	[scroll addSubview:dccDescription];
	[dccDescription setBackgroundColor:[UIColor clearColor]];
	nextY += dccDescription.frame.size.height;
	
	UITextView *dccCGCC = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[dccCGCC setText:@"Chandler - Gilbert Community College, Pecos Campus"];
	[dccCGCC setFont:[UIFont boldSystemFontOfSize:15.0f]];
	[dccCGCC sizeToFit];
	[dccCGCC setEditable:NO];
	[scroll addSubview:dccCGCC];
	[dccCGCC setBackgroundColor:[UIColor clearColor]];
	nextY += dccCGCC.frame.size.height - 10;
	
	UITextView *dccAddress = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[dccAddress setText:@"2626 E. Pecos Road, Chandler, AZ 85225"];
	[dccAddress setFont:[UIFont systemFontOfSize:15.0f]];
	[dccAddress sizeToFit];
	[dccAddress setEditable:NO];
	[dccAddress setDataDetectorTypes:UIDataDetectorTypeAddress];
	[scroll addSubview:dccAddress];
	[dccAddress setBackgroundColor:[UIColor clearColor]];
	nextY += dccAddress.frame.size.height - 10;
	
	UITextView *dccWhen = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[dccWhen setText:@"When: October 18, 2014 8am - 6pm"];
	[dccWhen setFont:[UIFont systemFontOfSize:15.0f]];
	[dccWhen sizeToFit];
	[dccWhen setEditable:NO];
	[dccWhen setDataDetectorTypes:UIDataDetectorTypeCalendarEvent];
	[scroll addSubview:dccWhen];
	[dccWhen setBackgroundColor:[UIColor clearColor]];
	nextY += dccWhen.frame.size.height - 10;
	
	UITextView *dccEmail = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[dccEmail setText:@"Contact Email: jguadagno@sevdnug.org"];
	[dccEmail setFont:[UIFont systemFontOfSize:15.0f]];
	[dccEmail sizeToFit];
	[dccEmail setEditable:NO];
	[dccEmail setDataDetectorTypes:UIDataDetectorTypeLink];
	[scroll addSubview:dccEmail];
	[dccEmail setBackgroundColor:[UIColor clearColor]];
	nextY += dccEmail.frame.size.height;
	
	UITextView *appDevBy = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[appDevBy setText:@"App Developed By:"];
	[appDevBy setFont:[UIFont boldSystemFontOfSize:15.0f]];
	[appDevBy sizeToFit];
	[appDevBy setEditable:NO];
	[scroll addSubview:appDevBy];
	[appDevBy setBackgroundColor:[UIColor clearColor]];
	nextY += appDevBy.frame.size.height - 10;
	
	UITextView *rsaTitle = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[rsaTitle setText:@"David Barkman @ RealSimpleApps"];
	[rsaTitle setFont:[UIFont systemFontOfSize:15.0f]];
	[rsaTitle sizeToFit];
	[rsaTitle setEditable:NO];
	[scroll addSubview:rsaTitle];
	[rsaTitle setBackgroundColor:[UIColor clearColor]];
	nextY += rsaTitle.frame.size.height - 10;
	
	UITextView *rsaWeb = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[rsaWeb setText:@"realsimpleapps.com @realSimpleApps"];
	[rsaWeb setFont:[UIFont systemFontOfSize:15.0f]];
	[rsaWeb sizeToFit];
	[rsaWeb setEditable:NO];
	[rsaWeb setDataDetectorTypes:UIDataDetectorTypeLink];
	[scroll addSubview:rsaWeb];
	[rsaWeb setBackgroundColor:[UIColor clearColor]];
	nextY += rsaWeb.frame.size.height - 10;
	
	UITextView *rsaEmail = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, nextY, size.width - 20.0f, (size.height - navHeight))];
	[rsaEmail setText:@"david.barkman13@gmail.com @cybler"];
	[rsaEmail setFont:[UIFont systemFontOfSize:15.0f]];
	[rsaEmail sizeToFit];
	[rsaEmail setEditable:NO];
	[rsaEmail setDataDetectorTypes:UIDataDetectorTypeLink];
	[scroll addSubview:rsaEmail];
	[rsaEmail setBackgroundColor:[UIColor clearColor]];
	nextY += rsaEmail.frame.size.height;
	
	
	[scroll setContentSize:CGSizeMake(scroll.contentSize.width, nextY)];
	[self.view addSubview:scroll];
}

- (IBAction)done
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
