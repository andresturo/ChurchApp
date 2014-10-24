//
//  PredicasTableViewController.h
//  AVPlayerApp
//
//  Created by Daniel Cardona on 8/31/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DisplayPlayer.h"
@interface PredicasTableViewController : UITableViewController <DisplayPlayerDelegate>
@property (strong,nonatomic) DisplayPlayer* player;
@property (strong,nonatomic) AVPlayerItem* playerItem;

@end
