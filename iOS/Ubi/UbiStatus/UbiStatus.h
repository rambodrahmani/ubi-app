//
//  UbiPost.h
//  Ubi
//
//  Created by Rambod Rahmani on 14/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"
#import "UbiPlace.h"

@interface UbiStatus : NSObject <NSCopying>

@property (nonatomic, copy) NSNumber * db_id;
@property (nonatomic, copy) NSNumber * author_id;
@property (nonatomic, copy) NSString * content_text;
@property (nonatomic, copy) NSString * status_date;
@property (nonatomic, copy) NSURL * content_media;
@property (nonatomic, copy) NSArray *likes_array;
@property (nonatomic, copy) NSNumber * comments_num;
@property (nonatomic, copy) UbiPlace* status_place;
@property (nonatomic, copy) NSArray* tags;

- (id)init;
- (id)initWithParametersStatusID:(NSNumber* )db_id author_id:(NSNumber *)author_id content_media:(NSURL *)content_media content_text:(NSString *)content_text status_date:(NSString *)status_date likes_array:(NSArray *)likes_array comments_num:(NSNumber* )comments_num status_place:(UbiPlace *)status_place tags:(NSArray *)tags;

- (void)dropStatus;

- (void)showErrorMessage:(NSString *)message;

@end
