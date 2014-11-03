//
//  ContactsDetailViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 9/2/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "ContactsDetailViewController.h"

@interface ContactsDetailViewController ()<UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionSheetBarButton;

@end

@implementation ContactsDetailViewController

#pragma mark - Lazy instantiation 

-(UIImage *)profileImage{
    if (!_profileImage) {
        _profileImage = [[UIImage alloc]init];
    }
    
    return _profileImage;
}

-(NSString *)profileInfo{
    if(!_profileInfo) _profileInfo = [[NSString alloc]init];
    return _profileInfo;
}
-(NSString *)profileName{
    if(!_profileName) _profileName = [[NSString alloc]init];
    return _profileName;
}

-(NSString *)mailRecipient{
    if(!_mailRecipient)_mailRecipient = [[NSString alloc]init];
    return _mailRecipient;
}
#pragma mark view life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   self.profileImageView.image = self.profileImage;
    _profileInfoLabel.text = self.profileInfo;
    _profileNameLabel.text = self.profileName;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - IBActions 

- (IBAction)mailButton:(id)sender {
//    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
//        UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail",@"Call", nil];
//        
//        [actionSheet showFromBarButtonItem:_actionSheetBarButton animated:YES];
//        return;
//    }
//    
//    [self sendMail];
    
    NSString *text = @"My mail text";
    
    NSURL *recipients = [NSURL URLWithString:@"mailto:me@example.com?subject=Hi"];
    
    NSArray *activityItems = @[text, recipients];
    
    UIActivityViewController *activity = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:nil];
    
    [self.navigationController presentViewController:activity animated:YES completion:nil];
    
    
}
#pragma mark - Mail Methods

-(void)sendMail{
    MFMailComposeViewController* mailView = [[MFMailComposeViewController alloc]init];
    mailView.mailComposeDelegate = self;
    [mailView setToRecipients:@[self.mailRecipient]];
    [self presentViewController:mailView animated:YES completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [self sendMail];
    }
}
@end
