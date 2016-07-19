//
//  UbiStatusLike.m
//  Ubi
//
//  Created by Rambod Rahmani on 12/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "UbiStatusLike.h"

@implementation UbiStatusLike

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (id)init {
	_status_id = [NSNumber numberWithInt:0];
	_user_id = [NSNumber numberWithInt:0];
	
	return self;
}

- (id)initWithParametersStatusID:(NSNumber *)status_id user_id:(NSNumber *)user_id {
	_status_id = status_id;
	_user_id = user_id;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	UbiStatusLike * copy = [[UbiStatusLike allocWithZone:zone] init];
	
	copy.status_id = _status_id;
	copy.user_id = _user_id;
	
	return copy;
}

- (void)postLike
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"status_id": _status_id,
							 @"user_id": _user_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/post_status_like.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if ([operation.responseString containsString:@"ERROR"]) {
			[self showErrorMessage:operation.responseString];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

- (void)dropLike
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"status_id": _status_id,
							 @"user_id": _user_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/drop_status_like.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
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
