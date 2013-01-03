//
//  UsernameViewController.h
//  DesertCodeCamp
//
//  Created by David Barkman on 10/30/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UsernameDelegate <NSObject>

- (void)usernameEntered:(NSString *)username;

@end

@interface UsernameViewController : UIViewController
{
	IBOutlet UITextField *usernameTextField;
	
	__weak id <UsernameDelegate> delegate;
}

- (IBAction)save;

@property (nonatomic, weak)id <UsernameDelegate> delegate;

@end
