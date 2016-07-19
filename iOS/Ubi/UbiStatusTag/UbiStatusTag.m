//
//  UbiStatusTag.m
//  Ubi
//
//  Created by Rambod Rahmani on 12/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "UbiStatusTag.h"

@implementation UbiStatusTag

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (id)init {
	_status_id = [NSNumber numberWithInt:0];
	_user_id = [NSNumber numberWithInt:0];
	_user_name = [NSString stringWithFormat:@""];
	_user_surname = [NSString stringWithFormat:@""];
	
	return self;
}

- (id)initWithParametersStatusID:(NSNumber *)status_id user_id:(NSNumber *)user_id user_name:(NSString *)user_name user_surname:(NSString *)user_surname {
	_status_id = status_id;
	_user_id = user_id;
	_user_name = user_name;
	_user_surname = user_surname;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	UbiStatusTag * copy = [[UbiStatusTag allocWithZone:zone] init];
	
	copy.status_id = _status_id;
	copy.user_id = _user_id;
	copy.user_name = _user_name;
	copy.user_surname = _user_surname;
	
	return copy;
}

- (void)dropTag
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"status_id": _status_id,
							 @"user_id": _user_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/drop_status_tag.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
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
