//
//  Message.m
//  ChurchApp
//
//  Created by Daniel Cardona on 11/3/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "Message.h"


@implementation Message

@dynamic deliverDate;
@dynamic messageContent;
@dynamic messageTag;
@dynamic targetGroups;

-(NSString *)description{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/mm/yyyy hh:m a"];
    NSString* dateString = [formatter stringFromDate:self.deliverDate];
    NSString* description = [NSString stringWithFormat:@"%@ scheduled for: %@",self.messageTag,dateString];
    
    return description;
}

@end
