//
//  TargetGroupTableViewCell.h
//  RedilApp
//
//  Created by Daniel Cardona on 10/16/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TargetGroupTableViewCell : UITableViewCell

@property (strong,nonatomic)IBOutlet UIButton* roleButton;
@property (strong,nonatomic)IBOutlet UILabel* titleLabel;
@property (strong,nonatomic)IBOutlet UILabel* subtitleLabel;


@end
