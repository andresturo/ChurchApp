//
//  MULoginViewController.m
//  MatchedUp
//
//  Created by Daniel Cardona on 9/29/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MULoginViewController.h"

@interface MULoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic)NSMutableData* imageData;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@end

@implementation MULoginViewController

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
    
    self.activityIndicator.hidden = YES;
    self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width/2;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)loginButtonPressed:(id)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    //This is an array containing profile information
    NSArray* permissionsArray = @[@"public_profile",@"email",@"user_location"];
    
    //This will show FB alert view asking for permissions
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        //Show Alert Views
        if (!user) {
            if (!error) {
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Loggin Error" message:@"The facebook login was canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            } else {
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Loggin Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            
        }else {
            [self updateUserInformation];
            NSLog(@"Login Complete");
        }
        
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];

    }];
}

#pragma mark - Helper Methods 

-(void)updateUserInformation{
    FBRequest* request = [FBRequest requestForMe];
    
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSDictionary* userDictionary = (NSDictionary*)result;//result is a JSON response
            //NSLog(@"User Dictionary %@",userDictionary);
            
            //Create URL
            NSString* facebookID = userDictionary[@"id"];
            NSURL* pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
            
            NSMutableDictionary* userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            
            if (userDictionary[@"name"]) {
                userProfile[kMUUserProfileNameKey] = userDictionary[@"name" ];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kMUUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]){
                userProfile[kMUUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kMUUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kMUUserProfileBirthdayKey]=userDictionary[@"birthday"];
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate* date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate* now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds/31536000;
                userProfile[kMUUserProfileAgeKey] = @(age);
            }
            if (userDictionary[ @"email"]) {
                userProfile[@"email"]=userDictionary [@"email"];
            }
            

            
            if ([pictureURL absoluteString]) {
                userProfile[kMUUserProfilePictureURL] = [pictureURL absoluteString];
            }
            [self notifyObserversOfFacebookLogin:userProfile];
            
            [[PFUser currentUser]setObject:userProfile forKey:kMUUserProfileKey];
            [[PFUser currentUser]saveInBackground];
            [self requestImage];
        }else {
            
            NSLog(@"Error in FB request %@",error);
        }
    }];
}

-(void)upLoadPFFileToParse:(UIImage*)image{
    
    NSData* imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"Image data was not found");
        return;
    }
    
    PFFile* photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //A class name is a namespace under which other objects are stored or queried for
            PFObject* photo = [PFObject objectWithClassName:kMUPhotoClassKey];
            //photo class will have a user key value pair, is current a user a pointer and not the actual object?
            [photo setObject:[PFUser currentUser] forKey:kMUPhotoUserKey];
            //photo class will have a photofile key value pair
            [photo setObject:photoFile forKey:kMUPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved succesfully");
            }];
        }
    }];
}

-(void)requestImage{
    
    //This querys for a class visually like a row
    PFQuery* query = [PFQuery queryWithClassName:kMUPhotoClassKey];
    //Then query even further by objects inside class, visually like columns
    [query whereKey:kMUPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            
            PFUser* user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            NSURL* profilePictureURL = [NSURL URLWithString:user[kMUUserProfileKey][kMUUserProfilePictureURL]];
            NSURLRequest* urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            NSURLConnection* urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            if (!urlRequest) {
                NSLog(@"Failed to download picture");
            }
        }
        
    }];
}

#pragma mark - NSURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [self.imageData appendData:data];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    UIImage* profileImage = [UIImage imageWithData:self.imageData];
    [self upLoadPFFileToParse:profileImage];
    
}

#pragma mark - NSNotification 

-(void)notifyObserversOfFacebookLogin:(NSDictionary*)userProfile{
    NSLog(@"Notifying about fb login");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLogin" object:self userInfo:userProfile];
}


     
     
     
     
     
     
     

@end
