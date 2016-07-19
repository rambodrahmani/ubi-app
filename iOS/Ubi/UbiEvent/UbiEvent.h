//
//  UbiEvent.h
//  Ubi
//
//  Created by Rambod Rahmani on 20/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "UbiPlace.h"

@interface UbiEvent : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * db_id;
@property (nonatomic, copy)	NSNumber * event_author_id;
@property (nonatomic, copy)	NSString * event_name;
@property (nonatomic, copy)	NSURL * event_picture_url;
@property (nonatomic, copy)	NSString * event_description;
@property (nonatomic, copy)	NSNumber * event_place_id;
@property (nonatomic, copy)	NSString * event_start_date;
@property (nonatomic, copy)	NSString * event_end_date;
@property (nonatomic, copy)	NSString * event_type;
@property (nonatomic, copy)	NSURL * event_website_url;
@property (nonatomic, copy)	NSURL * event_facebook_page_url;
@property (nonatomic, retain) NSMutableArray * event_participants_ids;

@property (nonatomic, copy)	UbiPlace * relatedUbiPlace;

- (id)init;
- (id)initWithParametersEventID:(NSNumber *)db_id event_author_id:(NSNumber *)event_author_id event_name:(NSString *)event_name event_picture_url:(NSURL *)event_picture_url event_description:(NSString *)event_description event_place_id:(NSNumber *)event_place_id event_start_date:(NSString *)event_start_date event_end_date:(NSString *)event_end_date event_type:(NSString *)event_type event_website_url:(NSURL *)event_website_url event_facebook_page_url:(NSURL *)event_facebook_page_url event_participants_ids:(NSMutableArray *)event_participants_ids relatedUbiPlace:(UbiPlace *)relatedUbiPlace;

@end
