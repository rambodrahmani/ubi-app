//
//  UbiStatusTag.h
//  Ubi
//
//  Created by Rambod Rahmani on 12/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"

@interface UbiStatusTag : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * status_id;
@property (nonatomic, copy)	NSNumber * user_id;
@property (nonatomic, copy)	NSString * user_name;
@property (nonatomic, copy)	NSString * user_surname;

- (id)init;
- (id)initWithParametersStatusID:(NSNumber *)status_id user_id:(NSNumber *)user_id user_name:(NSString *)user_name user_surname:(NSString *)user_surname;

- (void)dropTag;

- (void)showErrorMessage:(NSString *)message;

@end
