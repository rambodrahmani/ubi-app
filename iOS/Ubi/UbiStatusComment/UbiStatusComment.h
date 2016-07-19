//
//  UbiStatusComment.h
//  Ubi
//
//  Created by Rambod Rahmani on 31/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"

@interface UbiStatusComment : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * db_id;
@property (nonatomic, copy)	NSNumber * status_id;
@property (nonatomic, copy)	NSNumber * user_id;
@property (nonatomic, copy)	NSString * comment_content_text;
@property (nonatomic, copy)	NSString * comment_date;

- (id)init;
- (id)initWithParametersCommentID:(NSNumber *)db_id status_id:(NSNumber *)status_id user_id:(NSNumber *)user_id comment_content_text:(NSString *)comment_content_text comment_date:(NSString *)comment_date;

- (id)postNewCommentWithUser_id:(NSNumber *)user_id status_id:(NSNumber *)status_id comment_text:(NSString *)comment_text;
- (void)dropComment;

- (void)showErrorMessage:(NSString *)message;

@end
