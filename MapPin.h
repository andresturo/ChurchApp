//
//  MapPin.h
//  MapViewApplication
//
//  Created by Daniel Cardona on 8/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapPin : MKPointAnnotation 

@property NSString* detailLink;
@property NSString* detailInformation;



@end

