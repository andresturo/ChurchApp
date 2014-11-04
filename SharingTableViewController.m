//
//  SharingTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/1/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "SharingTableViewController.h"
#import "DetailSharedMessageViewController.h"
#import "ReceivedMessage.h"


@interface SharingTableViewController () <UIAlertViewDelegate>
@property (strong,nonatomic) NSMutableArray* scheduledMessages;//These are messages scheduled to show on a date
@property (strong,nonatomic) NSMutableArray* showingMessages;//Actual data source
@property (strong,nonatomic) ReceivedMessage* currentMessage;
@property (nonatomic) NSInteger selectedCellIndex;
@property BOOL shouldUpdateMessages;
@end

//TODO: Best way of sync between core data and parse service

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkForUpdates];
    [self loadMessages];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.destinationViewController isKindOfClass:[DetailSharedMessageViewController class]]) {
        DetailSharedMessageViewController* nextVC = (DetailSharedMessageViewController*)segue.destinationViewController;
        self.currentMessage = self.showingMessages[self.selectedCellIndex];
        nextVC.messageContentProxy = self.currentMessage.messageContent;
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
    return [self.showingMessages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    // Configure the cell...
    ReceivedMessage* message = self.showingMessages[indexPath.row];
    cell.textLabel.text = message.messageTag;
    cell.detailTextLabel.text = message.fromUser;
    
    return cell;
}
#pragma mark - TableViewDelegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedCellIndex = indexPath.row;
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
 1.2)Retrieve checking if current user is included in the targetgroup of message
 2) Schedule a local notification using the showDate
 
 -Count parse objects, count core data object if count doesnot match - retrive from parse and replace core data objects
 
 */
#pragma mark - Core Data

-(void)loadReceivedMessages {
    
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReceivedMessage"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"showDate" ascending:NO]]];
    //Filter to show only messages from today and before
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"showDate < %@",[NSDate date]];
//    [fetchRequest setPredicate:predicate];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    
    
    NSLog(@"Number of loaded messages %i",fetchedResults.count);
    self.showingMessages = [fetchedResults mutableCopy];
    [self.tableView reloadData];
    
}

-(void)deleteAllReceivedMessages{
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReceivedMessage"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"showDate" ascending:NO]]];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    for (ReceivedMessage* msg in fetchedResults) {
        [[msg managedObjectContext]delete:msg];
    }
    
}

-(NSInteger)countCoreDataReceivedMessages{
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReceivedMessage"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"showDate" ascending:NO]]];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    return [fetchedResults count];
}




#pragma mark - Parse
-(void)loadMessagesFromParse{//MARK: seems like parse cant support predicates with contained in
    NSString* currentUserChurch = [[NSUserDefaults standardUserDefaults] objectForKey:@"attendingChurch"];
    NSLog(@"Will query for user attendingChurch %@",currentUserChurch);
    PFQuery* query = [PFQuery queryWithClassName:@"Sharing"];
//    [query whereKey:@"fromUser" notEqualTo:[PFUser currentUser]];
    [query includeKey:@"fromUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
          //TODO: Make ReceivedMessages from fetched Array
            NSLog(@"Found %i messages for user attendingChurch",objects.count);
            for (PFObject* object in objects) {
                [self receivedMessageFromParseObject:object];
            }

        }
    }];
    
}

-(void)checkForUpdates{
    PFQuery* query = [PFQuery queryWithClassName:@"Sharing"];
    
     [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            NSInteger localCount = [self countCoreDataReceivedMessages];
            if (number > localCount) {
                self.shouldUpdateMessages = YES;
                NSLog(@"Should update");
            }
        }else {
            
            self.shouldUpdateMessages = NO;
        }
    }];
}

#pragma mark - Helpers
//TODO: Query before saving -avoid duplicates
-(void)receivedMessageFromParseObject:(PFObject*)object{
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    //Find if current user belongs in message Role group
 
    NSString* currentUserRole = [[NSUserDefaults standardUserDefaults] objectForKey:@"roleInChurch"];
    NSString* currentUserChurch = [[NSUserDefaults standardUserDefaults] objectForKey:@"attendingChurch"];

    NSArray* targetGroups = object[@"targetGroups"];//This for shure must be an array of one object
    NSDictionary* targetGroup = [targetGroups firstObject];
    ReceivedMessage* newMessage;
    
    //Filter parse query for target and role of user
    if ([targetGroup[@"targetGroup"]isEqualToString:currentUserChurch])
    if ([targetGroup[@"roleInChurch"] isEqualToString:@"None"] || [targetGroup[@"roleInChurch"] isEqualToString:currentUserRole]) {
        
        //Persist if not already saved
        NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ReceivedMessage"];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"messageTag == %@",object[@"tag"]];
        [fetchRequest setPredicate:predicate];
        NSArray* fetchedDuplicates = [context executeFetchRequest:fetchRequest error:&error];
        
        if (fetchedDuplicates.count == 0) {
            NSLog(@"No duplicate");
            newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"ReceivedMessage" inManagedObjectContext:context];
            newMessage.messageContent = object[@"content"];
            newMessage.messageTag = object[@"tag"];
            newMessage.showDate = object[@"showDate"];
            newMessage.fromUser = object[@"fromUser"];
            [[newMessage managedObjectContext]save:&error];
        }   

    }

  
    
}


-(void)loadMessages{
    
//    if (self.shouldUpdateMessages) {
//        [self deleteAllReceivedMessages];
//        [self loadMessagesFromParse];
//    }else {
//        
//        [self loadReceivedMessages];
//    }

    [self loadMessagesFromParse];
    [self loadReceivedMessages];
}




@end
