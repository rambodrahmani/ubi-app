//
//  UbiStatusComment.m
//  Ubi
//
//  Created by Rambod Rahmani on 31/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiStatusComment.h"

@implementation UbiStatusComment

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_status_id = [NSNumber numberWithInt:0];
	_user_id = [NSNumber numberWithInt:0];
	_comment_content_text = [NSString stringWithFormat:@""];
	_comment_date = [NSString stringWithFormat:@""];
	
	return self;
}

- (id)initWithParametersCommentID:(NSNumber *)db_id status_id:(NSNumber *)status_id user_id:(NSNumber *)user_id comment_content_text:(NSString *)comment_content_text comment_date:(NSString *)comment_date
{
	_db_id = db_id;
	_status_id = status_id;
	_user_id = user_id;
	_comment_content_text = comment_content_text;
	_comment_date = comment_date;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    UbiStatusComment * copy = [[UbiStatusComment allocWithZone:zone] init];
	
	copy.db_id = _db_id;
	copy.status_id = _status_id;
	copy.user_id = _user_id;
	copy.comment_content_text = _comment_content_text;
	copy.comment_date = _comment_date;
	
    return copy;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_db_id forKey:@"status_comment_db_id"];
	[encoder encodeObject:_status_id forKey:@"status_comment_status_id"];
	[encoder encodeObject:_user_id forKey:@"status_comment_user_id"];
	[encoder encodeObject:_comment_content_text forKey:@"status_comment_content_text"];
	[encoder encodeObject:_comment_date forKey:@"status_comment_date"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"status_comment_db_id"];
	_status_id = [decoder decodeObjectForKey:@"status_comment_status_id"];
	_user_id = [decoder decodeObjectForKey:@"status_comment_user_id"];
	_comment_content_text = [decoder decodeObjectForKey:@"status_comment_content_text"];
	_comment_date = [decoder decodeObjectForKey:@"status_comment_date"];
	
	return self;
}

- (id)postNewCommentWithUser_id:(NSNumber *)user_id status_id:(NSNumber *)status_id comment_text:(NSString *)comment_text
{
	__block UbiStatusComment * newComment;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
	NSNumber * timeZoneInMins = [NSNumber numberWithFloat:(float)(timeZoneOffset*60)];
	
	NSDictionary *params = @{@"user_id": user_id,
							 @"status_id": status_id,
							 @"comment_content_text": comment_text,
							 @"status_comment_date_utc_offset": timeZoneInMins,};
	
	[manager POST:[NSString stringWithFormat:@"%@/post_status_comment.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (![operation.responseString containsString:@"ERROR"]) {
			NSDateFormatter *formatter;
			NSString * commentDate;
			formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			commentDate = [formatter stringFromDate:[NSDate date]];
			
			newComment = [[UbiStatusComment alloc] initWithParametersCommentID:[NSNumber numberWithInt:[operation.responseString intValue]]
																	 status_id:status_id
																	   user_id:user_id
														  comment_content_text:comment_text
																  comment_date:commentDate];
		}
		else {
			[self showErrorMessage:operation.responseString];
		}
		
		dispatch_semaphore_signal(semaphore);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
		dispatch_semaphore_signal(semaphore);
	}];
	
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	return newComment;
}

- (void)dropComment
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"comment_id": _db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/drop_status_comment.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
	{	
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
