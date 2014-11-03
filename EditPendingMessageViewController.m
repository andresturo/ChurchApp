//
//  EditPendingMessageViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/15/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "EditPendingMessageViewController.h"

@interface EditPendingMessageViewController () < UITextViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UITextField *messageTagTextField;

@end

@implementation EditPendingMessageViewController

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
    // Do any additional setup after loading the view.
    
    self.messageTagTextField.text = self.message.messageTag;
    self.messageTextView.text = self.message.messageContent;
    self.messageTagTextField.delegate = self;
    self.messageTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    [self.delegate didEndEditingMessage:textView.text];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.text.length > 0 ) {
        self.message.messageTag = textField.text;
        [self.delegate didFinishEditingTag:textField.text];
    }else {
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Empty Message" message:@"Please enter a non empty message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
