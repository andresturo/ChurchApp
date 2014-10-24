//
//  ViewController.m
//  MapViewApplication
//
//  Created by Daniel Cardona on 8/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "MapViewController.h"
#import "MapDetailsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    

    InfoRediles* rediles = [[InfoRediles alloc]init];
    _infoSedesRedil = [rediles sedesInfoArrayUsingLocalPlist];
    
    //Annotations.
    _mapview.delegate = self;
    [self fillDetailImages];
    _MapPins = [[NSMutableArray alloc]init];
    [self fillMapPins];
    
    [_mapview showAnnotations:_MapPins animated:YES];
    


}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Model Methods
-(void)fillMapPins{
    for (NSDictionary* info in _infoSedesRedil) {
          MapPin* pin = [[MapPin alloc] init];
        //MKPointAnnotation* pin = [[MKPointAnnotation alloc]init];
        
        pin.title = info[@"nombre"];
        pin.subtitle = [NSString stringWithFormat:@"%@, Tel: %@",info[ @"direccion"],info [ @"telefono"]];
        pin.coordinate = CLLocationCoordinate2DMake([info[ @"latitud"] doubleValue], [info[ @"longitud"]doubleValue]);
        
        pin.detailLink = info[ @"link"];
        
        [_MapPins addObject:pin];
        
    }
}

-(void)fillDetailImages{
    
    //Detail Images
    _detailImages = [[NSMutableDictionary alloc]init];
    for (NSDictionary* info in _infoSedesRedil) {
        NSString* imageName = info[ @"nombre"];
        NSLog(@"Nombre de imagen: %@",imageName);
        NSString* path = [[NSBundle mainBundle] pathForResource:imageName ofType: @"jpg"];
        UIImage* image = [[UIImage alloc]initWithContentsOfFile:path];
        if (image) {
            [_detailImages setObject:image forKey:imageName];
        }

        
        
    }
}

#pragma mark User Action

- (IBAction)setMap:(id)sender {
    
    UISegmentedControl* segment = (UISegmentedControl*)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:
            _mapview.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapview.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapview.mapType = MKMapTypeHybrid;
            
        default:
            break;
    }
}

- (IBAction)setMapToUserLocation:(id)sender {

    _mapview.showsUserLocation = YES;
    
}
#pragma mark Segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 
    if ([segue.identifier isEqualToString:@"detailsSegue"]) {
        NSLog(@"Details Segue fired");
        
        MapDetailsViewController* nextView = [segue destinationViewController];
        nextView.detailsTitle = [[sender annotation] title];
        nextView.detailsSubtitle = [[sender annotation] subtitle];
        nextView.image = _detailImages[[[sender annotation] title]];
        nextView.detailLink = [[sender annotation] detailLink];
        
        
    }

}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([ identifier isEqualToString:@"detailsSegue"]) {
        NSLog(@"Details segue has pushed");
        return YES;
    }
    return NO;
}


#pragma mark mapView Delegated Methods
//Delegated Methods
//-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//
//    _mapview.centerCoordinate = userLocation.location.coordinate;
//}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
   if ([view.annotation isKindOfClass:[MKUserLocation class]]){return;}
    if ([control isKindOfClass:[UIButton class]]) {
        
        MapDetailsViewController* detailsViewController = [[MapDetailsViewController alloc]init];
        UIStoryboardSegue* segue = [[UIStoryboardSegue alloc]initWithIdentifier:@"detailsSegue" source:self destination:detailsViewController];
        
       [self prepareForSegue:segue sender:view];
       [self performSegueWithIdentifier:@"detailsSegue" sender:view];
        //[self.navigationController pushViewController: detailsViewController animated:YES];

    }
    

    
    
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
           // pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            UIImageView* image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sheep-32.png"]];
            pinView.leftCalloutAccessoryView =image;
           // pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.image = [UIImage imageNamed:@"church-32.png"];
            pinView.calloutOffset = CGPointMake(-10, -10);
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
     
            pinView.rightCalloutAccessoryView = rightButton;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
    
}


@end
