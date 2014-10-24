//
//  MapDetailsViewController.h
//  MapViewApplication
//
//  Created by Daniel Cardona on 8/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MapViewController.h"
@interface MapDetailsViewController : ViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property NSString* detailsTitle;
@property NSString* detailsSubtitle;
@property NSString* detailLink;
@property (strong,nonatomic)UIImage* image;
- (IBAction)openRedilWebsite:(id)sender;

@end
