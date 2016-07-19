//
//  UbiAddressReview.m
//  Ubi
//
//  Created by Rambod Rahmani on 31/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiPlaceReview.h"

@implementation UbiPlaceReview

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_place_id = [NSNumber numberWithInt:0];
	_user_id = [NSNumber numberWithInt:0];
	_review_text = [NSString stringWithFormat:@""];
	_review_rating = [NSNumber numberWithInt:0];
	_review_date = [NSString stringWithFormat:@""];
    
	return self;
}

- (id)initWithParametersReview_id:(NSNumber *)db_id place_id:(NSNumber *)place_id user_id:(NSNumber *)user_id review_text:(NSString *)review_text review_rating:(NSNumber *)review_rating review_date:(NSString *)review_date
{
	_db_id = db_id;
	_place_id = place_id;
	_user_id = user_id;
	_review_text = review_text;
	_review_rating = review_rating;
	_review_date = review_date;
	
	return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    UbiPlaceReview * copy = [[UbiPlaceReview allocWithZone:zone] init];
	
	copy.db_id = _db_id;
	copy.place_id = _place_id;
	copy.user_id = _user_id;
	copy.review_text = _review_text;
	copy.review_rating = _review_rating;
	copy.review_date = _review_date;
	
    return copy;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_db_id forKey:@"review_db_id"];
	[encoder encodeObject:_place_id forKey:@"review_place_id"];
	[encoder encodeObject:_user_id forKey:@"review_user_id"];
	[encoder encodeObject:_review_text forKey:@"review_review_text"];
	[encoder encodeObject:_review_rating forKey:@"review_review_rating"];
	[encoder encodeObject:_review_date forKey:@"review_review_date"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"review_db_id"];
	_place_id = [decoder decodeObjectForKey:@"review_place_id"];
	_user_id = [decoder decodeObjectForKey:@"review_user_id"];;
	_review_text = [decoder decodeObjectForKey:@"review_review_text"];;
	_review_rating = [decoder decodeObjectForKey:@"review_review_rating"];;
	_review_date = [decoder decodeObjectForKey:@"review_review_date"];;
	
	return self;
}

- (void)dropPlaceReview
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"review_id": _db_id,
							 @"place_id": _place_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/drop_place_review.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([operation.responseString containsString:@"ERROR"]) {
				[self showErrorMessage:operation.responseString];
			}
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
