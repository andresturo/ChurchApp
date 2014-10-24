//
//  ExpandingTableViewCell.h
//  RedilApp
//
//  Created by Daniel Cardona on 9/9/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailedInfoLabel;
@property (strong, nonatomic) IBOutlet UIButton *youtubeButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *scheduledServicesButton;
@property (strong,nonatomic) IBOutlet UIButton *websiteLinkButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduledServicesLabel;
@end
