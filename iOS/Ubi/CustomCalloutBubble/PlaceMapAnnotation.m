//
//  PlaceMapAnnotation.m
//  Ubi
//
//  Created by Rambod Rahmani on 04/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "PlaceMapAnnotation.h"

@interface PlaceMapAnnotation()

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end

@implementation PlaceMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

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

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	self.latitude = newCoordinate.latitude;
	self.longitude = newCoordinate.longitude;
}

- (id)copyWithZone:(NSZone *)zone
{
	PlaceMapAnnotation * copy = [[PlaceMapAnnotation allocWithZone:zone] init];
	
	copy.latitude = _latitude;
	copy.longitude = _longitude;
	copy.title = _title;
	copy.subtitle = _subtitle;
	copy.relatedUbiPlace = _relatedUbiPlace;
	
	return copy;
}

@end
