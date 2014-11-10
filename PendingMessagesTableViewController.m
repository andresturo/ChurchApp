//
//  PendingMessagesTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/15/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "PendingMessagesTableViewController.h"
#import "Message.h"
#import "TargetGroups.h"

//TODO: Block user from sending same event more than once, how to update message once pushed to parse

@interface PendingMessagesTableViewController ()<PendingMessagesDelegate, UIAlertViewDelegate,NSCoding>

@property (strong,nonatomic)NSIndexPath* indexPathForSelectedCell;

@property (strong,nonatomic) NSMutableArray* messages;
@end

@implementation PendingMessagesTableViewController

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
    
   self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.messages = [[NSMutableArray alloc]init];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dispatchPendingMessage:) name:@"sendScheduledMessages" object:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //Reload saved data
    
    [self loadMessages];

}

#pragma mark - Lazy Instantiation 

-(NSMutableArray *)messages{
    
    if(!_messages){
        _messages = [[NSMutableArray alloc]init];
    }
    
    return _messages;
}

#pragma mark - NSNotification Center
-(void)dispatchPendingMessage:(NSNotification*)notification{
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Send your scheduled message?" message:@"Press ok to deliver message" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)addMessageBarButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Schedule New Message" message:@"Enter a tag for message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
    
  
    
    
}


#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString* messageTag =[[alertView textFieldAtIndex:0]text];
    
    if (buttonIndex ==0) {
        
        Message* newMessage = [self messageFromTag:messageTag];
        [self.messages addObject:newMessage];
        //TODO: Order tableView by date
        
        
        
        [self.tableView reloadData];
        
    }
}

#pragma mark - Core Data Helper Methods 

-(Message*)messageFromTag:(NSString*)messageTag{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    Message* message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    message.messageTag = messageTag;
    NSError* error = nil;
    BOOL succeded = [[message managedObjectContext] save:&error];
    if (!succeded) {
        NSLog(@"Couldnt save");
    }
    

    [self newParseMessageFromTag:messageTag];
    
    return message;
}

-(void)loadMessages {
    
    //TODO: Should delivered messages be deleted here?
    [self deleteOldMessages];
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"deliverDate" ascending:NO]]];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    

    
    NSLog(@"Number of loaded messages %i",fetchedResults.count);
    self.messages = [fetchedResults mutableCopy];
    [self.tableView reloadData];
    
}

-(void)deleteOldMessages {
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deliverDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context  = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchedResults = [context executeFetchRequest:fetchRequest error:&error];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"deliverDate < %@",[NSDate date]];
    NSArray* filteredArray = [fetchedResults filteredArrayUsingPredicate:predicate];
    
    for (Message* msg in filteredArray) {
        [[msg managedObjectContext] deleteObject:msg];
        //Delete From Parse too
        [self deleteMessageFromParse:msg];

    }
    
    NSLog(@"%i deleted messages",[[context deletedObjects] count]);
    
    
    if (![context save:&error]) {
        NSLog(@"Couldnt save after deleting objects");
    }
    
    
    
    
    
}
#pragma mark - Push to parse


-(void)newParseMessageFromTag:(NSString*)tag{
    
    PFObject* message = [PFObject objectWithClassName:@"Sharing"];
    [message setObject:tag forKey:@"tag"];
    [message setObject:[PFUser currentUser] forKey:@"fromUser"];
    [message saveInBackground];
}

-(void)deleteMessageFromParse:(Message*)msg{
    
    PFQuery* query = [PFQuery queryWithClassName:@"Sharing"];
    
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"tag" equalTo:msg.messageTag];
    [query includeKey:@"fromUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            NSLog(@"object count %i with fromUser %@",objects.count,objects[0][@"fromUser"][@"profile"][@"name"]);
            
            for (PFObject* obj in objects) {
                [obj deleteInBackground];
            }
        }
    
    }];
    
}

-(void)updateParseMessage{
    
    PFQuery* query = [PFQuery queryWithClassName:@"Sharing"];
    
    Message* msg = self.messages[self.indexPathForSelectedCell.row];
    NSLog(@"message tag: %@",msg.messageContent);
    [query whereKey:@"tag" equalTo:msg.messageTag ];
    
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *message, NSError *error) {
        if (!error) {
            NSLog(@"Updating Found PFObject %@",message[@"targetGroups"]);
            //Found message with specified tag
            [message setObject:msg.messageContent forKey:@"content"];
            [message setObject:msg.messageTag forKey:@"tag"];
            [message setObject:msg.deliverDate forKey:@"showDate"];
            [message setObject:msg.targetGroup forKey:@"targetGroups"];
            [message saveInBackground];
            
        }else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
        }
    }];
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
    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pendingMessageCell" forIndexPath:indexPath];
    
    Message* selectedMessage = self.messages[indexPath.row];
    cell.textLabel.text = selectedMessage.messageTag;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/mm/yyyy"];
    NSString* dateString = [formatter stringFromDate:selectedMessage.deliverDate];
    cell.detailTextLabel.text = dateString;
    
    // Configure the cell...
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Remove from parse too
        [self deleteMessageFromParse:self.messages[indexPath.row]];

        //add code here for when you hit delete
        Message* message = self.messages[indexPath.row];
        NSError* error;
        [[message managedObjectContext] deleteObject:message];
        [[message managedObjectContext] save:&error];
        
        [self.messages removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.indexPathForSelectedCell = indexPath;
    
    [self performSegueWithIdentifier:@"toMessageSettingsSegue" sender:nil];
}

#pragma mark - Segue Methods 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.destinationViewController isKindOfClass:[PendingSettingsViewController class]]) {
        PendingSettingsViewController* nextViewController = (PendingSettingsViewController*)segue.destinationViewController;
        
        nextViewController.delegate = self;
        nextViewController.message = self.messages[self.indexPathForSelectedCell.row];
        NSLog(@"message Tag %@",[sender detailTextLabel].text);
    }
}

#pragma mark - PendingMessageDelegate



-(void)didSaveMessageSettings:(Message*)message{
  
    
    [self updateParseMessage];
}









@end
