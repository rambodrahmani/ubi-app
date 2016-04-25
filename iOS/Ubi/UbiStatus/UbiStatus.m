//
//  UbiPost.m
//  Ubi
//
//  Created by Rambod Rahmani on 14/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiStatus.h"

@implementation UbiStatus

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_author_id = [NSNumber numberWithInt:0];
	_content_text = [NSString stringWithFormat:@""];;
	_status_date = [NSString stringWithFormat:@""];;
	_content_media = [NSURL URLWithString:@""];
	_likes_array = [[NSArray alloc] init];
	_comments_num = [NSNumber numberWithInt:0];
	_status_place = [[UbiPlace alloc] init];
	_tags = [[NSArray alloc] init];
	
	return self;
}

- (id)initWithParametersStatusID:(NSNumber* )db_id author_id:(NSNumber *)author_id content_media:(NSURL *)content_media content_text:(NSString *)content_text status_date:(NSString *)status_date likes_array:(NSArray *)likes_array comments_num:(NSNumber* )comments_num status_place:(UbiPlace *)status_place tags:(NSArray *)tags
{
    _db_id = db_id;
    _author_id = author_id;
    _content_text = content_text;
    _status_date = status_date;
    _content_media = content_media;
	_likes_array = likes_array;
	_comments_num = comments_num;
	_status_place = status_place;
	_tags = tags;
	
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    UbiStatus * copy = [[UbiStatus allocWithZone:zone] init];
    
	copy.db_id = _db_id;
	copy.author_id = _author_id;
	copy.content_text = _content_text;
	copy.status_date = _status_date;
	copy.content_media = _content_media;
	copy.likes_array = _likes_array;
	copy.comments_num = _comments_num;
	copy.status_place = _status_place;
	copy.tags = _tags;
	
    return copy;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_db_id forKey:@"status_db_id"];
    [encoder encodeObject:_author_id forKey:@"status_author_id"];
    [encoder encodeObject:_content_text forKey:@"status_content_text"];
    [encoder encodeObject:_status_date forKey:@"status_status_date"];
    [encoder encodeObject:_content_media forKey:@"status_content_media"];
	[encoder encodeObject:_likes_array forKey:@"status_likes_array"];
	[encoder encodeObject:_comments_num forKey:@"status_comments_num"];
	[encoder encodeObject:_status_place forKey:@"status_place"];
	[encoder encodeObject:_tags forKey:@"status_tags"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"status_db_id"];
	_author_id = [decoder decodeObjectForKey:@"status_author_id"];
	_content_text = [decoder decodeObjectForKey:@"status_content_text"];
	_status_date = [decoder decodeObjectForKey:@"status_status_date"];
	_content_media = [decoder decodeObjectForKey:@"status_content_media"];
	_likes_array = [decoder decodeObjectForKey:@"status_likes_array"];
	_comments_num = [decoder decodeObjectForKey:@"status_comments_num"];
	_status_place = [decoder decodeObjectForKey:@"status_place"];
    _tags = [decoder decodeObjectForKey:@"status_tags"];
	
    return self;
}

- (void)dropStatus
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"status_id": _db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/drop_status.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if ([operation.responseString containsString:@"ERROR"]) {
			[self showErrorMessage:operation.responseString];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
