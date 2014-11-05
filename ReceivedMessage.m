//
//  ReceivedMessage.m
//  ChurchApp
//
//  Created by Daniel Cardona on 11/3/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "ReceivedMessage.h"


@implementation ReceivedMessage

@dynamic showDate;
@dynamic messageContent;
@dynamic messageTag;
@dynamic fromUser;

-(NSString *)description{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/mm/yyyy hh:m a"];
    NSString* dateString = [formatter stringFromDate:self.showDate];
    NSString* description = [NSString stringWithFormat:@"%@ - from user: %@  showing on: %@",self.messageTag,self.fromUser,dateString];

    return description;
}
@end
