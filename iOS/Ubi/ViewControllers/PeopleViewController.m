//
//  LikesViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 10/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "PeopleViewController.h"

@interface PeopleViewController ()

@end

@implementation PeopleViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	locationManager = [[CLLocationManager alloc] init];
	if ([CLLocationManager locationServicesEnabled]) {
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		if (status == kCLAuthorizationStatusNotDetermined) {
			[locationManager requestAlwaysAuthorization];
			locationManager.delegate = self;
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			[locationManager startUpdatingLocation];
		}
		else if (status != kCLAuthorizationStatusAuthorizedAlways) {
			[[[UIAlertView alloc] initWithTitle:@"Location Services is disabled"
										message:@"Ubi needs access to your location. Please turn on Location Services in your device settings."
									   delegate:self
							  cancelButtonTitle:@"Annulla"
							  otherButtonTitles:@"Impostazioni", nil] show];
		}
		else {
			[locationManager requestAlwaysAuthorization];
			locationManager.delegate = self;
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			[locationManager startUpdatingLocation];
		}
	}
	else {
		[[[UIAlertView alloc] initWithTitle:@"Location Services is disabled"
									message:@"Ubi needs access to your location. Please turn on Location Services in your device settings."
								   delegate:self
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil] show];
	}
	
    _likesTableView.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
    _likesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
    //_peopleEmails = [_peopleEmails filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    [self loadUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUsers
{
	UbiUser * currentUbiUser = [[UbiUser alloc] initFromCache];
	
    NSString * people_ids = [_peopleEmails componentsJoinedByString:@" "];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	
    NSDictionary *params = @{@"user_ids": people_ids};
	
    [manager POST:[NSString stringWithFormat:@"%@/read_users_info.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dati_utenti_caricati = [[NSMutableArray alloc] init];
        
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
		
		if (!error) {
			for (NSDictionary *tempDictionary in jsonArray) {
				double lat_id = [[[tempDictionary objectForKey:@"user_lat"] description] floatValue];
				double long_id = [[[tempDictionary objectForKey:@"user_lon"] description] floatValue];
				
				CLLocation * location;
				CLLocationDistance distance;
				if ([[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_id"] description] intValue]] isEqualToNumber:currentUbiUser.db_id]) {
					distance = 0;
				}
				else {
					location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
					distance = [location distanceFromLocation:locationManager.location];
				}
				
				UbiUser * newUbiUser = [[UbiUser alloc] initWithParametersUserID:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_id"] description] intValue]]
																		 chat_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_chat_id"] description] intValue]]
																		   email:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_email"] description]]
																			name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_name"] description]]
																		 surname:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_surname"] description]]
																	 profile_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_pic"] description]]]
																	 profile_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_url"] description]]]
																last_status_text:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"status_content_text"] description]]
																			 bio:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_bio"] description]]
																		birthday:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_birthday"] description]]
																		  gender:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_gender"] description]]
																		latitude:[NSNumber numberWithFloat:lat_id]
																	   longitude:[NSNumber numberWithFloat:long_id]
																	 last_access:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_lastaccess"] description]]
																		distance:[NSNumber numberWithFloat:distance]];
				[dati_utenti_caricati addObject:newUbiUser];
			}
		}
		else
		{
			[self showErrorMessage:error.description];
		}
		
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [_likesTableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dati_utenti_caricati count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UbiUser * newUbiUser = [dati_utenti_caricati objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:newUbiUser.email];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:newUbiUser.email];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %@", newUbiUser.distance];
        
		[cell.imageView sd_setImageWithURL:newUbiUser.profile_pic
						  placeholderImage:[UIImage imageNamed:@""]];
		
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [cell.imageView.layer setCornerRadius:20];
        [cell.imageView.layer setMasksToBounds:YES];
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UbiUser * newUbiUser = [dati_utenti_caricati objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
        UbiUser *selectedUbiUser = (UbiUser *)sender;
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedUbiUser = selectedUbiUser;
    }
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
