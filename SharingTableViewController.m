//
//  SharingTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/1/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "SharingTableViewController.h"

@interface SharingTableViewController () <UIAlertViewDelegate>
@property (strong,nonatomic) NSArray* sharingActivities;
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
        _sharingActivities = objects;
        [self.tableView reloadData];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.textLabel.text = activity[@"testimonio"];
    cell.detailTextLabel.text = activity[@"userName"];
    
    return cell;
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






@end
