//
//  UbiAddress.m
//  Ubi
//
//  Created by Rambod Rahmani on 04/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "UbiPlace.h"

@implementation UbiPlace

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_place_name = [NSString stringWithFormat:@""];
	_place_lat = [NSNumber numberWithInt:0];
	_place_lon = [NSNumber numberWithInt:0];
	_place_icon_url = [NSURL URLWithString:@""];
	_place_string = [NSString stringWithFormat:@""];
	_place_google_id = [NSString stringWithFormat:@""];
	_place_rating = [NSNumber numberWithInt:0];
	_place_types = [NSString stringWithFormat:@""];
	_place_website_url = [NSURL URLWithString:@""];
	_place_phone_number = [NSString stringWithFormat:@""];
	_place_int_phone_number = [NSString stringWithFormat:@""];
	_place_utc_offset = [NSNumber numberWithInt:0];
	_place_google_url = [NSURL URLWithString:@""];
	_place_cover_pic = [NSURL URLWithString:@""];
	_place_distance = [NSNumber numberWithInt:0];
	
	return self;
}

- (id)initWithParameters_db_id:(NSNumber *)db_id place_name:(NSString *)place_name place_lat:(NSNumber *)place_lat place_lon:(NSNumber *)place_lon place_icon_url:(NSURL *)place_icon_url place_string:(NSString *)place_string place_google_id:(NSString *)place_google_id place_rating:(NSNumber *)place_rating place_types:(NSString *)place_types place_website_url:(NSURL *)place_website_url place_phone_number:(NSString *)place_phone_number place_int_phone_number:(NSString *)place_int_phone_number place_utc_offset:(NSNumber *)place_utc_offset place_google_url:(NSURL *)place_google_url place_cover_pic:(NSURL *)place_cover_pic place_distance:(NSNumber *)place_distance
{
	_db_id = db_id;
	_place_name = place_name;
	_place_lat = place_lat;
	_place_lon = place_lon;
	_place_icon_url = place_icon_url;
	_place_string = place_string;
	_place_google_id = place_google_id;
	_place_rating = place_rating;
	_place_types = place_types;
	_place_website_url = place_website_url;
	_place_phone_number = place_phone_number;
	_place_int_phone_number = place_int_phone_number;
	_place_utc_offset = place_utc_offset;
	_place_google_url = place_google_url;
	_place_cover_pic = place_cover_pic;
	_place_distance = place_distance;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    UbiPlace * copy = [[UbiPlace allocWithZone:zone] init];
	
	copy.db_id = _db_id;
	copy.place_name = _place_name;
	copy.place_lat = _place_lat;
	copy.place_lon = _place_lon;
	copy.place_icon_url = _place_icon_url;
	copy.place_string = _place_string;
	copy.place_google_id = _place_google_id;
	copy.place_rating = _place_rating;
	copy.place_types = _place_types;
	copy.place_website_url = _place_website_url;
	copy.place_phone_number = _place_phone_number;
	copy.place_int_phone_number = _place_int_phone_number;
	copy.place_utc_offset = _place_utc_offset;
	copy.place_google_url = _place_google_url;
	copy.place_cover_pic = _place_cover_pic;
	copy.place_distance = _place_distance;
	
    return copy;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_db_id forKey:@"place_db_id"];
	[encoder encodeObject:_place_name forKey:@"place_name"];
	[encoder encodeObject:_place_lat forKey:@"place_lat"];
	[encoder encodeObject:_place_lon forKey:@"place_lon"];
	[encoder encodeObject:_place_icon_url forKey:@"place_icon_url"];
	[encoder encodeObject:_place_string forKey:@"place_string"];
	[encoder encodeObject:_place_google_id forKey:@"place_google_id"];
	[encoder encodeObject:_place_rating forKey:@"place_rating"];
	[encoder encodeObject:_place_types forKey:@"place_types"];
	[encoder encodeObject:_place_website_url forKey:@"place_website_url"];
	[encoder encodeObject:_place_phone_number forKey:@"place_phone_number"];
	[encoder encodeObject:_place_int_phone_number forKey:@"place_int_phone_number"];
	[encoder encodeObject:_place_utc_offset forKey:@"place_utc_offset"];
	[encoder encodeObject:_place_google_url forKey:@"place_google_url"];
	[encoder encodeObject:_place_cover_pic forKey:@"place_cover_pic"];
	[encoder encodeObject:_place_distance forKey:@"place_distance"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"place_db_id"];
	_place_name = [decoder decodeObjectForKey:@"place_name"];
	_place_lat = [decoder decodeObjectForKey:@"place_lat"];
	_place_lon = [decoder decodeObjectForKey:@"place_lon"];
	_place_icon_url = [decoder decodeObjectForKey:@"place_icon_url"];
	_place_string = [decoder decodeObjectForKey:@"place_string"];
	_place_google_id = [decoder decodeObjectForKey:@"place_google_id"];
	_place_rating = [decoder decodeObjectForKey:@"place_rating"];
	_place_types = [decoder decodeObjectForKey:@"place_types"];
	_place_website_url = [decoder decodeObjectForKey:@"place_website_url"];
	_place_phone_number = [decoder decodeObjectForKey:@"place_phone_number"];
	_place_int_phone_number = [decoder decodeObjectForKey:@"place_int_phone_number"];
	_place_utc_offset = [decoder decodeObjectForKey:@"place_utc_offset"];
	_place_google_url = [decoder decodeObjectForKey:@"place_google_url"];
	_place_cover_pic = [decoder decodeObjectForKey:@"place_cover_pic"];
	_place_distance = [decoder decodeObjectForKey:@"place_distance"];
	
	return self;
}

@end
