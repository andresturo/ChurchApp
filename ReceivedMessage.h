//
//  ReceivedMessage.h
//  ChurchApp
//
//  Created by Daniel Cardona on 11/3/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReceivedMessage : NSManagedObject

@property (nonatomic, retain) NSDate * showDate;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSString * messageTag;
@property (nonatomic, retain) NSString * fromUser;

@end
