//
//  User.h
//  RedilApp
//
//  Created by Daniel Cardona on 10/9/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * attendingChurch;
@property (nonatomic, retain) NSString * roleInChurch;
@property (nonatomic, retain) NSString * email;

@end
