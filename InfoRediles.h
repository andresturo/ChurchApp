//
//  InfoRediles.h
//  RedilApp
//
//  Created by Daniel Cardona on 9/12/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol InfoRedilesDelegate;

@interface InfoRediles : NSObject

@property id <InfoRedilesDelegate> delegate;

//-(NSArray*)contactsInfoArray;
//-(NSArray*)sedesInfoArray;
-(NSArray*) contactsInfoArrayUsingRemoteJSON;
-(NSArray*) sedesInfoArrayUsingRemoteJSON;
-(NSArray*) sedesInfoArrayUsingLocalPlist;
-(NSArray*) contactsInfoArrayUsingLocalPlist;

-(void) saveContactsJsonFile;
-(void) saveSedesJsonFile;

@end

@protocol InfoRedilesDelegate <NSObject>
@optional
-(BOOL)shouldSortContacts;
-(BOOL)shouldSortSedes;

@end
