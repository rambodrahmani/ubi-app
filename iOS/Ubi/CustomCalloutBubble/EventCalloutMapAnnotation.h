//
//  EventCalloutMapAnnotation.h
//  Ubi
//
//  Created by Rambod Rahmani on 20/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UbiEvent.h"
#import "EventMapAnnotation.h"

@interface EventCalloutMapAnnotation : NSObject <MKAnnotation>
{
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) EventMapAnnotation * eventMapAnnotation;

- (id)initWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;

@end
