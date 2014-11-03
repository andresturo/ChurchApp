//
//  EditPendingMessageViewController.h
//  RedilApp
//
//  Created by Daniel Cardona on 10/15/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@protocol EditPendingMessageDelegate;

@interface EditPendingMessageViewController : UIViewController

@property (weak,nonatomic) id<EditPendingMessageDelegate> delegate;
@property (strong,nonatomic) Message* message;


@end


@protocol EditPendingMessageDelegate <NSObject>

@required
-(void)didEndEditingMessage:(Message*)message;
-(void)didFinishEditingTag:(NSString*)messageTag;

@end