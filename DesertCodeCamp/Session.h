//
//  Session.h
//  DesertCodeCamp
//
//  Created by David Barkman on 11/1/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Session : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * dictionary;
@property (nonatomic) double orderValue;

@end
