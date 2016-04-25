//
//  PlaceCalloutMapAnnotation.h
//  Ubi
//
//  Created by Rambod Rahmani on 21/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UbiPlace.h"
#import "PlaceMapAnnotation.h"

@interface PlaceCalloutMapAnnotation : NSObject <MKAnnotation>
{
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) PlaceMapAnnotation * placeMapAnnotation;

- (id)initWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;

@end
