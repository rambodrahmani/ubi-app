//
//  PlaceTypesTableViewCell.m
//  Ubi
//
//  Created by Rambod Rahmani on 19/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "PlaceTypesTableViewCell.h"

@implementation PlaceTypesTableViewCell

- (IBAction)switchPlaceValueChanged:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * sharedPlacesFilters = [defaults objectForKey:@"mapPlacesFilters"];
	NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedPlacesFilters];
	if (_switchPlace.isOn) {
		if (![filters containsObject:_place_type]) {
			[filters addObject:_place_type];
		}
	}
	else {
		[filters removeObject:_place_type];
	}
	
	[defaults setObject:filters forKey:@"mapPlacesFilters"];
}

@end
