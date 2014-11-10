//
//  Message.h
//  ChurchApp
//
//  Created by Daniel Cardona on 11/10/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * deliverDate;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSString * messageTag;
@property (nonatomic, retain) NSString * roleInGroup;
@property (nonatomic, retain) NSString * targetGroup;

@end
