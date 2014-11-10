//
//  Message.h
//  ChurchApp
//
//  Created by Daniel Cardona on 11/3/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//Testing xcode github 

//TODO: simplify to have only one target group

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * deliverDate;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSString * messageTag;
@property (nonatomic, retain) id targetGroups;

@end
