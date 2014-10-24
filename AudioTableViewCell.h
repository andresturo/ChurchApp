//
//  AudioTableViewCell.h
//  AVPlayerApp
//
//  Created by Daniel Cardona on 8/31/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioTableViewCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UISlider* slider;
@property (strong,nonatomic) IBOutlet UIButton* playPauseButton;
@property (strong,nonatomic) IBOutlet UILabel* title;
@property (strong,nonatomic) IBOutlet UILabel* meta;
@property (strong,nonatomic) IBOutlet UILabel* timeProgress;

@end
