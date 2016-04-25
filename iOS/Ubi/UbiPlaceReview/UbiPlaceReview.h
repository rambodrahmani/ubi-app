//
//  UbiAddressReview.h
//  Ubi
//
//  Created by Rambod Rahmani on 31/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"

@interface UbiPlaceReview : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * db_id;
@property (nonatomic, copy)	NSNumber * place_id;
@property (nonatomic, copy)	NSNumber * user_id;
@property (nonatomic, copy)	NSString * review_text;
@property (nonatomic, copy)	NSNumber * review_rating;
@property (nonatomic, copy)	NSString * review_date;

- (id)init;
- (id)initWithParametersReview_id:(NSNumber *)db_id place_id:(NSNumber *)place_id user_id:(NSNumber *)user_id review_text:(NSString *)review_text review_rating:(NSNumber *)review_rating review_date:(NSString *)review_date;

- (void)dropPlaceReview;

- (void)showErrorMessage:(NSString *)message;

@end
