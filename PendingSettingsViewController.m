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
@property (strong,nonatomic) NSMutableArray* datasourceTargets;
//An array of CCIndexPath objects
@property (strong,nonatomic) NSMutableArray* checkMarkIndexPaths;
@property (strong,nonatomic) NSMutableArray* targetsWithRoles;

@end

@implementation PendingSettingsViewController

#pragma mark -Lazy 

-(NSMutableArray *)targetsWithRoles{
    if (!_targetsWithRoles) {
        _targetsWithRoles = [[NSMutableArray alloc]init];
        
    }
    return _targetsWithRoles;
}

-(NSMutableArray *)datasourceTargets{
    if (!_datasourceTargets) {
        _datasourceTargets = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < self.churchNames.count; i++) {
            [self.datasourceTargets addObject:[self targetWithDefaultRole:i]];
            
        }
    }
    return _datasourceTargets;
    
}

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
    self.checkMarkIndexPaths = [[NSMutableArray alloc]init];
//    [self loadCheckMarks];
    self.navigationController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self checkMarksFromMessageTargets];
//    [self setRolesInDatasourceTargets];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    
    if ([self.checkMarkIndexPaths count] == 0 && [viewController isKindOfClass:[PendingMessagesTableViewController class]]) {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Can't send a message withoud target group" message:@"Select a target group" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    }
}

#pragma mark - Segue Methods

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
- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.selectedDate && [self.delegate respondsToSelector:@selector(didUpdateMessageSendDate:)]) {
        [self.delegate didUpdateMessageSendDate:self.selectedDate];

    }
    [self selectedTargetsAndRoles];
    NSLog(@"Saved targets and roles %@",self.targetsWithRoles);
    [self.delegate didFinishSelectingtargetgroupsAndRoles:self.targetsWithRoles];
    [self.delegate didSaveMessageSettings];
    
}



#pragma mark - Helper Methods

-(void)checkMarksFromMessageTargets{
    
    
    NSMutableArray* checkMarkIndexPaths = [[NSMutableArray alloc]init];
    NSLog(@"Initial datasource targets %@",self.message.targetGroups);
    NSInteger indexCount;
    //Look up in message object if it contains the dataSourceTargetGroup if so then replace the dataSourceTargetgroup object
    
    for (indexCount = 0 ; indexCount < self.datasourceTargets.count ; indexCount++) {
        
        NSDictionary* dict = self.datasourceTargets[indexCount];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"targetGroup == %@",dict[@"targetGroup"]];
        NSArray* filteredArray = [self.message.targetGroups filteredArrayUsingPredicate:predicate];
        
        if (filteredArray.count > 0) {
            NSDictionary* targetMatch = filteredArray[0];

            NSLog(@"Found a match: %@ at index %i",targetMatch,indexCount);
            [self.datasourceTargets setObject:targetMatch atIndexedSubscript:indexCount];
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:indexCount inSection:1];
            [checkMarkIndexPaths addObject:indexPath];
        }
        
      
   
    }
    
    self.checkMarkIndexPaths = checkMarkIndexPaths;
    [self.tableView reloadData];
}

-(void)setTodaysDate {
    
    NSDate* today = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"ccc dd MMM yyyy hh:m a"];
    NSString* stringFromDate = [formatter stringFromDate:today];
    self.chosenDateLabel.text = stringFromDate;
    
}



-(NSDictionary*)targetWithDefaultRole:(NSInteger)index{
    
    NSString* target = self.churchNames[index];
    NSString* role = @"None";
    
    return @{@"targetGroup":target,@"roleInChurch":role};
}

-(void)selectedTargetsAndRoles{
    
    for (NSIndexPath* indexPath in self.checkMarkIndexPaths) {
        NSString* selectedChurch = [self.datasourceTargets[indexPath.row] objectForKey:@"targetGroup"];
        NSString* selectedRole = [self.datasourceTargets[indexPath.row] objectForKey:@"roleInChurch"];
        NSDictionary* targetAndRole = @{@"targetGroup":selectedChurch,@"roleInChurch":selectedRole};
        [self.targetsWithRoles addObject:targetAndRole];
    }
    
}
-(void)setRolesInDatasourceTargets{
    
    for (NSDictionary* dictionary  in self.message.targetGroups) {
        if ([self.datasourceTargets containsObject:dictionary]) {
            NSLog(@"Datasourcetargets contain %@",dictionary[@"targetGroup"]);
            NSInteger index = [self.datasourceTargets indexOfObject:dictionary];
            [self.datasourceTargets replaceObjectAtIndex:index withObject:dictionary];
            
        }
    }
    
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
        NSString* role = [self.datasourceTargets[indexPath.row] objectForKey:@"roleInChurch"];
        cell.subtitleLabel.text = [NSString stringWithFormat:@"Specific to: %@",role];
        cell.roleButton.tag = indexPath.row;
        [cell.roleButton addTarget:self action:@selector(roleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
   
        
    }else if (indexPath.section == 0){
        
        cell.titleLabel.text = self.message.messageTag;
        cell.subtitleLabel.hidden = YES;
        cell.roleButton.hidden = YES;
        
    }
    
  
        
        if ([self.checkMarkIndexPaths containsObject:(CCIndexPath*)indexPath]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
           // cell.roleButton.hidden = NO;
        }else {
            
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    

    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}



#pragma mark - Table View Delegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"toMessageEditSegue" sender:nil];
        
    }else if(indexPath.section == 1){
        
        TargetGroupTableViewCell* cell = (TargetGroupTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.roleButton.hidden = NO;
        self.currentSelectedIndexPath = indexPath;

        //Check if cell is already checkmarked
        if ([self.checkMarkIndexPaths containsObject:(CCIndexPath*)indexPath]) {
            
            NSInteger index = [self.checkMarkIndexPaths indexOfObject:indexPath];
            NSLog(@"Index of deselected cell: %i",index);
            [self.checkMarkIndexPaths removeObjectAtIndex:index];
            
        }else{
            [self.checkMarkIndexPaths addObject:(CCIndexPath*)indexPath];
            

        }
        
        NSLog(@"Array of checkmark indexes count: %i",self.checkMarkIndexPaths.count);

        [self.tableView reloadData];

    }

}



#pragma mark - EditPendingMessagesDelegate

-(void)didEndEditingMessage:(NSString *)message{
    
    //TODO: Persist message and messageTag
}
-(void)didFinishEditingTag:(NSString *)messageTag{
    self.message.messageTag = messageTag;
    [self.tableView reloadData];
    [self.delegate didUpdateMessageTag:messageTag];

}

#pragma mark - IBActions

//TODO: Make action sheet contain a pickerView for selecting a role in the selected targetGroup (church)
-(IBAction)roleButtonPressed:(id)sender{
    

    
    //This is done because button press in cell steals cell selection
    
    NSIndexPath* indexForStealTouch = [NSIndexPath indexPathForRow:[sender tag] inSection:1];
    self.currentSelectedIndexPath = indexForStealTouch;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Role" rows:self.rolesInChurch
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Selected role %@",self.rolesInChurch[selectedIndex]);
                                           
                                           NSString* selectedRole = self.rolesInChurch[selectedIndex];
                                           
                                           NSMutableDictionary* targetAndRole = [self.datasourceTargets[self.currentSelectedIndexPath.row] mutableCopy];
                                           [targetAndRole setObject:selectedRole forKey:@"roleInChurch"];
                                           
                                           [self.datasourceTargets setObject:targetAndRole atIndexedSubscript:self.currentSelectedIndexPath.row];
                                           
                                           [self.tableView reloadData];
                                           
                                   } cancelBlock:^(ActionSheetStringPicker *picker) {
                                       NSLog(@"Canceled");
                                        }origin:sender];
    
    
}


#pragma mark - NSKeyedArchiver 

//-(void)saveCheckMarks {
//    
//    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.checkMarkIndexPaths];
//    NSUserDefaults* standardDefaults = [NSUserDefaults standardUserDefaults];
//    [standardDefaults removeObjectForKey:@"checkMarks"];
//    [standardDefaults setObject:data forKey:@"checkMarks"];
//    
//    
//
//}
//
//-(void)loadCheckMarks {
//    
//    NSData* checkMarkData = [[NSUserDefaults standardUserDefaults]objectForKey:@"checkMarks"];
//    if (checkMarkData){
//        self.checkMarkIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:checkMarkData];
//        NSLog(@"Loaded %i checkmarks",self.checkMarkIndexPaths.count);
//
//        [self.tableView reloadData];
//        
//    }
//}








@end
