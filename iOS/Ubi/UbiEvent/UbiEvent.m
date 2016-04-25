//
//  UbiEvent.m
//  Ubi
//
//  Created by Rambod Rahmani on 14/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiEvent.h"

@implementation UbiEvent

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_event_author_id = [NSNumber numberWithInt:0];
	_event_name = [NSString stringWithFormat:@""];
	_event_picture_url = [NSURL URLWithString:@""];
	_event_description = [NSString stringWithFormat:@""];
	_event_place_id = [NSNumber numberWithInt:0];
	_event_start_date = [NSString stringWithFormat:@""];
	_event_end_date = [NSString stringWithFormat:@""];
	_event_type = [NSString stringWithFormat:@""];
	_event_website_url = [NSURL URLWithString:@""];
	_event_facebook_page_url = [NSURL URLWithString:@""];
	_event_participants_ids = [[NSMutableArray alloc] init];
	
	_relatedUbiPlace = [[UbiPlace alloc] init];
	
	return self;
}

- (id)initWithParametersEventID:(NSNumber *)db_id event_author_id:(NSNumber *)event_author_id event_name:(NSString *)event_name event_picture_url:(NSURL *)event_picture_url event_description:(NSString *)event_description event_place_id:(NSNumber *)event_place_id event_start_date:(NSString *)event_start_date event_end_date:(NSString *)event_end_date event_type:(NSString *)event_type event_website_url:(NSURL *)event_website_url event_facebook_page_url:(NSURL *)event_facebook_page_url event_participants_ids:(NSMutableArray *)event_participants_ids relatedUbiPlace:(UbiPlace *)relatedUbiPlace
{
	_db_id = db_id;
	_event_author_id = event_author_id;
	_event_name = event_name;
	_event_picture_url = event_picture_url;
	_event_description = event_description;
	_event_place_id = event_place_id;
	_event_start_date = event_start_date;
	_event_end_date = event_end_date;
	_event_type = event_type;
	_event_website_url = event_website_url;
	_event_facebook_page_url = event_facebook_page_url;
	_event_participants_ids = event_participants_ids;
	
	_relatedUbiPlace = relatedUbiPlace;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    UbiEvent * copy = [[UbiEvent allocWithZone:zone] init];
	
	copy.db_id = _db_id;
	copy.event_author_id = _event_author_id;
	copy.event_name = _event_name;
	copy.event_picture_url = _event_picture_url;
	copy.event_description = _event_description;
	copy.event_place_id = _event_place_id;
	copy.event_start_date = _event_start_date;
	copy.event_end_date = _event_end_date;
	copy.event_type = _event_type;
	copy.event_website_url = _event_website_url;
	copy.event_facebook_page_url = _event_facebook_page_url;
	copy.event_participants_ids = _event_participants_ids;
	
	copy.relatedUbiPlace = _relatedUbiPlace;
	
    return copy;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_db_id forKey:@"event_db_id"];
	[encoder encodeObject:_event_author_id forKey:@"event_author_id"];
	[encoder encodeObject:_event_name forKey:@"event_name"];
	[encoder encodeObject:_event_picture_url forKey:@"event_picture_url"];
	[encoder encodeObject:_event_description forKey:@"event_description"];
	[encoder encodeObject:_event_place_id forKey:@"event_place_id"];
	[encoder encodeObject:_event_start_date forKey:@"event_start_date"];
	[encoder encodeObject:_event_end_date forKey:@"event_end_date"];
	[encoder encodeObject:_event_type forKey:@"event_type"];
	[encoder encodeObject:_event_website_url forKey:@"event_website_url"];
	[encoder encodeObject:_event_facebook_page_url forKey:@"event_facebook_page_url"];
	[encoder encodeObject:_event_participants_ids forKey:@"event_participants_ids"];
	
	[encoder encodeObject:_relatedUbiPlace forKey:@"event_relatedUbiPlace"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"event_db_id"];
	_event_author_id = [decoder decodeObjectForKey:@"event_author_id"];
	_event_name = [decoder decodeObjectForKey:@"event_name"];
	_event_picture_url = [decoder decodeObjectForKey:@"event_picture_url"];
	_event_description = [decoder decodeObjectForKey:@"event_description"];
	_event_place_id = [decoder decodeObjectForKey:@"event_place_id"];
	_event_start_date = [decoder decodeObjectForKey:@"event_start_date"];
	_event_end_date = [decoder decodeObjectForKey:@"event_end_date"];
	_event_type = [decoder decodeObjectForKey:@"event_type"];
	_event_website_url = [decoder decodeObjectForKey:@"event_website_url"];
	_event_facebook_page_url = [decoder decodeObjectForKey:@"event_facebook_page_url"];
	_event_participants_ids = [decoder decodeObjectForKey:@"event_participants_ids"];
	
	_relatedUbiPlace = [decoder decodeObjectForKey:@"event_relatedUbiPlace"];
	
	return self;
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
