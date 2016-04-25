//
//  PlaceCalloutMapAnnotation.m
//  Ubi
//
//  Created by Rambod Rahmani on 20/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "PlaceCalloutMapAnnotation.h"

@interface PlaceCalloutMapAnnotation()


@end

@implementation PlaceCalloutMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude
{
	if (self = [super init])
	{
		self.latitude = latitude;
		self.longitude = longitude;
	}
	
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;

	return coordinate;
}

@end
