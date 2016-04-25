//
//  UbiUser.h
//  Ubi
//
//  Created by Rambod Rahmani on 14/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "AFNetworking.h"
#import <Accounts/Accounts.h>
#import <Quickblox/Quickblox.h>
#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"

@interface UbiUser : NSObject <NSCopying>

@property (nonatomic, copy)	NSNumber * db_id;
@property (nonatomic, copy)	NSString * email;
@property (nonatomic, copy)	NSString * name;
@property (nonatomic, copy)	NSString * surname;
@property (nonatomic, copy)	NSURL * profile_pic;
@property (nonatomic, copy)	NSURL * profile_url;
@property (nonatomic, copy)	NSString * last_status_text;
@property (nonatomic, copy)	NSString * bio;
@property (nonatomic, copy)	NSString * birthday;
@property (nonatomic, copy)	NSString * gender;
@property (nonatomic, copy)	NSNumber * chat_id;
@property (nonatomic, copy)	NSNumber * latitude;
@property (nonatomic, copy)	NSNumber * longitude;
@property (nonatomic, copy)	NSString * last_access;
@property (nonatomic, copy)	NSNumber * distance;
@property (nonatomic, copy)	NSString * sign_in_account;

@property (nonatomic, copy)	NSString * google_plus_id;

- (id)init;
- (id)initWithParametersUserID:(NSNumber *)db_id chat_id:(NSNumber *)chat_id email:(NSString *)email name:(NSString *)name surname:(NSString *)surname profile_pic:(NSURL *)profile_pic profile_url:(NSURL *)profile_url last_status_text:(NSString *)last_status_text bio:(NSString *)bio birthday:(NSString *)birthday gender:(NSString *)gender latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude last_access:(NSString *)last_access distance:(NSNumber *)distance;
- (id)initFromCache;

- (BOOL)signUp;

- (BOOL)updateUserInfoToDB;
- (BOOL)updateUserLocationToDB:(float)latitudine :(float)longitudine;

- (void)getUserInfoFromDB;

- (void)saveCurrentUserToCache;
- (void)printUser;

- (void)showErrorMessage:(NSString *)message;

@end
