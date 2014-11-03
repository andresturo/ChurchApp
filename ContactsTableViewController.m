//
//  ContactsTableViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 9/2/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactsDetailViewController.h"
#import "User.h"
#import "SettingsViewController.h"
@interface ContactsTableViewController ()

@property NSArray* contactList;
@property NSMutableArray* profilePictures;
@property NSString* currentMailRecipient;
@property NSInteger selectedScopeIndex;
@property (strong,nonatomic) NSDictionary* currentUserFBProfileInfo;
@property (nonatomic,copy) NSArray* searchResults;
@property (strong,nonatomic) UITableView* unFilteredTableView;

@property (strong,nonatomic) NSString* predicatePrefix;
@end

@implementation ContactsTableViewController

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
    //Initailize objects
    
   // _searchResults = [[NSArray alloc]init];
    self.profilePictures = [[NSMutableArray alloc]init];
    NSLog(@"Profile pictures array: %@",self.profilePictures);
    //Load Cell Contents Array
    
    //If no user profiles have been presisted to CoreData then request from parse
    
//    [self retrieveCommunityProfilesFromParse];
//    [self retrieveCommunityProfilePicturesFromParse];
    
//    self.contactList =[self usersToContactListDictionary:[self getSavedUserProfiles]];
//    NSLog(@"ContactList info in CoreData %@",[self usersToContactListDictionary:[self getSavedUserProfiles]]);
//
//    if ([self.contactList count] == 0) {
//        [self retrieveCommunityProfilesFromParse];
//        [self retrieveCommunityProfilePicturesFromParse];
//
//
//    }
    
    
    InfoRediles* infoRediles = [[InfoRediles alloc]init];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    self.contactList = [[infoRediles contactsInfoArrayUsingLocalPlist] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    [self.tableView reloadData];
    
    //Be an observer for facebook logins
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithFacebookLoginInfo:) name:@"didLogin" object:nil];
    



}



#pragma mark - NSNotification Callbacks

-(void)updateWithFacebookLoginInfo:(NSNotification*)notification{
    
    NSDictionary* profileInfo =[notification userInfo];
    NSLog(@"Have been notified about login with user info %@",profileInfo);

    self.currentUserFBProfileInfo = profileInfo;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //Segue To DetailViewController
    if([segue.destinationViewController isKindOfClass:[ContactsDetailViewController class]]){
        
        ContactsDetailViewController* nextView =(ContactsDetailViewController*)[segue destinationViewController];
        NSIndexPath* indexPath;
        NSDictionary* selectedContact = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            selectedContact = _searchResults[indexPath.row];
        }else {
            indexPath = [self.tableView indexPathForSelectedRow];
            selectedContact = self.contactList[indexPath.row];
        }
        //Configure nextViewController
        
        if (selectedContact) {
            NSLog(@"Performing segue with contact info %@",selectedContact);
            NSString* aboutUser = [NSString stringWithFormat:@"%@ en el %@",selectedContact[@"roleInChurch"],selectedContact[@"attendingChurch"]];
            if(aboutUser)nextView.profileInfo = aboutUser;
            if(selectedContact[@"name"])nextView.profileName = selectedContact[@"name"];
            if(selectedContact[@"email"]) nextView.mailRecipient = selectedContact[ @"email"];
            if (selectedContact[@"cellphone"]) nextView.cellphone = selectedContact[@"cellphone"];
            if(self.profilePictures && self.profilePictures.count != 0){nextView.profileImage = self.profilePictures[indexPath.row];}
        }
   
        
    }
    
    //Segue to Profile Settings View Controller
    
    if ([segue.destinationViewController isKindOfClass:[SettingsViewController class]]) {
        SettingsViewController* nextViewController = (SettingsViewController*)segue.destinationViewController;
        nextViewController.userNameProxy = self.currentUserFBProfileInfo[@"name"];
        
    }
    
}

#pragma mark - Alphabetically Ordered Contacts


-(NSArray*)contactListStartingByLetter:(NSString*)letter{
    NSArray* keyArray = @[@"name",@"attendingChurch",@"roleInChurch"];
    
    

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K beginswith[c] %@",keyArray[self.selectedScopeIndex],letter];
    NSArray* arrayStartingByLetter = [self.contactList filteredArrayUsingPredicate:predicate];
    
    return arrayStartingByLetter;
    
}


-(NSDictionary*)contactsByAlphabetOrder{
    
    NSArray* alphabet = [[NSArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                         @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    NSMutableDictionary* contactsByAlphabetOrder = [[NSMutableDictionary alloc]initWithCapacity:alphabet.count];


    for (NSString* letter  in alphabet) {
        
        NSArray* contactsByLetter = [self contactListStartingByLetter:letter];
        
        if (contactsByLetter && contactsByLetter.count > 0) {
            [contactsByAlphabetOrder setObject:contactsByLetter forKey:letter];

        }
    }
    
    return contactsByAlphabetOrder;
}

-(NSArray*)contactsInSection:(NSInteger)section {
    
    NSArray* titles = [self usedAlphabetLetters];
    NSString* title = [titles objectAtIndex:section];
    NSArray* contactsInSectionTitle =[[self contactsByAlphabetOrder] objectForKey:title];
    return contactsInSectionTitle;
}

-(NSArray*)usedAlphabetLetters{
    
    return [[self contactsByAlphabetOrder]allKeys];
}




#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    NSInteger sections = [[self usedAlphabetLetters] count];

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger rows = 1;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rows = [self.searchResults count];
        return rows;
    }
    if (self.contactList) {
//        rows = [self.contactList count];
        rows = [[self contactsInSection:section] count];

        NSLog(@"Number of rows in section %i",rows);
        return rows;
        
    }

    return rows;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
   NSArray* titles = [self usedAlphabetLetters];
    return titles;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
   
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    NSString* letter =[[self usedAlphabetLetters] objectAtIndex:section];

    return letter;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Self.tableview not [tableView deque .....

    //    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
    }
    // Configure the cell...
    CGFloat cellHeight = cell.frame.size.height;
    cell.imageView.layer.cornerRadius = cellHeight/2;
    cell.imageView.frame = CGRectMake(0, 0, cellHeight-30, cellHeight-30);
    cell.imageView.clipsToBounds = YES;
    
    //Data source for cells using filtered results or complete data set
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary* selectedContact = _searchResults[indexPath.row];
        cell.textLabel.text = selectedContact[ @"name"];
        cell.detailTextLabel.text = selectedContact[@"attendingChurch"];

        
    }else{
        
       // NSDictionary* selectedContact = _contactList[indexPath.row];
        NSDictionary* selectedContact = [[self contactsInSection:indexPath.section] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = selectedContact[ @"name"];
        cell.detailTextLabel.text = selectedContact[@"attendingChurch"];
        if ([self.profilePictures count] > indexPath.row) {
            cell.imageView.image = self.profilePictures[indexPath.row];
        }else cell.imageView.image = nil;

    }

    
    return cell;
}



#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark - SearchDisplayControllerDelegate methods
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString* predicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@",self.predicatePrefix,searchText];
    NSLog(@"Predicate string %@",predicateFormat);
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%@ contains[c] %@",scope,searchText];
    
    _searchResults = [_contactList filteredArrayUsingPredicate:predicate];
}

-(void)filterContentForSearchText:(NSString*)searchText scopeIndex:(NSInteger)scopeIndex{
    NSArray* keyArray = @[@"name",@"attendingChurch",@"roleInChurch"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K contains[c] %@",keyArray[scopeIndex],searchText];
    NSLog(@"Predicate string: %@",predicate.predicateFormat);
    _searchResults = [_contactList filteredArrayUsingPredicate:predicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    
    [self filterContentForSearchText:searchString scopeIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    
    return YES;
}


#pragma mark - UISearchbarDelegate

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.selectedScopeIndex = selectedScope;
    //TODO:Retrigger shouldReloadTableForSearchString

}


#pragma  mark - Parse Retreiving
//TODO: Retrieve all except this users info
-(void)retrieveCommunityProfilesFromParse{
    NSMutableArray* profiles = [[NSMutableArray alloc]init];

    //PFQuery* queryForUsers = [PFQuery queryWithClassName:@"User"];
    PFQuery* queryForUsers = [PFUser query];
    
    [queryForUsers whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [queryForUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFUser* user in objects) {
                    NSMutableDictionary* profileInfo = [user[@"profile"] mutableCopy];
                    [profileInfo setObject:user[@"roleInChurch"] forKey:@"roleInChurch"];
                    [profileInfo setObject:user[@"attendingChurch"] forKey:@"attendingChurch"];
                    [profileInfo setObject:user.objectId forKey:@"objectId"];
                    [profiles addObject:profileInfo];
                    //Save User profile info to parse
                    NSLog(@"User Object Id%@",user.objectId);
                
         

            }
            
            _contactList = [profiles copy];
           [self saveUsers:profiles];
            [self.tableView reloadData];
        }
       
    }];
    
 
}


-(void)retrieveCommunityProfilePicturesFromParse{
    
    
    PFQuery* queryForPictures = [PFUser query];
    //[queryForPictures includeKey:@"userPhoto"];
    
    
    [queryForPictures findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        NSLog(@"Finding pictures number of %i users ",[objects count]);
        
        for (PFUser *user in objects) {
            PFFile* pictureFile = user[@"userPhoto"];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"Getting Image data");
                UIImage* profileImage = [UIImage imageWithData:data];
                [self.profilePictures addObject:profileImage];
                NSLog(@"Profile pictures count %i",[self.profilePictures count]);
                [self.tableView reloadData];

            }];
        }
        
    }];
    
}

//TODO: Perform a PFQuery that excludes saved data

-(void)checkForNewUsersInParse {
    
    PFQuery* queryForNewUsers = [PFUser query];
    
    
    //[queryForNewUsers whereKey:@"objectId" notContainedIn:myArrayOfUserIds];
    
    //Count objects first to check for updates
    [queryForNewUsers countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if (number > 0) {
            //Update User list
            [queryForNewUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               
                
            }];
        }
    }];
}

#pragma mark - CoreData
//TODO: Save prevent saving a User twice
-(void)saveUserWithProfileInfo:(NSDictionary*)profileInfo{
 
    
    id delegate = [[UIApplication sharedApplication] delegate];
   NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error;
    
    //Query before saving
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"objectId == %@",profileInfo[@"objectId"]];
    [fetchRequest setPredicate:predicate];
    NSArray* fetchedUsers = [context executeFetchRequest:fetchRequest error:&error];
    
    //Save to core Data is profileInfo has not been persisted
    if ([fetchedUsers count] == 0) {
        User* user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        
        user.objectId = profileInfo[@"objectId"];
        user.name = profileInfo [@"name"];
        user.attendingChurch = profileInfo[@"attendingChurch"];
        user.roleInChurch = profileInfo[@"roleInChurch"];
        user.email = profileInfo[@"email"];
        
        
        BOOL saveSucceeded = [context save:&error];
        
        
        if (!saveSucceeded) {
            //We have an error savingo to CoreData
            NSLog(@"Couldnt persist to CoreData");
        }
    }

    
}

-(void)saveUsers:(NSArray*)usersInfo{
    
    for (NSDictionary* profileInfo in usersInfo) {
        [self saveUserWithProfileInfo:profileInfo];
    }
}

-(NSArray*)getSavedUserProfiles { //This Returns an array of User objects not dictionaries
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    NSError* error = nil;
    
    NSArray* fetchedUsers = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedUsers;
    
    
}
#pragma mark - Parse Helper Methods

-(NSArray*)usersToContactListDictionary:(NSArray*)fetchedUsers{
    NSMutableArray* newContactList =[[NSMutableArray alloc]init];

    for (User* user in fetchedUsers) {
        [newContactList addObject:[self dictionaryFromUser:user]];
    }
    return newContactList;
}

-(NSDictionary*)dictionaryFromUser:(User*)user{
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    
    if(user.name)[dictionary setObject:user.name forKey:@"name"];
    if(user.attendingChurch)[dictionary setObject:user.attendingChurch forKey:@"attendingChurch"];
    if(user.roleInChurch)[dictionary setObject:user.roleInChurch forKey:@"roleInChurch"];
    if(user.email)[dictionary setObject:user.email forKey:@"email"];
    if(user.objectId)[dictionary setObject:user.objectId forKey:@"objectId"];
    
    return dictionary;
}

-(void)setUser:(User*)user withDictionaryInfo:(NSDictionary*)profileInfo{
    
    user.objectId = profileInfo[@"objectId"];
    user.name = profileInfo [@"name"];
    user.attendingChurch = profileInfo[@"attendingChurch"];
    user.roleInChurch = profileInfo[@"roleInChurch"];
    user.email = profileInfo[@"email"];
    
}

@end
