//
//  SocialViewController.m
//  RedilApp
//
//  Created by Daniel Cardona on 9/8/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "SocialViewController.h"
#import "ExpandingTableViewCell.h"


@interface SocialViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSIndexPath* selectedRowIndex;
@property (nonatomic)int selectedIndex;
@property (nonatomic) BOOL shouldExtraExpand;

@end


@implementation SocialViewController
@synthesize selectedIndex = selectedIndex;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    selectedIndex =-1; //Meaning no row is selected or should be expanded
    
    InfoRediles* rediles = [[InfoRediles alloc]init];
    self.infoSedesRedil =[rediles sedesInfoArrayUsingLocalPlist];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableView delegate methods 

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.selectedRowIndex = indexPath;
//    [tableView beginUpdates];
//    [tableView endUpdates];
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //check if the index actually exists
//    if(_selectedRowIndex && indexPath.row == _selectedRowIndex.row) {
//        return 100;
//    }
//    return 44;
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSLog(@"Did select indexpath row %i",indexPath.row);
    ExpandingTableViewCell* cell =(ExpandingTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.scheduledServicesButton.selected = NO;
    
    //taps expanded cell
    if (selectedIndex == indexPath.row) {
        selectedIndex = -1;
        _shouldExtraExpand = NO;
        [self.tableView beginUpdates];[self.tableView endUpdates];
        //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
        return;
    }
    
    //User taps different row
    
    if (selectedIndex != -1) {
        _shouldExtraExpand = NO;
       // NSIndexPath* prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [self.tableView beginUpdates];[self.tableView endUpdates];
        //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationFade];
       
    }
    
    //User taps row with none expanded
    selectedIndex = indexPath.row;
    [self.tableView beginUpdates];[self.tableView endUpdates];
   // [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if(_shouldExtraExpand && selectedIndex == indexPath.row) {
        return 210;
    }
    
    if (selectedIndex == indexPath.row) {
        return 110;
    }else{
        return  46;

    }
   
}


#pragma mark UItableview datasource methods 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.infoSedesRedil count];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ExpandingTableViewCell* cell = (ExpandingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"expandingCell"];
    

    cell.clipsToBounds = YES; //super important!!

    // Configure button actions
    [cell.youtubeButton addTarget:self action:@selector(openYoutubeChannel:) forControlEvents:UIControlEventTouchUpInside];
    [cell.facebookButton addTarget:self action:@selector(openFacebookProfile:) forControlEvents:UIControlEventTouchUpInside];
    [cell.scheduledServicesButton addTarget:self action:@selector(showScheduledServices:) forControlEvents:UIControlEventTouchUpInside];
    [cell.websiteLinkButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
   
    //Button Tags
    cell.scheduledServicesButton.tag = indexPath.row;
    cell.facebookButton.tag = indexPath.row;
    cell.youtubeButton.tag = indexPath.row;
    cell.websiteLinkButton.tag = indexPath.row;
    
    //Make cell button toggle tint color
    UIImage* image = [cell.scheduledServicesButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [ cell.scheduledServicesButton setImage:image forState:UIControlStateSelected];
  
    
    NSDictionary* infoSede = [self.infoSedesRedil objectAtIndex:indexPath.row ];
    
    //Disable buttons if no string
    if ([infoSede[@"facebookId"] length] == 0 ) {
        [cell.facebookButton setEnabled:NO];
    }else {
        
        [cell.facebookButton setEnabled:YES];
    }
    if ([infoSede[@"youtubeChannel"] length] == 0) {
        [cell.youtubeButton setEnabled:NO];
    } else {
        
        [cell.youtubeButton setEnabled:YES];
    }
    
    cell.titleLabel.text = infoSede[@"nombre"];
    cell.detailedInfoLabel.text = infoSede[ @"direccion"];
    cell.scheduledServicesLabel.text = [infoSede[ @"servicios"] stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    

    
    
    return cell;
}

#pragma mark IBActions

- (IBAction)openFacebookProfile:(UIButton*)sender {
    

    NSString *profileName = self.infoSedesRedil[sender.tag][@"facebookId"];
    
        NSURL *linkToAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@",profileName]];
        NSURL *linkToWebURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@",profileName]];
        
        if ([[UIApplication sharedApplication] canOpenURL:linkToAppURL]) {
            // Can open the youtube app URL so launch the youTube app with this URL
            [[UIApplication sharedApplication] openURL:linkToAppURL];
        }
        else{
            // Can't open the youtube app URL so launch Safari instead
            [[UIApplication sharedApplication] openURL:linkToWebURL];
        }
    

}

- (IBAction)openYoutubeChannel:(UIButton*)sender {
    
    NSString *channelName = self.infoSedesRedil[sender.tag][@"youtubeChannel"];
    NSLog(@"Youtube Channel: %@",channelName);
    
        NSURL *linkToAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"youtube://www.youtube.com/user/%@",channelName]];
        NSURL *linkToWebURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/user/%@",channelName]];
        
        if ([[UIApplication sharedApplication] canOpenURL:linkToAppURL]) {
            // Can open the youtube app URL so launch the youTube app with this URL
            [[UIApplication sharedApplication] openURL:linkToAppURL];
        }
        else{
            // Can't open the youtube app URL so launch Safari instead
            [[UIApplication sharedApplication] openURL:linkToWebURL];
        }
  
}

-(IBAction)showScheduledServices:(UIButton*)sender{

    NSIndexPath* path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
   // ExpandingTableViewCell* expCell =(ExpandingTableViewCell*) [self.tableView cellForRowAtIndexPath:path];
    
    selectedIndex = path.row;
    sender.selected = !sender.selected;
    _shouldExtraExpand = sender.selected;
    


    [self.tableView beginUpdates];[self.tableView endUpdates];
    

    
}
-(void)openWebsite:(UIButton*)sender{
    
    NSString* detailLink = self.infoSedesRedil[sender.tag][ @"link"];
    if ([detailLink length] == 0) {
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:detailLink]];

}
@end
