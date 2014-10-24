//
//  SocialViewController.h
//  RedilApp
//
//  Created by Daniel Cardona on 9/8/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MapViewController.h"
#import "InfoRediles.h"


@interface SocialViewController : ViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong,nonatomic)NSArray* infoSedesRedil;

@end
