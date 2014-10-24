//
//  RoleInChurchTableTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/11/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "RoleInChurchTableTableViewController.h"

@interface RoleInChurchTableTableViewController ()

@property (strong,nonatomic) NSIndexPath* checkMarkIndexPath;
@property (strong,nonatomic) NSArray* rolesInChurch;
@property (strong,nonatomic) NSString* selectedRole;

@end

@implementation RoleInChurchTableTableViewController

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
    return [self.rolesInChurch count];
}

#pragma mark - Lzy instantiation

-(NSArray *)rolesInChurch{
    
    if (!_rolesInChurch) {
               _rolesInChurch = [[NSArray alloc] initWithObjects:@"Asistente",@"Pastor",@"Lider de Jovenes",@"Grupo de Alabanza", @"Trabajador del Redil", nil];
    }
    
    return _rolesInChurch;
}



#pragma mark - Table view data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"roleCell" forIndexPath:indexPath];
    
    //Only one check mark at a time
    if ([self.checkMarkIndexPath isEqual:indexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    
    
    cell.textLabel.text = self.rolesInChurch[indexPath.row];
    
    
    return cell;
}

#pragma mark - tableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.checkMarkIndexPath = indexPath;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];

    self.selectedRole = cell.textLabel.text;
    [tableView reloadData];
        
    //Notify parent view controller of a new selected church
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedARole" object:self userInfo:@{@"roleInChurch": self.selectedRole}];
    
    //Save Selected Index to NSUserDefaults
    [self saveSettings];
    
    
}

#pragma mark - NSUserDefaults

-(void)saveSettings{
    //Persist Selection to NSUserDefaults
    NSNumber* selectedCell = [NSNumber numberWithInteger:self.checkMarkIndexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedCell forKey:@"roleInChurchIndex"];
    
}

-(void)updateWithSavedSettings{
    
    //Check last selected cell in tableView
    NSNumber* selectedRowInSectionOne = [[NSUserDefaults standardUserDefaults] objectForKey:@"roleInChurchIndex"];
    
    
    self.checkMarkIndexPath = [NSIndexPath indexPathForRow:selectedRowInSectionOne.integerValue inSection:0];
    
    [self.tableView selectRowAtIndexPath:self.checkMarkIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}


@end
