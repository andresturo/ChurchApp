//
//  SettingsViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/11/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *profileImageButton;

@property (strong,nonatomic)NSString* userName;
@property (strong,nonatomic) NSString* userEmail;
@property (strong, nonatomic) NSString* roleInChurch;
@property (strong, nonatomic) NSString* attendingChurch;
@property (strong,nonatomic) NSArray* firstSectionSettingNames;
@end

@implementation SettingsViewController

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
    self.firstSectionSettingNames = @[@"Attending Church",@"Role in Church"];
    self.profileImageButton.layer.cornerRadius = self.profileImageButton.frame.size.width/2;
    self.userNameTextField.tag = 0;
    self.userEmailTextField.tag = 1;
    
    //Recieve notifications from detailed settings view controllers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedChurch:) name:@"selectedAChurch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedRole:) name:@"selectedARole" object:nil];
    
    //Update with NSUserDefaults Persisted Data

    [self recoverProfileImage];
    [self recoverTableViewSettings];
    [self recoverUserName];
    [self recoverUserEmail];



}
-(void)viewDidAppear:(BOOL)animated{
    




}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)saveBarButtonPressed:(id)sender {
    
    [self pushUserSettingsToParse];
    
}

#pragma mark - Callbacks for NSNotifications

-(void)updateSelectedChurch:(NSNotification*)notification{
    NSString* selectedChurch = notification.userInfo[@"attendingChurch"];
    self.attendingChurch =selectedChurch;
    [[NSUserDefaults standardUserDefaults]setObject: selectedChurch forKey:@"attendingChurch"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self.tableView reloadData];
    
}

-(void)updateSelectedRole:(NSNotification*)notification{
    
    NSString* selectedRole = notification.userInfo[@"roleInChurch"];
    self.roleInChurch= selectedRole;
    [[NSUserDefaults standardUserDefaults]setObject:selectedRole forKey:@"roleInChurch"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self.tableView reloadData];
    
}
#pragma mark - NSUserDefaults

-(void)recoverProfileImage{
    
    //Get profile image from NSUserDefaults
    NSData* imageData =[[NSUserDefaults standardUserDefaults] objectForKey:@"profileImage"];
    UIImage* image = [UIImage imageWithData:imageData];
    
    [_profileImageButton setImage:image forState:UIControlStateNormal];
}
-(void)recoverUserName{
    NSString* savedUserName =  [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserName"];

    self.userNameTextField.text =savedUserName;
    NSLog(@"User name %@",savedUserName);
}
-(void)recoverUserEmail{
    NSString* savedUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserEmail"];
    
    self.userEmailTextField.text =savedUserEmail;
    NSLog(@"User name %@",savedUserEmail);
}
-(void)recoverTableViewSettings{
    
    self.attendingChurch = [[NSUserDefaults standardUserDefaults] objectForKey:@"attendingChurch"];
    self.roleInChurch = [[NSUserDefaults standardUserDefaults] objectForKey:@"roleInChurch"];
    NSLog(@"recovered %@",self.attendingChurch);
    [self.tableView reloadData];
    
}


#pragma mark - UITableView data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfSections;
    switch (section) {
        case 0:
            numberOfSections = [self.firstSectionSettingNames count];
            break;
        case 1:
            numberOfSections =1;
        default:
            break;
    }
    return numberOfSections;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.firstSectionSettingNames[indexPath.row];

            if (indexPath.row == 0 ) {
                cell.detailTextLabel.text = self.attendingChurch;
            }else if (indexPath.row == 1){
                
                cell.detailTextLabel.text = self.roleInChurch;
            }
            break;
        case 1:
            
            cell.textLabel.text = @"Privacy Settings";
            cell.detailTextLabel.hidden = YES;
            
        default:
            break;
    }


    
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* titleForHeader = nil;
    switch (section) {
        case 0:
            titleForHeader = @"Church Status";
            break;
        case 1:
            titleForHeader = @"Privacy Settings";
            break;
            
        default:
            break;
    }
    return titleForHeader;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"toAttendingChurch" sender:nil];
                
            }else if(indexPath.row == 1) {
                [self performSegueWithIdentifier:@"toRoleInChurch" sender:nil];
            }
            break;
            
        case 1:
            
            [self performSegueWithIdentifier:@"toPrivacySettingsSegue" sender:nil];
            
            break;
            
        default:
            break;
    }

    
}
#pragma mark - UITextField Delegate


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //[[NSUserDefaults standardUserDefaults]setObject:textField.text forKey:@"userName"];

    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            
            if (textField.text.length < 5) {
                UIAlertView* alertView = [[UIAlertView alloc ]initWithTitle:@"Are you shure?" message:@"Make shure you have submitted your full name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView setAlertViewStyle:UIAlertViewStyleDefault];
                [alertView show];
            }else{
                NSLog(@"Saving %@ as username", textField.text);
                [[NSUserDefaults standardUserDefaults]setObject:textField.text forKey:@"currentUserName"];
            }
            
            break;
        
            case 1:
            
            if (textField.text.length < 5) {
                UIAlertView* alertView = [[UIAlertView alloc ]initWithTitle:@"Are you shure?" message:@"Make shure you have submitted a correct email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView setAlertViewStyle:UIAlertViewStyleDefault];
                [alertView show];
            }else{
                NSLog(@"Saving %@ as userEmail", textField.text);
                [[NSUserDefaults standardUserDefaults]setObject:textField.text forKey:@"currentUserEmail"];
            }
            
         
            
        default:
            break;
    }

}


- (IBAction)chooseProfilePictureButtonPressed:(id)sender {
    
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    
    [_profileImageButton setImage:image forState:UIControlStateNormal];
    
    
    //Persist to NSUser Desfaults
    NSData* imageData = UIImageJPEGRepresentation(image, 0.8);
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"profileImage"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //Push imageFile to parse
    
    [self pushProfilePictureToParse:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parse

-(void)pushUserSettingsToParse {

    [[PFUser currentUser] setObject:self.attendingChurch forKey:@"attendingChurch"];
    [[PFUser currentUser] setObject:self.roleInChurch forKey:@"roleInChurch"];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Pushed");
            
        }
    }];
}

-(void)pushProfilePictureToParse:(UIImage*)image{
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"Image data was not found");
        return;
    }
    
    PFFile* photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[PFUser currentUser] setObject:photoFile forKey:@"userPhoto"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved succesfully");
            }];
        }
    }];
}












@end
