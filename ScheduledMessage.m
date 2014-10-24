//
//  ScheduledMessage.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/21/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "ScheduledMessage.h"
@interface ScheduledMessage()
    
    


@end

@implementation ScheduledMessage
-(id)init{
    
    return [self initWithMessageTag:@"Set Message Tag" andDeliverDate:[NSDate date]];
}

-(id)initWithMessageTag:(NSString*)messageTag andDeliverDate:(NSDate*)date{
    
    self = [super init];
    
    if (self) {
        self.messageTag = messageTag;
        self.deliverDate = date;
        self.dateFormat = @"dd/mm/yyyy";
        [self dateToString];
        self.targetsAndRoles = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(id)initWithMessageTag:(NSString *)messageTag{
    
    return [self initWithMessageTag:messageTag andDeliverDate:[NSDate date]];
}

-(NSString *)messageDateString{
    if (_deliverDate) {
        [self dateToString];

    }else {
        _messageDateString = [[NSString alloc]init];
    }
    return _messageDateString;
}

+(ScheduledMessage *)scheduledMessageWithTag:(NSString *)title andDeliverDate:(NSDate *)date{
    
    ScheduledMessage* newScheduledMessage = [[ScheduledMessage alloc]init];
    
    newScheduledMessage.messageTag = title;
    newScheduledMessage.deliverDate = date;
    
    return newScheduledMessage;
}

-(void)dateStringWithFormat:(NSString*)dateFormat{
   
    self.dateFormat = dateFormat;
    

}

-(void)dateToString{
    
    NSString* stringFromDate = @"Set Deliver Date";

    if (self.deliverDate) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:self.dateFormat];//@"dd/mm/yyyy"
        
        stringFromDate = [formatter stringFromDate:self.deliverDate];
    }
    
    self.messageDateString =stringFromDate;
    
}

#pragma  mark - Manage Targets and Roles
-(void)addTargetGroup:(NSString *)targeGroup WithRole:(NSString *)role{

    //TODO: Do not add the save targetGroup more then once
    NSDictionary* dictionary = @{@"targetGroup": targeGroup,@"roleInChurch":role};
    
    if (![self targetsContainDictionary:dictionary]) {
        [_targetsAndRoles addObject:dictionary];//Do I have to subclass dictionary and override isEqual?

    }
    
}

-(BOOL)targetsContainDictionary:(NSDictionary*)dictionary{
    
    
//    BOOL isContainedInArray =NO;
//    for (NSDictionary* dict in self.targetsAndRoles) {
//        if([dict[@"targetGroup"]isEqualToString:dictionary[@"targetGroup"]]){
//            isContainedInArray = YES;
//            break;
//        }
//    }
    
    BOOL isContainedInArray = [self.targetsAndRoles containsObject:dictionary];
    
    return isContainedInArray;
}

-(NSInteger)indexForTarget:(NSDictionary*)targetAndRole{
    
    NSInteger index = 0;
    
    for (NSDictionary* dict in self.targetsAndRoles) {
        index++;
        if([dict[@"targetGroup"]isEqualToString:targetAndRole[@"targetGroup"]]){
            break;
        }
    }
    return index;
}

-(NSInteger)indexForTargetGroupNamed:(NSString*)name{
    
 
    NSInteger index = 0;
    
    for (NSDictionary* dict in self.targetsAndRoles) {
        index++;
        if([dict[@"targetGroup"]isEqualToString:name]){
            break;
        }
    }
    return index;
}

-(void)addTargetGroups:(NSArray *)targets andRoles:(NSArray *)roles{
    
    if (targets.count == roles.count) {
        for (NSInteger i =0 ; i <targets.count; i++) {
            [self addTargetGroup:targets[i] WithRole:roles[i]];
        }
    }else{
        
        NSLog(@"Not all target groups have an assigned role, not even nil");
    }
}

-(void)removeTargetGroupAndRole:(NSDictionary*)targetAndRole{
    
    NSInteger indexForTarget = [self indexForTarget:targetAndRole];
    
    [self.targetsAndRoles removeObjectAtIndex:indexForTarget];
    
}

-(void)removeTargetGroupWithName:(NSString*)name{
    NSInteger index = [self indexForTargetGroupNamed:name];
    if (index > 0 && index < self.targetsAndRoles.count) {
        [self.targetsAndRoles removeObjectAtIndex:index];

    }
    
}

#pragma mark - NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super init];
    
    if (self) {
        self.messageTag = [aDecoder decodeObjectForKey:@"messageTag"];
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.deliverDate = [aDecoder decodeObjectForKey:@"deliverDate"];
        self.messageDateString = [aDecoder decodeObjectForKey:@"dateString"];
        self.targetsAndRoles = [aDecoder decodeObjectForKey:@"targetsAndRoles"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.messageTag forKey:@"messageTag"];
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.deliverDate forKey:@"deliverDate"];
    [aCoder encodeObject:self.messageDateString forKey:@"dateString"];
    [aCoder encodeObject:self.targetsAndRoles forKey:@"targetsAndRoles"];
}

#pragma mark - NSObject 


@end
