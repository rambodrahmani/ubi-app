//
//  EventMapAnnotation.h
//  Ubi
//
//  Created by Rambod Rahmani on 20/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FTGooglePlacesAPI.h"
#import "UbiEvent.h"

@interface EventMapAnnotation : NSObject <MKAnnotation, NSCopying> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
	NSString *_title;
    NSString *_subtitle;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) UbiEvent * relatedUbiEvent;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
