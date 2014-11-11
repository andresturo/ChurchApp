//
//  PendingSettingsViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/15/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "PendingSettingsViewController.h"
#import "EditPendingMessageViewController.h"
#import "PendingMessagesTableViewController.h"
#import "TargetGroupTableViewCell.h"
#import "ActionSheetStringPicker.h"
#import "CCIndexPath.h"

/*TODO: By default all message will be sent now if no date has been assigned 
 and will be sent to all if no targetgroup is selected but wont be sent if message is blank 
 
 
 */


@interface PendingSettingsViewController ()
<UITableViewDataSource,UITableViewDelegate,EditPendingMessageDelegate,UINavigationControllerDelegate
/*,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate*/>

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UILabel *chosenDateLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSDate* selectedDate;
@property (strong,nonatomic) NSArray* churchNames;
@property (strong,nonatomic) NSArray* rolesInChurch;
@property (strong,nonatomic) NSIndexPath* currentSelectedIndexPath;

//@property (strong,nonatomic) NSMutableArray* datasourceTargets;
//An array of CCIndexPath objects
//@property (strong,nonatomic) NSMutableArray* checkMarkIndexPaths;
//@property (strong,nonatomic) NSMutableArray* targetsWithRoles;

@property (strong,nonatomic) NSString* selectedTarget;
@property (strong,nonatomic) NSString* seletedRole;

@end

@implementation PendingSettingsViewController



#pragma mark - VIewLifeCycle

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
     self.churchNames =[[NSArray alloc] initWithObjects:@"Redil del Sur",@"Redil del Poblado",@"Redil de la 33",@"Redil de Envigado",@"Redil del Oriente",@"Redil de Belen",nil];
    self.rolesInChurch = [[NSArray alloc]initWithObjects:@"None",@"Visitantes",@"Pastores",@"Lideres de Jovenes",@"Grupo de Alabanza", @"Trabajadores del Redil", nil];


    
    //Limit UIDatePicker minimum date to current date
    [self.datePicker setMinimumDate:[NSDate date]];//Never let edit send date to a past date
    [self setTodaysDate];
    
    //Default Selection
    self.currentSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    self.navigationController.delegate = self;
    self.seletedRole = @"None";
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.navigationController.delegate = nil;

    
    if ([viewController isKindOfClass:[PendingMessagesTableViewController class]]) {
        
        if ([self.churchNames containsObject:self.message.targetGroup]) {
             UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Can't send a message withoud target group" message:@"Select a target group" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];

        }
       
        
    }
}

#pragma mark - Segue Methods

//MARK: This VC will relase message so if editVC doesnt edit message(return message via delegate) no information will be pushed
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.destinationViewController isKindOfClass:[EditPendingMessageViewController class]]) {
        EditPendingMessageViewController* nextViewController = (EditPendingMessageViewController*)segue.destinationViewController;
        nextViewController.message = self.message;
        nextViewController.delegate = self;
    }
}


#pragma mark - UIDatePicker IBAction
//UIDatePickerView doesn't have a delegate
- (IBAction)dateChanged:(UIDatePicker *)sender {
    NSTimeInterval timeInterval = [sender.date timeIntervalSinceNow];
    
    if (timeInterval > 0) {
        //Date to Register UILocalNotification
        self.selectedDate = sender.date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        
        //[formatter setDateFormat:@"dd/mm/yyyy"];
        [formatter setDateFormat:@"ccc dd MMM yyyy hh:m a"];
        
        //[formatter setDateStyle:NSDateFormatterFullStyle];
        NSString* stringFromDate = [formatter stringFromDate:sender.date];
        self.chosenDateLabel.text = stringFromDate;
    }else {
        

        
    }

    
}

#pragma mark - IBActions
- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
    
    
    self.message.deliverDate = self.selectedDate;
    
    //TODO: Persist to core data
    
    [self updateParseWithMessage];
    NSLog(@"Did save message %@",self.message);
    [self.delegate didSaveMessageSettings:self.message];
    
}

#pragma mark - Parse 
-(void)updateParseWithMessage{
    
    PFQuery* query = [PFQuery queryWithClassName:@"Sharing"];
    
    NSLog(@"message tag: %@",self.message.messageContent);
    [query whereKey:@"tag" equalTo:self.message.messageTag ];
    
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *message, NSError *error) {
        if (!error) {
            NSLog(@"Updating Found PFObject %@",message);
            //Found message with specified tag
            [message setObject:self.message.messageContent forKey:@"content"];
            [message setObject:self.message.messageTag forKey:@"tag"];
            [message setObject:self.message.deliverDate forKey:@"showDate"];
            [message setObject:self.message.targetGroup forKey:@"targetGroup"];
            [message setObject:self.message.roleInGroup forKey:@"roleInGroup"];
            [message saveInBackground];
            
        }else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
        }
    }];
}


#pragma mark - Helper Methods



-(void)setTodaysDate {
    
    NSDate* today = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"ccc dd MMM yyyy hh:m a"];
    NSString* stringFromDate = [formatter stringFromDate:today];
    self.chosenDateLabel.text = stringFromDate;
    
}




#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //Edit Message,Target group for message and tag for message
    
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 1;
   
    
    if (section ==1) {
        rows = [self.churchNames count];
    }
    return rows;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSArray* titleArray = @[@"Edit Message",@"Target Group"];
    
    NSString* title = titleArray[section];
    return title;
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    TargetGroupTableViewCell* cell = (TargetGroupTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"targetGroupCell"];
    
    
    if (indexPath.section ==1) {

        cell.titleLabel.text = self.churchNames[indexPath.row];
        cell.subtitleLabel.hidden = NO;
        cell.roleButton.tag = indexPath.row;
        [cell.roleButton addTarget:self action:@selector(roleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.currentSelectedIndexPath.row == indexPath.row ) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            cell.subtitleLabel.text = [NSString stringWithFormat:@"Specific to: %@",self.seletedRole];

             cell.roleButton.hidden = NO;
        }else {
            cell.subtitleLabel.hidden = YES;
            cell.roleButton.hidden = YES;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
   
        
    }else if (indexPath.section == 0){
        
        cell.titleLabel.text = self.message.messageTag;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"ccc dd MMM hh:m a"];
        NSString* dateString = [formatter stringFromDate:self.message.deliverDate];
        if(dateString)
        cell.subtitleLabel.text = [NSString stringWithFormat:@"Scheduled for: %@", dateString];
        else cell.subtitleLabel.hidden = YES;
        cell.roleButton.hidden = YES;
        
     
        
    }
    
  
        
   
    

    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}



#pragma mark - Table View Delegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        
        
        
        [[self.message managedObjectContext]save:nil];
        
        [self performSegueWithIdentifier:@"toMessageEditSegue" sender:nil];
        
        
    }else if(indexPath.section == 1){
        //If selected Index is different from currentSelectedIndex
        if (self.currentSelectedIndexPath.row != indexPath.row) {
            self.seletedRole = self.rolesInChurch[0];

        }
        self.currentSelectedIndexPath = indexPath;
        self.selectedTarget = self.churchNames[self.currentSelectedIndexPath.row];
        self.message.targetGroup = self.selectedTarget;
        [self.tableView reloadData];

    }

}



#pragma mark - EditPendingMessagesDelegate

-(void)didEndEditingMessage:(Message*)message{
    
    //TODO: Persist message and messageTag
    self.message = message;
    NSError* error;
    [[self.message managedObjectContext] save:&error];
}
-(void)didFinishEditingTag:(NSString *)messageTag{
    self.message.messageTag = messageTag;
    [self.tableView reloadData];

}

#pragma mark - IBActions

//TODO: Make action sheet contain a pickerView for selecting a role in the selected targetGroup (church)
-(IBAction)roleButtonPressed:(id)sender{
    

    
    //This is done because button press in cell steals cell selection
    
    NSIndexPath* indexForStealTouch = [NSIndexPath indexPathForRow:[sender tag] inSection:1];
    self.currentSelectedIndexPath = (CCIndexPath*)indexForStealTouch;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Role" rows:self.rolesInChurch
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Selected role %@",self.rolesInChurch[selectedIndex]);
                                           
                                           self.seletedRole = self.rolesInChurch[selectedIndex];
                                           self.message.roleInGroup = self.seletedRole;
                                        
                                           
                                           [self.tableView reloadData];
                                           
                                   } cancelBlock:^(ActionSheetStringPicker *picker) {
                                       NSLog(@"Canceled");
                                        }origin:sender];
    
    
}











@end
