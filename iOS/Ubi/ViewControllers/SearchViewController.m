//
//  SearchViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 20/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "SearchViewController.h"
#import "ImagesGalleryViewController.h"

@interface NSMutableArray (Resizing)

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (NSMutableArray *)resize:(NSInteger)newSize;

@end

@implementation NSMutableArray (Resizing)

- (NSMutableArray *)resize:(NSInteger)newSize
{
	int size = (int)((newSize > [self count]) ? self.count : newSize);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:size];
	for (int i = 0; i < size; i++){
		[array addObject:[self objectAtIndex:i]];
	}
	return array;
}

@end

@interface SearchViewController ()

@end

@implementation SearchViewController

#pragma mark - ViewController lyfe cycle
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	id_caricati = [[NSMutableArray alloc] initWithCapacity:4];
	dati_utenti_caricati = [[NSMutableDictionary alloc] initWithCapacity:4];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
	dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	id_caricati = [defaults objectForKey:@"id_caricati"];
	
	if (!allUsersHaveBeenLoaded) {
		id_caricati = [id_caricati resize:4];
	}
    
	[[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
    dispatch_async(dispatch_get_main_queue(), ^{
        [_resultsTableView reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[_activityIndicatorView startAnimating];
	
	allUsersHaveBeenLoaded = FALSE;
	allPlacesHaveBeenLoaded = FALSE;
	_nearbyPlacesResults = [[NSMutableArray array] init];
	_searchPlacesResults = [[NSMutableArray array] init];
	_searchUsersResults = [[NSMutableArray array] init];
	loadedNearbyPlaces = [[NSMutableArray array] init];
	
	locationManager = [[CLLocationManager alloc] init];
	
	self.navigationController.interactivePopGestureRecognizer.enabled = true;
	self.navigationController.interactivePopGestureRecognizer.delegate = self;
	
	networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
									message:@"The internet connection appears to be offline."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		[_activityIndicatorView stopAnimating];
	}
	else
	{
		if ([CLLocationManager locationServicesEnabled]) {
			CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
			if (status == kCLAuthorizationStatusNotDetermined) {
				[locationManager requestAlwaysAuthorization];
				locationManager.delegate = self;
				locationManager.desiredAccuracy = kCLLocationAccuracyBest;
				[locationManager startUpdatingLocation];
				
				[self startSearchingNearbyPlaces:locationManager.location.coordinate.latitude :locationManager.location.coordinate.longitude];
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
				
				[self startSearchingNearbyPlaces:locationManager.location.coordinate.latitude :locationManager.location.coordinate.longitude];
			}
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Location Services is disabled"
										message:@"Ubi needs access to your location. Please turn on Location Services in your device settings."
									   delegate:self
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil] show];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Impostazioni"])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
	}
}

#pragma mark - Tableview Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int rowsNumber = [self getRowsNumber];
	
	return rowsNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"- Search Result Error";
	}
    
    if ([self isLoadMoreResultsCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreCell"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Load more nearby places...";
        }
    }
    else if ([self isLoadMoreUsersCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreUsersCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreUsersCell"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Load more nearby users...";
        }
    }
    else if ([self isPlacesNearbyCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PlacesNearby"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlacesNearby"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"- Places nearby you:";
        }
    }
    else if ([self isPeopleNearbyCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PeopleNearby"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PeopleNearby"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"- People nearby you:";
        }
    }
    else if ([self isSearchResultsCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResults"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchResults"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"- Places search results:";
        }
    }
    else if ([self isUserSearchResultsCellAtIndexPath:indexPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UsersSearchResults"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsersSearchResults"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"- Ubi search results:";
        }
    }
    else
    {
        if ( ([_searchUsersResults count] > 0) && (indexPath.row < [_searchUsersResults count] + 1) ) {
            UbiUser * newUbiUser = [_searchUsersResults objectAtIndex:indexPath.row - 1];
            
            cell = [tableView dequeueReusableCellWithIdentifier:newUbiUser.email];
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
        }
        else if ( ([_searchPlacesResults count] > 0) && (indexPath.row < [_searchPlacesResults count] + 1 + [_searchUsersResults count] + ([_searchUsersResults count] > 0 ? 1 : 0)) ) {
			UbiPlace *newUbiPlace = [[UbiPlace alloc] init];
            if ([_searchUsersResults count] > 0) {
                newUbiPlace = [_searchPlacesResults objectAtIndex:indexPath.row - [_searchUsersResults count] - 2];
            }
            else {
                newUbiPlace = [_searchPlacesResults objectAtIndex:indexPath.row - 1];
            }
            
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@", newUbiPlace.place_google_id]];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%@", newUbiPlace.place_google_id]];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = newUbiPlace.place_name;
				
				cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %@m", newUbiPlace.place_distance];
				
                [cell.imageView sd_setImageWithURL:newUbiPlace.place_icon_url
								  placeholderImage:[UIImage imageNamed:@""]];
            }
        }
        else if ( ([id_caricati count] > 0) && (indexPath.row < ([id_caricati count] + 1 + [_searchPlacesResults count] + ([_searchPlacesResults count] > 0 ? 1 : 0) + [_searchUsersResults count] + ([_searchUsersResults count] > 0 ? 1 : 0))) ) {
            UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:[self getEmailCaricateIndex:indexPath]]];
            
            cell = [tableView dequeueReusableCellWithIdentifier:newUbiUser.email];
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
        }
        else
        {
            UbiPlace *newUbiPlace = [_nearbyPlacesResults objectAtIndex:[self getPlacesNearbyIndex:indexPath]];
			
            cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@", newUbiPlace.db_id]];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%@", newUbiPlace.db_id]];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.text = newUbiPlace.place_name;
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %@m", newUbiPlace.place_distance];
				
				[cell.imageView sd_setImageWithURL:newUbiPlace.place_icon_url
								  placeholderImage:[UIImage imageNamed:@""]];
            }
        }
    }
		
	return cell;
}

#pragma mark - Tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if ([self isLoadMoreResultsCellAtIndexPath:indexPath])
    {
        [self startSearchingNearbyPlaces:locationManager.location.coordinate.latitude+0.004 :locationManager.location.coordinate.longitude];
		allPlacesHaveBeenLoaded = TRUE;
    }
    else if ([self isLoadMoreUsersCellAtIndexPath:indexPath])
    {
        allUsersHaveBeenLoaded = TRUE;
        
        id_caricati = [[NSMutableArray alloc] init];
        dati_utenti_caricati = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
        dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        id_caricati = [defaults objectForKey:@"id_caricati"];
        
        [[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [_resultsTableView reloadData];
    }
	else if ([self isPlacesNearbyCellAtIndexPath:indexPath])
	{
		return;
	}
	else if ([self isPeopleNearbyCellAtIndexPath:indexPath])
	{
		return;
	}
	else if ([self isSearchResultsCellAtIndexPath:indexPath])
	{
		return;
	}
	else if ([self isUserSearchResultsCellAtIndexPath:indexPath])
	{
		return;
	}
    else
    {
        if ( ([_searchUsersResults count] > 0) && (indexPath.row < [_searchUsersResults count] + 1) ) {
            UbiUser * newUbiUser = [_searchUsersResults objectAtIndex:indexPath.row - 1];
			
            [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
        }
        else if ( ([_searchPlacesResults count] > 0) && (indexPath.row < [_searchPlacesResults count] + 1 + [_searchUsersResults count] + ([_searchUsersResults count] > 0)) ) {
            UbiPlace *newUbiPlace;
            if ([_searchUsersResults count] > 0) {
                newUbiPlace = [_searchPlacesResults objectAtIndex:indexPath.row - [_searchUsersResults count] - 2];
            }
            else {
                newUbiPlace = [_searchPlacesResults objectAtIndex:indexPath.row - 1];
            }
            
            [self performSegueWithIdentifier:@"ShowPlaceDetailsView" sender:newUbiPlace];
        }
        else if ( ([id_caricati count] > 0) && (indexPath.row < ([id_caricati count] + 1 + [_searchPlacesResults count] + ([_searchPlacesResults count] > 0 ? 1 : 0) + [_searchUsersResults count] + ([_searchUsersResults count] > 0 ? 1 : 0))) ) {
            UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:[self getEmailCaricateIndex:indexPath]]];
            [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
        }
        else {
            UbiPlace *newUbiPlace = [_nearbyPlacesResults objectAtIndex:[self getPlacesNearbyIndex:indexPath]];
            [self performSegueWithIdentifier:@"ShowPlaceDetailsView" sender:newUbiPlace];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPlaceDetailsView"]) {
        UbiPlace *newUbiPlace = (UbiPlace *)sender;
        PlaceDetailsViewController *destinationViewController = (PlaceDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedAddress = newUbiPlace;
    }
    else if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
        UbiUser *selectedUbiUser = (UbiUser *)sender;
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedUbiUser = selectedUbiUser;
    }
}

#pragma mark - FTGooglePlacesAPI performing search request
- (void)startSearchingNearbyPlaces:(float)latitudine :(float)longitudine
{
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
									message:@"The internet connection appears to be offline."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
	else
	{
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		NSDictionary *params = @{@"location": [NSString stringWithFormat:@"%f,%f", latitudine, longitudine],
								 @"place_types": @""};
		
		[manager POST:[NSString stringWithFormat:@"%@/radar_search.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					NSNumber * place_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"place_id"] description] intValue]];
					
					if (![loadedNearbyPlaces containsObject:place_id])
					{
						[loadedNearbyPlaces addObject:place_id];
						
						double lat_id = [[[tempDictionary objectForKey:@"place_lat"] description] floatValue];
						double long_id = [[[tempDictionary objectForKey:@"place_lon"] description] floatValue];
						
						CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
						CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
						
						UbiPlace * newUbiPlace = [[UbiPlace alloc] initWithParameters_db_id:place_id
																				 place_name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_name"] description]]
																				  place_lat:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lat"] description] floatValue]]
																				  place_lon:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lon"] description] floatValue]]
																			 place_icon_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_icon_url"] description]]]
																			   place_string:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_string"] description]]
																			place_google_id:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_id"] description]]
																			   place_rating:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_rating"] description] floatValue]]
																				place_types:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_types"] description]]
																		  place_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_website_url"] description]]]
																		 place_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_phone_number"] description]]
																	 place_int_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_int_phone_number"] description]]
																		   place_utc_offset:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"place_utc_offset"] description] floatValue]]
																		   place_google_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_url"] description]]]
																			place_cover_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_cover_pic_url"] description]]]
																			 place_distance:[NSNumber numberWithFloat:distance]];
						
						[_nearbyPlacesResults addObject:newUbiPlace];
					}
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_activityIndicatorView stopAnimating];
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				[_resultsTableView reloadData];
				
				[UIView animateWithDuration:0.5f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
					} completion:^(BOOL finished){
						if (finished) {
							[_resultsTableView reloadRowsAtIndexPaths:[_resultsTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
						}
				}];
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
		}];
	}
}

- (void)startSearchingPlaces:(id<FTGooglePlacesAPIRequest>)request
{
	[FTGooglePlacesAPIService executeSearchRequest:request
							 withCompletionHandler:^(FTGooglePlacesAPISearchResponse *response, NSError *error)
	 {
		 if (error)
		 {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 _searchPlacesResults = [[NSMutableArray alloc] init];
				 
				 [[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
				 [_resultsTableView reloadData];
				 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				 
				 [self searchDataBase];
			 });
			 return;
		 }
		 
		 dispatch_async(dispatch_get_main_queue(), ^{
			 for (FTGooglePlacesAPISearchResultItem *resultItem in response.results) {
				 CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(resultItem.location.coordinate.latitude, resultItem.location.coordinate.longitude) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
				 CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
				 
				 UbiPlace * newUbiPlace = [[UbiPlace alloc] initWithParameters_db_id:[NSNumber numberWithInt:0]
																		  place_name:resultItem.name
																		   place_lat:[NSNumber numberWithFloat:resultItem.location.coordinate.latitude]
																		   place_lon:[NSNumber numberWithFloat:resultItem.location.coordinate.longitude]
																	  place_icon_url:[NSURL URLWithString:resultItem.iconImageUrl]
																		place_string:resultItem.addressString
																	 place_google_id:resultItem.placeId
																		place_rating:[NSNumber numberWithFloat:resultItem.rating]
																		 place_types:[resultItem.types componentsJoinedByString:@", "]
																   place_website_url:[NSURL URLWithString:@""]
																  place_phone_number:[NSString stringWithFormat:@""]
															  place_int_phone_number:[NSString stringWithFormat:@""]
																	place_utc_offset:[NSNumber numberWithInt:0]
																	place_google_url:[NSURL URLWithString:@""]
																	 place_cover_pic:[NSURL URLWithString:@""]
																	  place_distance:[NSNumber numberWithFloat:distance]];
				 [_searchPlacesResults addObject:newUbiPlace];
			 }
			 
			 [[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
			 [_resultsTableView reloadData];
			 [self searchDataBase];
		 });
	 }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
	_searchPlacesResults = [[NSMutableArray alloc] init];
	_searchUsersResults = [[NSMutableArray alloc] init];
	
	[[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[_resultsTableView reloadData];
	
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	if ([searchBar.text isEqualToString:@""]) {
		_searchPlacesResults = [[NSMutableArray alloc] init];
		_searchUsersResults = [[NSMutableArray alloc] init];
		
		[[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		[_resultsTableView reloadData];
	}
	
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	_searchPlacesResults = [[NSMutableArray alloc] init];
	_searchUsersResults = [[NSMutableArray alloc] init];
	
	NSString * searchQuery = [searchBar text];
	
	FTGooglePlacesAPINearbySearchRequest *request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:locationManager.location.coordinate];
	request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
	request.radius = 1000;
	request.keyword = searchQuery;
	request.types = @[@"accounting", @"airport", @"amusement_park", @"aquarium", @"art_gallery", @"atm", @"bakery", @"bank", @"bar", @"beauty_salon", @"bicycle_store", @"book_store", @"bowling_alley", @"bus_station", @"cafe", @"campground", @"car_dealer", @"car_rental", @"car_repair", @"car_wash", @"casino", @"cemetery", @"church", @"city_hall", @"clothing_store", @"convenience_store", @"courthouse", @"dentist", @"department_store", @"doctor", @"electrician", @"electronics_store", @"embassy", @"establishment", @"finance", @"fire_station", @"florist", @"food", @"funeral_home", @"furniture_store", @"gas_station", @"general_contractor", @"grocery_or_supermarket", @"gym", @"hair_care", @"hardware_store", @"health", @"hindu_temple", @"home_goods_store", @"hospital", @"insurance_agency", @"jewelry_store", @"laundry", @"lawyer", @"library", @"liquor_store", @"local_government_office", @"locksmith", @"lodging", @"meal_delivery", @"meal_takeaway", @"mosque", @"movie_rental", @"movie_theater", @"moving_company", @"museum", @"night_club", @"painter", @"park", @"parking", @"pet_store", @"pharmacy", @"physiotherapist", @"place_of_worship", @"plumber", @"police", @"post_office", @"real_estate_agency", @"restaurant", @"roofing_contractor", @"rv_park", @"school", @"shoe_store", @"shopping_mall", @"spa", @"stadium", @"storage", @"store", @"subway_station", @"synagogue", @"taxi_stand", @"train_station", @"travel_agency", @"university", @"veterinary_care", @"zoo"];
	
	[self startSearchingPlaces:request];
}

# pragma mark - Database Search
- (void)searchDataBase
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
									message:@"The internet connection appears to be offline."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
	else
	{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *params = @{@"query": _searchBar.text};
        
        [manager POST:[NSString stringWithFormat:@"%@/search_database.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            _searchUsersResults = [[NSMutableArray array] init];
            
            NSError *error;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					double lat_id = [[[tempDictionary objectForKey:@"user_lat"] description] floatValue];
					double long_id = [[[tempDictionary objectForKey:@"user_lon"] description] floatValue];
					
					CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
					CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
					
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
					[_searchUsersResults addObject:newUbiUser];
				}
			}
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				
                [[[self searchDisplayController] searchResultsTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                [_resultsTableView reloadData];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
        }];
	}
}

#pragma mark - Helper methods
- (BOOL)isUserSearchResultsCellAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_searchUsersResults count] > 0) {
		if (indexPath.row == 0) {
			return TRUE;
		}
	}
	
	return FALSE;
}

- (BOOL)isSearchResultsCellAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_searchPlacesResults count] > 0) {
		if ([_searchUsersResults count] > 0) {
			if (indexPath.row == [_searchUsersResults count] + 1) {
				return TRUE;
			}
		}
		else {
			if (indexPath.row == 0) {
				return TRUE;
			}
		}
		
	}
	
	return FALSE;
}

- (BOOL)isPeopleNearbyCellAtIndexPath:(NSIndexPath *)indexPath
{
	int rowsNumber = 0;
	
	if ([_searchUsersResults count] > 0) {
		rowsNumber += [_searchUsersResults count] + 1;
	}
	
	if ([_searchPlacesResults count] > 0) {
		rowsNumber += [_searchPlacesResults count] + 1;
	}
	
	if ([id_caricati count] > 0) {
		if (indexPath.row == rowsNumber) {
			return TRUE;
		}
	}
	
	return FALSE;
}

- (BOOL)isLoadMoreUsersCellAtIndexPath:(NSIndexPath *)indexPath
{
	if ( (allUsersHaveBeenLoaded) || ([id_caricati count] < 4) ) {
		return FALSE;
	}
	
	int rowsNumber = 0;
	
	if ([_searchUsersResults count] > 0) {
		rowsNumber += [_searchUsersResults count] + 1;
	}
	
	if ([_searchPlacesResults count] > 0) {
		rowsNumber += [_searchPlacesResults count] + 1;
	}
	
	if ([id_caricati count] > 0) {
		rowsNumber += [id_caricati count] + 1;
	}
	
	if ([id_caricati count] > 0) {
		if (indexPath.row == rowsNumber) {
			return TRUE;
		}
	}
	
	return FALSE;
}

- (BOOL)isPlacesNearbyCellAtIndexPath:(NSIndexPath *)indexPath
{
	int rowsNumber = 0;
	
	if ([_searchUsersResults count] > 0) {
		rowsNumber += [_searchUsersResults count] + 1;
	}
	
	if ([_searchPlacesResults count] > 0) {
		rowsNumber += [_searchPlacesResults count] + 1;
	}
	
	if ( ([id_caricati count] > 0) && ([id_caricati count] < 4) ) {
		rowsNumber += [id_caricati count] + (allUsersHaveBeenLoaded ? 0 : 1);
	}
	else if ([id_caricati count] > 0) {
		rowsNumber += [id_caricati count] + 1 + (allUsersHaveBeenLoaded ? 0 : 1);
	}
	
	if ([_nearbyPlacesResults count] > 0) {
		if (indexPath.row == rowsNumber) {
			return TRUE;
		}
	}
	
	return FALSE;
}

- (BOOL)isLoadMoreResultsCellAtIndexPath:(NSIndexPath *)indexPath
{
	if (allPlacesHaveBeenLoaded) {
		return FALSE;
	}
	
	int rowsNumber = [self getRowsNumber];
	
	if (indexPath.row == rowsNumber - 1) {
		return TRUE;
	}
	
	return FALSE;
}

- (int)getEmailCaricateIndex:(NSIndexPath *)indexPath
{
	int result = 0;
	
	if ( ([_searchPlacesResults count] > 0) && ([_searchUsersResults count] > 0) ) {
		result = (int)(indexPath.row - [_searchUsersResults count] - [_searchPlacesResults count] - 3);
	}
	else if ([_searchPlacesResults count] > 0) {
		result = (int)(indexPath.row - [_searchPlacesResults count] - 2);
	}
	else if ([_searchUsersResults count] > 0) {
		result = (int)(indexPath.row - [_searchUsersResults count] - 2);
	}
	else {
		result = (int)(indexPath.row - 1);
	}
	
	return result;
}

- (int)getPlacesNearbyIndex:(NSIndexPath *)indexPath
{
	int result = 0;

	if ( ([_searchPlacesResults count] > 0) && ([id_caricati count] > 0) && ([_searchUsersResults count] > 0) && ([id_caricati count] < 4) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchPlacesResults count] - [_searchUsersResults count] - 2 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ( ([_searchPlacesResults count] > 0) && ([id_caricati count] > 0) && ([_searchUsersResults count] > 0) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchPlacesResults count] - [_searchUsersResults count] - 4 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ( ([_searchPlacesResults count] > 0) && ([id_caricati count] > 0) && ([id_caricati count] < 4) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchPlacesResults count] - 1 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ( ([_searchPlacesResults count] > 0) && ([id_caricati count] > 0) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchPlacesResults count] - 3 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ( ([_searchPlacesResults count] > 0) && ([_searchUsersResults count] > 0) ) {
		result = (int)(indexPath.row - [_searchUsersResults count] - [_searchPlacesResults count] - 3);
	}
	else if ( ([_searchUsersResults count] > 0) && ([id_caricati count] > 0) && ([id_caricati count] < 4) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchUsersResults count] - 1 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ( ([_searchUsersResults count] > 0) && ([id_caricati count] > 0) ) {
		result = (int)(indexPath.row - [id_caricati count] - [_searchUsersResults count] - 3 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ([_searchUsersResults count] > 0) {
		result = (int)(indexPath.row - [_searchUsersResults count] - 2);
	}
	else if ([_searchPlacesResults count] > 0) {
		result = (int)(indexPath.row - [_searchPlacesResults count] - 2);
	}
	else if ( ([id_caricati count] > 0) && ([id_caricati count] < 4) ) {
		result = (int)(indexPath.row - [id_caricati count] - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else if ([id_caricati count] > 0) {
		result = (int)(indexPath.row - [id_caricati count] - 2 - (allUsersHaveBeenLoaded ? 0 : 1));
	}
	else {
		result = (int)(indexPath.row - 1);
	}
	
	return result;
}

- (int)getRowsNumber
{
	int result = 0;
	
	if ([_searchUsersResults count] > 0) {
		result += [_searchUsersResults count] + 1;
	}
	
	if ([_searchPlacesResults count] > 0) {
		result += [_searchPlacesResults count] + 1;
	}
	
	if ( ([id_caricati count] > 0) && ([id_caricati count] < 4) ) {
		result += [id_caricati count] - 1 + (allUsersHaveBeenLoaded ? 0 : 1);
	}
	else if ([id_caricati count] > 0) {
		result += [id_caricati count] + 1 + (allUsersHaveBeenLoaded ? 0 : 1);
	}
	
	if ([_nearbyPlacesResults count] > 0) {
		result += [_nearbyPlacesResults count] + 1;
	}
	
	if (allPlacesHaveBeenLoaded) {
		result--;
	}
	
	return result;
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
