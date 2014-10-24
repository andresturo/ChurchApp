//
//  ContactsDetailViewController.h
//  RedilApp
//
//  Created by Daniel Cardona on 9/2/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MapViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactsDetailViewController : ViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;


@property (strong,nonatomic) NSString* mailRecipient;
@property NSString* imageName;
@property (strong,nonatomic) UIImage* profileImage;
@property (strong,nonatomic) NSString* profileInfo;
@property (strong,nonatomic) NSString* profileName;

- (IBAction)mailButton:(id)sender;

@end
