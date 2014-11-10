//
//  PendingSettingsViewController.h
//  RedilApp
//
//  Created by Daniel Cardona on 10/15/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@protocol PendingMessagesDelegate;

@interface PendingSettingsViewController : UIViewController

@property (weak,nonatomic)id<PendingMessagesDelegate> delegate;
@property (strong,nonatomic) Message* message;


@end

@protocol PendingMessagesDelegate <NSObject>

//-(void)didUpdateMessageSendDate:(NSDate*)sendDate;
//-(void)didUpdateMessage:(NSString*)message;
//-(void)didUpdateMessageTag:(NSString*)messageTag;
//-(void)didFinishSelectingtargetgroupsAndRoles:(NSArray*)info;//Array of dictionaries with keys targetGroup and roleInChurch
-(void)didSaveMessageSettings:(Message*)message;
@end
