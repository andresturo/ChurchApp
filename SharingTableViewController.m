//
//  SharingTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/1/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "SharingTableViewController.h"
#import "DetailSharedMessageViewController.h"


@interface SharingTableViewController () <UIAlertViewDelegate>
@property (strong,nonatomic) NSArray* sharingActivities;
@property (nonatomic) NSInteger selectedCellIndex;
@end

@implementation SharingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
 
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    PFQuery* queryForSharingActivities = [PFQuery queryWithClassName:@"Sharing"];
    [queryForSharingActivities findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.sharingActivities = objects;
        [self.tableView reloadData];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.destinationViewController isKindOfClass:[DetailSharedMessageViewController class]]) {
        DetailSharedMessageViewController* nextVC = (DetailSharedMessageViewController*)segue.destinationViewController;
        NSDictionary* message = self.sharingActivities[self.selectedCellIndex];
        nextVC.messageContentProxy = [message objectForKey:@"content"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sharingActivities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    PFObject* activity = _sharingActivities[indexPath.row];
    cell.textLabel.text = activity[@"tag"];
    cell.detailTextLabel.text = activity[@"userName"];
    
    return cell;
}
#pragma mark - TableViewDelegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedCellIndex = indexPath.row;
}

- (IBAction)addActivityBarButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle: @"Share with others" message:@"Enter message you would like to share" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: @"Cancel",nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

#pragma mark - UIALertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        NSString* message = textField.text;
        if (textField.text.length > 0) {
            [self saveActivityToParseWithMessage:message];

        }
        
    }else if (buttonIndex == 1){
        
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark - Helper Methods 

-(void)saveActivityToParseWithMessage:(NSString*)message{
    
    PFObject* activity = [PFObject objectWithClassName:@"Sharing"];
    [activity setObject:message forKey:@"testimonio"];
    [activity setObject:@"Daniel" forKey:@"userName"];
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Mensaje enviado" message:@"Enviado Exitosamente" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [self viewDidAppear:YES]; 

        }
    }];
    
}

/*TODO:
 1)Retrieve from parse and store to core data
 1.1)Retrieve checking for messages not already persisted to core data - Should this be done by comparing counts?
 2) Schedule a local notification using the showDate
 */
#pragma mark - Core Data


#pragma mark - Parse






@end
