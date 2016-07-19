//
//  UbiStatusLike.h
//  Ubi
//
//  Created by Rambod Rahmani on 12/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"

@interface UbiStatusLike : NSObject

@property (nonatomic, copy)	NSNumber * status_id;
@property (nonatomic, copy)	NSNumber * user_id;

- (id)init;
- (id)initWithParametersStatusID:(NSNumber *)status_id user_id:(NSNumber *)user_id;

- (void)postLike;
- (void)dropLike;

- (void)showErrorMessage:(NSString *)message;

@end
