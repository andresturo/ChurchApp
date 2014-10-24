//
//  AttendingChurchTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/11/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "AttendingChurchTableViewController.h"

@interface AttendingChurchTableViewController ()
@property (nonatomic) NSIndexPath* checkMarkIndexPath;
@property (strong,nonatomic) NSArray* churchNames;
@property (strong,nonatomic) NSString* selectedChurch;

@end

@implementation AttendingChurchTableViewController

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
    
    [self updateWithSavedSettings];

}

-(void)viewDidAppear:(BOOL)animated{
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Lazy instantiation

-(NSArray *)churchNames{
    
    if (!_churchNames) {
        _churchNames = [[NSArray alloc]initWithObjects:@"Visitante",@"Redil del Sur",@"Redil del Poblado",@"Redil de la 33",@"Redil del Envigado",@"Redil del Oriente",@"Redil de Belen",nil];
        
    }
    
    return _churchNames;
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
    return [self.churchNames count];
}

#pragma mark - tableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"churchCell" forIndexPath:indexPath];
    
    //Only one check mark at a time
    
    if ([self.checkMarkIndexPath isEqual:indexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    
    
    cell.textLabel.text = self.churchNames[indexPath.row];
    
    
    return cell;
}

#pragma mark - tableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.checkMarkIndexPath = indexPath;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedChurch = cell.textLabel.text;

    [tableView reloadData];
    
    //Notify parent view controller of a new selected church
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAChurch" object:self userInfo:@{@"attendingChurch": self.selectedChurch}];
    
    //Save Selected Index to NSUserDefaults
    [self saveSettings];
    

    
}
#pragma mark - NSUserDeafaults

-(void)saveSettings{
    //Persist Selection to NSUserDefaults
    NSNumber* selectedCell = [NSNumber numberWithInteger:self.checkMarkIndexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedCell forKey:@"attendingChurchIndex"];
        
}

-(void)updateWithSavedSettings{
    
    //Check last selected cell in tableView
    NSNumber* selectedRowInSectionOne = [[NSUserDefaults standardUserDefaults] objectForKey:@"attendingChurchIndex"];
   
    
    self.checkMarkIndexPath = [NSIndexPath indexPathForRow:selectedRowInSectionOne.integerValue inSection:0];
    
    [self.tableView selectRowAtIndexPath:self.checkMarkIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}




@end
