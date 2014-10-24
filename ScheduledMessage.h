//
//  ScheduledMessage.h
//  RedilApp
//
//  Created by Daniel Cardona on 10/21/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
//TODO: Use keys for accesing target or role of ScheduledMessage (extern keys)

@interface ScheduledMessage : NSObject <NSCoding>

@property (strong,nonatomic) NSDate* deliverDate;
@property (strong,nonatomic) NSString* messageTag;
@property (strong,nonatomic) NSString* dateFormat;
@property (strong,nonatomic) NSString* messageDateString;
@property (strong,nonatomic) NSString* message;
@property (strong,nonatomic) NSMutableArray* targetsAndRoles;



+(ScheduledMessage*)scheduledMessageWithTag:(NSString *)title andDeliverDate:(NSString*)subtitle;
-(id)init;
-(id)initWithMessageTag:(NSString*)messageTag andDeliverDate:(NSDate*)date;
-(id)initWithMessageTag:(NSString *)messageTag;
-(void)dateStringWithFormat:(NSString*)dateFormat;
-(void)addTargetGroup:(NSString*)targeGroup WithRole:(NSString*)role;
-(void)addTargetGroups:(NSArray*)targets andRoles:(NSArray*)roles;
-(void)removeTargetGroupAndRole:(NSDictionary*)targetAndRole;
-(void)removeTargetGroupWithName:(NSString*)name;


@end
