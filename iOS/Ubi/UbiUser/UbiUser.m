//
//  UbiUser.m
//  Ubi
//
//  Created by Rambod Rahmani on 14/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

@implementation UbiUser

- (id)init
{
	_db_id = [NSNumber numberWithInt:0];
	_chat_id = [NSNumber numberWithInt:0];
	_email = [NSString stringWithFormat:@""];
	_name = [NSString stringWithFormat:@""];
	_surname = [NSString stringWithFormat:@""];
	_profile_pic = [NSURL URLWithString:@""];
	_profile_url = [NSURL URLWithString:@""];
	_last_status_text = [NSString stringWithFormat:@""];
	_bio = [NSString stringWithFormat:@""];
	_birthday = [NSString stringWithFormat:@""];
	_gender = [NSString stringWithFormat:@""];
	_latitude = [NSNumber numberWithInt:0];
	_longitude = [NSNumber numberWithInt:0];
	_last_access = [NSString stringWithFormat:@""];
	_distance = [NSNumber numberWithInt:0];
	_sign_in_account = [NSString stringWithFormat:@""];
    _google_plus_id = [NSString stringWithFormat:@""];
	
	return self;
}

- (id)initWithParametersUserID:(NSNumber *)db_id chat_id:(NSNumber *)chat_id email:(NSString *)email name:(NSString *)name surname:(NSString *)surname profile_pic:(NSURL *)profile_pic profile_url:(NSURL *)profile_url last_status_text:(NSString *)last_status_text bio:(NSString *)bio birthday:(NSString *)birthday gender:(NSString *)gender latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude last_access:(NSString *)last_access distance:(NSNumber *)distance
{
	_db_id = db_id;
	_chat_id = chat_id;
	_email = email;
	_name = name;
	_surname = surname;
	_profile_pic = profile_pic;
	_profile_url = profile_url;
	_last_status_text = last_status_text;
	_bio = bio;
	_birthday = birthday;
	_gender = gender;
	_latitude = latitude;
	_longitude = longitude;
	_last_access = last_access;
	_distance = distance;
	_sign_in_account = [NSString stringWithFormat:@""];
	_google_plus_id = [NSString stringWithFormat:@""];
	
	return self;
}

- (id)initFromCache
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	_db_id = [defaults objectForKey:@"current_user_db_id"];
	_chat_id = [defaults objectForKey:@"current_user_chat_id"];
	_email = [defaults objectForKey:@"current_user_email"];
	_name = [defaults objectForKey:@"current_user_name"];
	_surname = [defaults objectForKey:@"current_user_surname"];
	_profile_pic = [NSURL URLWithString:[defaults objectForKey:@"current_user_profile_pic"]];
	_profile_url = [NSURL URLWithString:[defaults objectForKey:@"current_user_profile_url"]];
	_last_status_text = [defaults objectForKey:@"current_user_last_status_text"];
	_bio = [defaults objectForKey:@"current_user_bio"];
	_birthday = [defaults objectForKey:@"current_user_birthday"];
	_gender = [defaults objectForKey:@"current_user_gender"];
	_latitude = [defaults objectForKey:@"current_user_latitude"];
	_longitude = [defaults objectForKey:@"current_user_longitude"];
	_last_access = [defaults objectForKey:@"current_user_last_access"];
	_distance = [defaults objectForKey:@"current_user_distance"];
	_sign_in_account = [defaults objectForKey:@"current_user_sign_in_account"];
	_google_plus_id = [defaults objectForKey:@"current_user_google_plus_id"];
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    UbiUser * copy = [[UbiUser allocWithZone:zone] init];
	
    copy.db_id = _db_id;
	copy.chat_id = _chat_id;
	copy.email = _email;
    copy.name = _name;
    copy.surname = _surname;
    copy.profile_pic = _profile_pic;
    copy.profile_url = _profile_url;
	copy.last_status_text = _last_status_text;
    copy.bio = _bio;
    copy.birthday = _birthday;
    copy.gender = _gender;
    copy.latitude = _latitude;
    copy.longitude = _longitude;
    copy.last_access = _last_access;
    copy.distance = _distance;
    copy.sign_in_account = _sign_in_account;
	copy.google_plus_id = _google_plus_id;
	
    return copy;
}

- (void)printUser
{
	NSLog(@""
		  "\ndb_id: %@"
		  "\nemail: %@"
		  "\nname: %@"
		  "\nsurname: %@"
		  "\nprofile_pic: %@"
		  "\nprofile_url: %@"
		  "\nlast_status_text: %@"
		  "\nbio: %@"
		  "\nbirthday: %@"
		  "\ngender: %@"
		  "\nchat_id: %@"
		  "\nlatitude: %@"
		  "\nlongitude: %@"
		  "\nlast_access: %@"
		  "\ndistance: %@"
		  "\nsign_in_account: %@"
		  "\n", _db_id, _email, _name, _surname, _profile_pic, _profile_url, _last_status_text, _bio, _birthday, _gender, _chat_id, _latitude, _longitude, _last_access, _distance, _sign_in_account);
}

- (BOOL)signUp
{
	__block NSString * op_resp = @"";
    __block BOOL bool_response = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
	NSNumber * timeZoneInMins = [NSNumber numberWithFloat:(float)(timeZoneOffset*60)];
	
    NSDictionary *params = @{@"email": _email,
                             @"name": _name,
                             @"surname": _surname,
                             @"profile_pic": _profile_pic,
                             @"profile_url": _profile_url,
							 @"last_status_text": _last_status_text,
                             @"bio": _bio,
                             @"birthday": _birthday,
                             @"gender": _gender,
                             @"chat_id": _chat_id,
							 
							 @"google_plus_id": _google_plus_id,
							 
							 @"status_date_utc_offset": timeZoneInMins};
    
    [manager POST:[NSString stringWithFormat:@"%@/register_user.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		op_resp = operation.responseString;
		if ([operation.responseString containsString:@"ERROR"]) {
			bool_response = NO;
		}
		else  {
			_db_id = [NSNumber numberWithInt:[operation.responseString intValue]];
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:@"Standard" forKey:@"mapType"];
			
			NSArray * mapFilters = [[NSArray alloc] initWithObjects:@"people", nil];
			[defaults setObject:mapFilters forKey:@"mapFilters"];
			
			NSArray * placeTypesFilters = [[NSArray alloc] initWithObjects:@"cafe", @"bar", @"restaurant", @"night_club", nil];
			[defaults setObject:placeTypesFilters forKey:@"mapPlacesFilters"];
			
			[self saveCurrentUserToCache];
			
			bool_response = YES;
		}
        dispatch_semaphore_signal(semaphore);
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		op_resp = error.description;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	if (!bool_response) {
		[self showErrorMessage:[NSString stringWithFormat:@"user signup: %@", op_resp]];
	}
	
    return bool_response;
}

- (void)getUserInfoFromDB
{
	__block NSString * op_resp = @"";
	__block BOOL bool_response = NO;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block NSError * error;
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary * params = @{@"user_ids": _db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_users_info.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		op_resp = operation.responseString;
		NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
		
		if (!error) {
			for (NSDictionary *tempDictionary in jsonArray) {
				_db_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_id"] description] intValue]];
				_chat_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_chat_id"] description] intValue]];
				_email = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_email"] description]];
				_name = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_name"] description]];
				_surname = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_surname"] description]];
				_profile_pic = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_pic"] description]]];
				_profile_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_url"] description]]];
				_last_status_text = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"status_content_text"] description]];
				_bio = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_bio"] description]];
				_birthday = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_birthday"] description]];
				_gender = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_gender"] description]];
				_latitude = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_lat"] description] intValue]];
				_longitude = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_lon"] description] intValue]];
				_last_access = [NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_lastaccess"] description]];
				_distance = [NSNumber numberWithInt:0];
				
				bool_response = YES;
			}
		}
		
		[self saveCurrentUserToCache];
		dispatch_semaphore_signal(semaphore);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		op_resp = error.description;
		dispatch_semaphore_signal(semaphore);
	}];
	
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	if (!bool_response) {
		[self showErrorMessage:[NSString stringWithFormat:@"getUserInfoFromDB: %@ - %@", op_resp, error.description]];
	}
}

- (void)saveCurrentUserToCache
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_db_id forKey:@"current_user_db_id"];
	[defaults setObject:_chat_id forKey:@"current_user_chat_id"];
	[defaults setObject:_email forKey:@"current_user_email"];
	[defaults setObject:_name forKey:@"current_user_name"];
	[defaults setObject:_surname forKey:@"current_user_surname"];
	[defaults setObject:_profile_pic.absoluteString forKey:@"current_user_profile_pic"];
	[defaults setObject:_profile_url.absoluteString forKey:@"current_user_profile_url"];
	[defaults setObject:_last_status_text forKey:@"current_user_last_status_text"];
	[defaults setObject:_bio forKey:@"current_user_bio"];
	[defaults setObject:_birthday forKey:@"current_user_birthday"];
	[defaults setObject:_gender forKey:@"current_user_gender"];
	[defaults setObject:_latitude forKey:@"current_user_latitude"];
	[defaults setObject:_longitude forKey:@"current_user_longitude"];
	[defaults setObject:_last_access forKey:@"current_user_last_access"];
	[defaults setObject:_distance forKey:@"current_user_distance"];
	[defaults setObject:_sign_in_account forKey:@"current_user_sign_in_account"];
	[defaults setObject:_google_plus_id forKey:@"current_user_google_plus_id"];
}

- (BOOL)updateUserInfoToDB
{
	__block NSString * op_resp = @"";
	__block BOOL bool_response = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDictionary *params = @{@"user_id": _db_id,
							 @"chat_id": _chat_id,
							 @"email": _email,
							 @"name": _name,
							 @"surname": _surname,
							 @"profile_pic": _profile_pic,
							 @"profile_url": _profile_url,
							 @"bio": _bio,
							 @"birthday": _birthday,
							 @"gender": _gender};
	
	[manager POST:[NSString stringWithFormat:@"%@/update_user_info.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		op_resp = operation.responseString;
		if ([operation.responseString containsString:@"SUCCESS"]) {
			bool_response = YES;
		}
		
		dispatch_semaphore_signal(semaphore);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		op_resp = error.description;
		dispatch_semaphore_signal(semaphore);
	}];
	
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	if (!bool_response) {
		[self showErrorMessage:[NSString stringWithFormat:@"updateUserInfoToDB: %@", op_resp]];
	}
	
	return bool_response;
}

- (BOOL)updateUserLocationToDB:(float)latitudine :(float)longitudine
{
	__block NSString * op_resp = @"";
    __block BOOL bool_response = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSDictionary *params = @{@"user_id": _db_id,
                             @"lat": [NSNumber numberWithFloat:latitudine],
                             @"lon": [NSNumber numberWithFloat:longitudine]};
	
    [manager POST:[NSString stringWithFormat:@"%@/update_user_location.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		op_resp = operation.responseString;
		if ([operation.responseString containsString:@"SUCCESS"]) {
			bool_response = YES;
		}
		
        dispatch_semaphore_signal(semaphore);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		op_resp = error.description;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	if (!bool_response) {
		[self showErrorMessage:[NSString stringWithFormat:@"updateUserLocationToDB: %@", op_resp]];
	}
	
    return bool_response;
}

#pragma - NSKeyedArchiver
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_db_id forKey:@"current_user_db_id"];
	[encoder encodeObject:_chat_id forKey:@"current_user_chat_id"];
	[encoder encodeObject:_email forKey:@"current_user_email"];
	[encoder encodeObject:_name forKey:@"current_user_name"];
	[encoder encodeObject:_surname forKey:@"current_user_surname"];
	[encoder encodeObject:_profile_pic forKey:@"current_user_profile_pic"];
	[encoder encodeObject:_profile_url forKey:@"current_user_profile_url"];
	[encoder encodeObject:_bio forKey:@"current_user_bio"];
	[encoder encodeObject:_birthday forKey:@"current_user_birthday"];
	[encoder encodeObject:_gender forKey:@"current_user_gender"];
	[encoder encodeObject:_latitude forKey:@"current_user_latitude"];
	[encoder encodeObject:_longitude forKey:@"current_user_longitude"];
	[encoder encodeObject:_last_access forKey:@"current_user_last_access"];
	[encoder encodeObject:_distance forKey:@"current_user_distance"];
	[encoder encodeObject:_sign_in_account forKey:@"current_user_sign_in_account"];
	[encoder encodeObject:_last_status_text forKey:@"current_user_last_status_text"];
	[encoder encodeObject:_google_plus_id forKey:@"current_user_google_plus_id"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	_db_id = [decoder decodeObjectForKey:@"current_user_db_id"];
	_chat_id = [decoder decodeObjectForKey:@"current_user_chat_id"];
	_email = [decoder decodeObjectForKey:@"current_user_email"];
	_name = [decoder decodeObjectForKey:@"current_user_name"];
	_surname = [decoder decodeObjectForKey:@"current_user_surname"];
	_profile_pic = [decoder decodeObjectForKey:@"current_user_profile_pic"];
	_profile_url = [decoder decodeObjectForKey:@"current_user_profile_url"];
	_bio = [decoder decodeObjectForKey:@"current_user_bio"];
	_birthday = [decoder decodeObjectForKey:@"current_user_birthday"];
	_gender = [decoder decodeObjectForKey:@"current_user_gender"];
	_latitude = [decoder decodeObjectForKey:@"current_user_latitude"];
	_longitude = [decoder decodeObjectForKey:@"current_user_longitude"];
	_last_access = [decoder decodeObjectForKey:@"current_user_last_access"];
	_distance = [decoder decodeObjectForKey:@"current_user_distance"];
	_sign_in_account = [decoder decodeObjectForKey:@"current_user_sign_in_account"];
	_last_status_text = [decoder decodeObjectForKey:@"current_user_last_status_text"];
	_google_plus_id = [decoder decodeObjectForKey:@"current_user_google_plus_id"];
	
	return self;
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
