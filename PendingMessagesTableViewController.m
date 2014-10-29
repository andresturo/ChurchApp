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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dispatchPendingMessage:) name:@"sendScheduledMessages" object:nil];
    
    

    
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
    
    return message;
}

-(void)loadMessages {
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"deliverDate" ascending:NO]]];
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    NSArray* fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Number of loaded messages %i",fetchResults.count);
    self.messages = [fetchResults mutableCopy];
    [self.tableView reloadData];
    
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

-(void)didUpdateMessageSendDate:(NSDate *)sendDate{
    
    //Sort tableView to have ascending dates
//    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"deliverDate" ascending:YES];
//    self.messages = [[self.messages sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    //Update Schedule date for message on TableViewCell
    
    Message* currentMessage =[self.messages objectAtIndex:self.indexPathForSelectedCell.row];
    currentMessage.deliverDate = sendDate;
    [self.messages setObject:currentMessage atIndexedSubscript:self.indexPathForSelectedCell.row];
    
    [self.tableView reloadData];
    
    
    //Schedule LocalNotification
    
    UILocalNotification* localNotification = [[UILocalNotification alloc]init];
    [localNotification setFireDate:sendDate];
    [localNotification setAlertBody:@"Pending scheduled messages"];
    [localNotification setAlertAction:@"Send right now!"];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
    
}

-(void)didUpdateMessageTag:(NSString *)messageTag{
    if (messageTag) {
        Message* currentMessage = self.messages[self.indexPathForSelectedCell.row];
         [currentMessage setMessageTag:messageTag];
        [self.tableView reloadData];
    }
   
}

-(void)didFinishSelectingtargetgroupsAndRoles:(NSArray *)info{
    
    Message* currentMessage = self.messages[self.indexPathForSelectedCell.row];
    currentMessage.targetGroups = info;
    
}
-(void)didUpdateMessage:(NSString *)message{
    Message* currentMessage = self.messages[self.indexPathForSelectedCell.row];

    currentMessage.messageContent = message;
}


-(void)didSaveMessageSettings{
    Message* currentMessage = self.messages[self.indexPathForSelectedCell.row];
    NSError* error;
    
    BOOL succeded = [[currentMessage managedObjectContext] save:&error];
    
    if (!succeded) {
        NSLog(@"Didnt save");

    }
    
    
}









@end
