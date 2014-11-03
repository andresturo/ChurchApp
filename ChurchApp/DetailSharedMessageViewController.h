//
//  DetailSharedMessageViewController.h
//  ChurchApp
//
//  Created by Daniel Cardona on 11/3/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailSharedMessageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (strong,nonatomic) NSString* messageContentProxy;
@end
