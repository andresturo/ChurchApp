//
//  ViewController.h
//  MapViewApplication
//
//  Created by Daniel Cardona on 8/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import "InfoRediles.h"

@interface ViewController : UIViewController <MKMapViewDelegate>
    
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (strong, nonatomic) NSMutableArray* MapPins;
@property (strong,nonatomic)NSMutableDictionary* detailImages;
@property (strong,nonatomic)NSArray* infoSedesRedil;
- (IBAction)setMap:(id)sender;
- (IBAction)setMapToUserLocation:(id)sender;

@end
