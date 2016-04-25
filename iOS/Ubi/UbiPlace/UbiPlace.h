//
//  UbiAddress.h
//  Ubi
//
//  Created by Rambod Rahmani on 04/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

@interface UbiPlace : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * db_id;
@property (nonatomic, copy)	NSString * place_name;
@property (nonatomic, copy)	NSNumber * place_lat;
@property (nonatomic, copy)	NSNumber * place_lon;
@property (nonatomic, copy)	NSURL * place_icon_url;
@property (nonatomic, copy)	NSString * place_string;
@property (nonatomic, copy)	NSString * place_google_id;
@property (nonatomic, copy)	NSNumber * place_rating;
@property (nonatomic, copy)	NSString * place_types;
@property (nonatomic, copy)	NSURL * place_website_url;
@property (nonatomic, copy)	NSString * place_phone_number;
@property (nonatomic, copy)	NSString * place_int_phone_number;
@property (nonatomic, copy)	NSNumber * place_utc_offset;
@property (nonatomic, copy)	NSURL * place_google_url;
@property (nonatomic, copy)	NSURL * place_cover_pic;
@property (nonatomic, copy)	NSNumber * place_distance;

- (id)init;
- (id)initWithParameters_db_id:(NSNumber *)db_id place_name:(NSString *)place_name place_lat:(NSNumber *)place_lat place_lon:(NSNumber *)place_lon place_icon_url:(NSURL *)place_icon_url place_string:(NSString *)place_string place_google_id:(NSString *)place_google_id place_rating:(NSNumber *)place_rating place_types:(NSString *)place_types place_website_url:(NSURL *)place_website_url place_phone_number:(NSString *)place_phone_number place_int_phone_number:(NSString *)place_int_phone_number place_utc_offset:(NSNumber *)place_utc_offset place_google_url:(NSURL *)place_google_url place_cover_pic:(NSURL *)place_cover_pic place_distance:(NSNumber *)place_distance;

@end
