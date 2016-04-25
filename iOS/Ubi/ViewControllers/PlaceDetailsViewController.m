//
//  DetailViewController.m
//  GooglePlacesApi
//
//  Created by Rambod Rahmani on 18/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "PlaceDetailsViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface PlaceDetailsViewController ()

@end

@implementation PlaceDetailsViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_btnPost.layer.borderWidth = 1;
	_btnPost.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnPost.layer.cornerRadius = 10;
	
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
	
	currentUbiUser = [[UbiUser alloc] initFromCache];
	
	reviewRating = 0;
	
	_img_view_start_1.tag = 1;
	UITapGestureRecognizer *singleTapRatingStar_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ratingStarTapDetected:)];
	singleTapRatingStar_1.numberOfTapsRequired = 1;
	[_img_view_start_1 setUserInteractionEnabled:YES];
	[_img_view_start_1 addGestureRecognizer:singleTapRatingStar_1];
	
	_img_view_start_2.tag = 2;
	UITapGestureRecognizer *singleTapRatingStar_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ratingStarTapDetected:)];
	singleTapRatingStar_2.numberOfTapsRequired = 1;
	[_img_view_start_2 setUserInteractionEnabled:YES];
	[_img_view_start_2 addGestureRecognizer:singleTapRatingStar_2];
	
	_img_view_start_3.tag = 3;
	UITapGestureRecognizer *singleTapRatingStar_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ratingStarTapDetected:)];
	singleTapRatingStar_3.numberOfTapsRequired = 1;
	[_img_view_start_3 setUserInteractionEnabled:YES];
	[_img_view_start_3 addGestureRecognizer:singleTapRatingStar_3];
	
	_img_view_start_4.tag = 4;
	UITapGestureRecognizer *singleTapRatingStar_4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ratingStarTapDetected:)];
	singleTapRatingStar_4.numberOfTapsRequired = 1;
	[_img_view_start_4 setUserInteractionEnabled:YES];
	[_img_view_start_4 addGestureRecognizer:singleTapRatingStar_4];
	
	_img_view_start_5.tag = 5;
	UITapGestureRecognizer *singleTapRatingStar_5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ratingStarTapDetected:)];
	singleTapRatingStar_5.numberOfTapsRequired = 1;
	[_img_view_start_5 setUserInteractionEnabled:YES];
	[_img_view_start_5 addGestureRecognizer:singleTapRatingStar_5];
	
	// Set keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	loaded_reviews = [[NSMutableArray alloc] init];
	
	[self setTitle:@"Place Details"];
	_mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
	
	[self loadAddress];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)loadAddress {
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
	NSNumber * timeZoneInMins = [NSNumber numberWithFloat:(float)(timeZoneOffset*60)];
	
	NSDictionary *params = @{
							 @"places_google_id": _selectedAddress.place_google_id,
							 @"date_utc_offset": timeZoneInMins
							 };
	
	[manager POST:[NSString stringWithFormat:@"%@/post_new_place.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (![operation.responseString containsString:@"ERROR"]) {
				NSError *error;
				NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
				
				if (!error) {
					for (NSDictionary *tmpDictionary in jsonArray)
					{
						double lat_id = [[[tmpDictionary objectForKey:@"place_lat"] description] floatValue];
						double long_id = [[[tmpDictionary objectForKey:@"place_lon"] description] floatValue];
						
						CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
						CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
						
						_selectedAddress = [[UbiPlace alloc] initWithParameters_db_id:[NSNumber numberWithInt:[[[tmpDictionary objectForKey:@"place_id"] description] intValue]]
																		   place_name:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_name"] description]]
																			place_lat:[NSNumber numberWithFloat:[[[tmpDictionary objectForKey:@"place_lat"] description] floatValue]]
																			place_lon:[NSNumber numberWithFloat:[[[tmpDictionary objectForKey:@"place_lon"] description] floatValue]]
																	   place_icon_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_icon_url"] description]]]
																		 place_string:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_string"] description]]
																	  place_google_id:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_google_id"] description]]
																		 place_rating:[NSNumber numberWithFloat:[[[tmpDictionary objectForKey:@"place_rating"] description] floatValue]]
																		  place_types:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_types"] description]]
																	place_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_website_url"] description]]]
																   place_phone_number:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_phone_number"] description]]
															   place_int_phone_number:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_int_phone_number"] description]]
																	 place_utc_offset:[NSNumber numberWithInt:[[[tmpDictionary objectForKey:@"place_utc_offset"] description] floatValue]]
																	 place_google_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_google_url"] description]]]
																	  place_cover_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tmpDictionary objectForKey:@"place_cover_pic_url"] description]]]
																	   place_distance:[NSNumber numberWithFloat:distance]];
						
						[self setTitle:_selectedAddress.place_name];
						
						[self updateTableViewContent];
						
						[self loadAddressReviews];
					}
				}
				else {
					[self showErrorMessage:error.description];
				}
			} else {
				[self showErrorMessage:[NSString stringWithFormat:@"loadAddress: %@", operation.responseString]];
			}
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:[NSString stringWithFormat:@"loadAddress: %@", error.description]];
	}];
}

- (void)loadAddressReviews {
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSDictionary *params = @{@"place_id": _selectedAddress.db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_place_reviews.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			dati_utenti_caricati = [[NSMutableDictionary alloc] init];
			loaded_reviews = [[NSMutableArray alloc] init];
			
			NSError *error;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					double lat_id = [[[tempDictionary objectForKey:@"user_lat"] description] floatValue];
					double long_id = [[[tempDictionary objectForKey:@"user_lon"] description] floatValue];
					
					CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
					CLLocation * userLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([currentUbiUser.latitude floatValue], [currentUbiUser.longitude floatValue]) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
					CLLocationDistance distance = [location distanceFromLocation:userLoc];
					
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
					[dati_utenti_caricati setObject:newUbiUser forKey:newUbiUser.db_id];
					
					UbiPlaceReview * newReview = [[UbiPlaceReview alloc] initWithParametersReview_id:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"review_id"] description] floatValue]]
																							place_id:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_id"] description] floatValue]]
																							 user_id:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"user_id"] description] floatValue]]
																						 review_text:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"review_text"] description]]
																					   review_rating:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"review_rating"] description] floatValue]]
																						 review_date:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"review_date"] description]]];
					[loaded_reviews addObject:newReview];
				}
			}
			else
			{
				[self showErrorMessage:[NSString stringWithFormat:@"loadAddressReviews: %@", error.description]];
			}
			
			[_mainCollectionView reloadData];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:[NSString stringWithFormat:@"loadAddressReviews: %@", error.description]];
	}];
	
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return loaded_reviews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ReviewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlaceReviewCell" forIndexPath:indexPath];
	UbiPlaceReview * newReview = [loaded_reviews objectAtIndex:indexPath.row];
	UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:newReview.user_id];
	
	cell.contentView.frame = cell.bounds;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	cell.lblNome.text = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
	cell.lblNome.tag = indexPath.row;
	
	UITapGestureRecognizer *singleTapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedPD:)];
	singleTapName.numberOfTapsRequired = 1;
	[cell.lblNome setUserInteractionEnabled:YES];
	[cell.lblNome addGestureRecognizer:singleTapName];
	
	NSArray * splitter = [newReview.review_date componentsSeparatedByString:@"-"];
	int monthNumber = [[splitter objectAtIndex:1] intValue];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	NSString *monthName = [[df monthSymbols] objectAtIndex:(monthNumber-1)];
	NSString *shortMonthName = [monthName substringToIndex:3];
	cell.lblData.text = [NSString stringWithFormat:@"%d %@ %d", [[splitter objectAtIndex:2] intValue], shortMonthName, [[splitter objectAtIndex:0] intValue]];
	
	[cell.txtViewReview setText:nil];
	cell.txtViewReview.text = newReview.review_text;
	cell.txtViewReview.tag = indexPath.row;
	UITapGestureRecognizer *singleTapRevCell = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewCellTapDetected:)];
	singleTapRevCell.numberOfTapsRequired = 1;
	[cell.txtViewReview setUserInteractionEnabled:YES];
	[cell.txtViewReview addGestureRecognizer:singleTapRevCell];
	//[cell.txtViewReview scrollRangeToVisible:NSMakeRange(0, 0)];
	
	[cell initProfileImgView:indexPath :newUbiUser.profile_pic];

	UITapGestureRecognizer *singleTapProfilePicComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedPD:)];
	singleTapProfilePicComm.numberOfTapsRequired = 1;
	[cell.imgViewProfilo setUserInteractionEnabled:YES];
	[cell.imgViewProfilo addGestureRecognizer:singleTapProfilePicComm];
	
	[cell.imgViewRating setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@stelle.png", newReview.review_rating]]];
	
	if (indexPath.row == loaded_reviews.count - 1) {
		cell.separatorView.hidden = YES;
	} else {
		cell.separatorView.hidden = NO;
	}
	
	return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize newCellSize = _mainCollectionView.frame.size;
	newCellSize.height = 174;
	newCellSize.width -= 16;
	
	return newCellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	CGSize newCellSize = _mainCollectionView.frame.size;
	newCellSize.height = 342;
	return newCellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (loaded_reviews.count > 0)
	{
		UbiPlaceReview * newReview = [loaded_reviews objectAtIndex:indexPath.row];
		if ([newReview.user_id isEqualToNumber:currentUbiUser.db_id])
		{
			UIActionSheet * reviewAS = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Review: %@", newReview.review_text]
																   delegate:self
														  cancelButtonTitle:@"Cancel"
													 destructiveButtonTitle:nil
														  otherButtonTitles:@"Delete Comment", nil];
			reviewAS.tag = indexPath.row;
			[reviewAS showInView:self.view];
		}
	}
}

- (void)reviewCellTapDetected:(UIGestureRecognizer *)sender
{
	if (loaded_reviews.count > 0)
	{
		UbiPlaceReview * newReview = [loaded_reviews objectAtIndex:(long)sender.view.tag];
		if ([newReview.user_id isEqualToNumber:currentUbiUser.db_id])
		{
			UIActionSheet * reviewAS = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Review: %@", newReview.review_text]
																   delegate:self
														  cancelButtonTitle:@"Cancel"
													 destructiveButtonTitle:nil
														  otherButtonTitles:@"Delete Review", nil];
			reviewAS.tag = (long)sender.view.tag;
			[reviewAS showInView:self.view];
		}
	}
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *reusableview = nil;
	
	if (kind == UICollectionElementKindSectionHeader) {
		ReviewsHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReviewsHeaderView" forIndexPath:indexPath];
		
		[headerView.imgViewIcon sd_setImageWithURL:_selectedAddress.place_icon_url placeholderImage:[UIImage imageNamed:@""]];
		
		if (loaded_place_pictures.count > 0) {
			coverImage = [loaded_place_pictures objectAtIndex:0];
			[headerView.imgViewCover setImage:[loaded_place_pictures objectAtIndex:0]];
		}
		else {
			SDImageCache *imageCache = [SDImageCache sharedImageCache];
			[imageCache queryDiskCacheForKey:_selectedAddress.place_cover_pic.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
				if (image) {
					coverImage = image;
					[headerView.imgViewCover setImage:image];
				}
				else {
					[SDWebImageDownloader.sharedDownloader downloadImageWithURL:_selectedAddress.place_cover_pic
																		options:0
																	   progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
																	  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
																		  if (image && finished) {
																			  coverImage = image;
																			  [headerView.imgViewCover setImage:image];
																			  [[SDImageCache sharedImageCache] storeImage:image forKey:_selectedAddress.place_cover_pic.absoluteString toDisk:YES];
																		  }
																	  }];
				}
			}];
		}
		
		UITapGestureRecognizer *singleTapRevCellHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewCellHeaderImageTapDetected:)];
		singleTapRevCellHeader.numberOfTapsRequired = 1;
		[headerView.imgViewCover setUserInteractionEnabled:YES];
		[headerView.imgViewCover addGestureRecognizer:singleTapRevCellHeader];
		
		headerView.lblNome.text = _selectedAddress.place_name;
		
		headerView.lbl_place_string.text = _selectedAddress.place_string;

		headerView.detailsTableView.delegate = self;
		headerView.detailsTableView.dataSource = self;
		[headerView.detailsTableView reloadData];
		
		[headerView.btnVediSullaMappa addTarget:self action:@selector(showOnMap) forControlEvents:UIControlEventTouchUpInside];
		headerView.btnVediSullaMappa.layer.borderWidth = 1;
		headerView.btnVediSullaMappa.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		headerView.btnVediSullaMappa.layer.cornerRadius = 10;
		
		[headerView.btnVediFoto addTarget:self action:@selector(showPlacePictures) forControlEvents:UIControlEventTouchUpInside];
		headerView.btnVediFoto.layer.borderWidth = 1;
		headerView.btnVediFoto.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		headerView.btnVediFoto.layer.cornerRadius = 10;
		
		headerView.btnInfo.layer.borderWidth = 1;
		headerView.btnInfo.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		headerView.btnInfo.layer.cornerRadius = 10;

		[headerView.imgViewRating setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ldstelle.png", (long)[_selectedAddress.place_rating integerValue]]]];
		
		reusableview = headerView;
	}
	
	return reusableview;
}

- (void)showPlacePictures
{
	[self performSegueWithIdentifier:@"ShowImagesGalleryView" sender:self];
}

- (void)reviewCellHeaderImageTapDetected:(UIGestureRecognizer *)sender
{
	if (coverImage) {
		[self performSegueWithIdentifier:@"ShowImageviewView" sender:nil];
	}
}

#pragma mark - Tableview Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_responseTableRepresentation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSString *key = [_responseTableRepresentation allKeys][indexPath.row];
	
	cell.textLabel.text = key;
	cell.detailTextLabel.text = [_responseTableRepresentation[key] description];
	
	return cell;
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		if ( (loaded_reviews.count > 0) && ((int)actionSheet.tag < loaded_reviews.count) )
		{
			UbiPlaceReview * newReview = [loaded_reviews objectAtIndex:(int)actionSheet.tag];
			if ([actionSheet.title isEqualToString:[NSString stringWithFormat:@"Review: %@", newReview.review_text]])
			{
				[newReview dropPlaceReview];
				
				[loaded_reviews removeObject:newReview];
				[_mainCollectionView reloadData];
				[_reviewTextField resignFirstResponder];
			}
		}
	}
}

- (void)profileTapDetectedPD:(UIGestureRecognizer *)sender
{
	UbiPlaceReview * newReview = [loaded_reviews objectAtIndex:sender.view.tag];
	UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:[NSNumber numberWithInt:[[newReview valueForKey:@"user_id"] intValue]]];
	[self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
		UbiUser *selectedUbiUser = (UbiUser *)sender;
		UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
		destinationViewController.selectedUbiUser = selectedUbiUser;
	}
	else if ([segue.identifier isEqualToString:@"ShowImageviewView"]) {
		UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
		ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
		destinationViewController.selectedImage = coverImage;
	}
	else if ([segue.identifier isEqualToString:@"ShowWebviewView"]) {
		UINavigationController *destinationViewNavController = (UINavigationController *)segue.destinationViewController;
		WebViewViewController *destinationViewController = destinationViewNavController.viewControllers[0];
		destinationViewController.selectedURL = _selectedAddress.place_google_url;
		destinationViewController.webTitle = [NSString stringWithFormat:@"%@", _selectedAddress.place_name];
	}
	else if ([segue.identifier isEqualToString:@"ShowImagesGalleryView"]) {
		ImagesGalleryViewController *destinationViewController = (ImagesGalleryViewController *)segue.destinationViewController;
		destinationViewController.selectedUbiPlace = _selectedAddress;
	}
}

#pragma mark - Post Review for Address
- (void)ratingStarTapDetected:(UIGestureRecognizer *)sender
{
	if (sender.view.tag == 1) {
		[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	}
	
	if (sender.view.tag >= 2) {
		[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	}
	
	if (sender.view.tag >= 3) {
		[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
		[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	}
	
	if (sender.view.tag >= 4) {
		[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	}
	
	if (sender.view.tag >= 5) {
		[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStar.png"]];
		[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStar.png"]];
	}
	
	reviewRating = sender.view.tag;
}

- (IBAction)post_place_review:(id)sender {
	if (reviewRating > 0 && _reviewTextField.text.length > 0) {
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		
		NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
		NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
		float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
		NSNumber * timeZoneInMins = [NSNumber numberWithFloat:(float)(timeZoneOffset*60)];
		
		NSDictionary *params = @{@"place_id": (_selectedAddress.db_id ? _selectedAddress.db_id : @"N/A"),
								 @"user_id": currentUbiUser.db_id,
								 @"review_text": _reviewTextField.text,
								 @"review_rating": [NSNumber numberWithInteger:reviewRating],
								 @"$review_date": @"",
								 
								 @"place_review_date_utc_offset": timeZoneInMins};
		
		[manager POST:[NSString stringWithFormat:@"%@/post_place_review.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (![operation.responseString containsString:@"ERROR"]) {
					NSNumber * review_id = [NSNumber numberWithFloat:[operation.responseString floatValue]];
					
					for (UbiPlaceReview * review in loaded_reviews) {
						if ([review.user_id isEqualToNumber:currentUbiUser.db_id]) {
							review_id = review.db_id;
							[loaded_reviews removeObject:review];
							break;
						}
					}
					
					NSDateFormatter *formatter;
					NSString * reviewDate;
					formatter = [[NSDateFormatter alloc] init];
					[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
					reviewDate = [formatter stringFromDate:[NSDate date]];
					
					UbiPlaceReview * newReview = [[UbiPlaceReview alloc] initWithParametersReview_id:review_id
																							place_id:_selectedAddress.db_id
																							 user_id:currentUbiUser.db_id
																						 review_text:_reviewTextField.text
																					   review_rating:[NSNumber numberWithInteger:reviewRating]
																						 review_date:reviewDate];
					[loaded_reviews addObject:newReview];
					[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
					[_mainCollectionView reloadData];
					
					[_reviewTextField setText:@""];
					[_reviewTextField resignFirstResponder];
					[self clearRatingStarts];
					
				} else {
					[self showErrorMessage:operation.responseString];
				}
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:[NSString stringWithFormat:@"Something went wrong. Please retry. Message: %@", error.description]];
		}];
	}
	else {
		
	}
}

- (void)clearRatingStarts {
	[_img_view_start_1 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	[_img_view_start_2 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	[_img_view_start_3 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	[_img_view_start_4 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
	[_img_view_start_5 setImage:[UIImage imageNamed:@"singleStarBW.png"]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note
{
	_collViewBottomConstraint.constant = 213;
	_ratings_view.hidden = NO;
	
	[UIView animateWithDuration:0.3 animations:^{
		_txtFieldBgView.transform = CGAffineTransformMakeTranslation(0, -167);
		_ratings_view.transform = CGAffineTransformMakeTranslation(0, -167);
		_mainCollectionView.frame = CGRectMake(_mainCollectionView.frame.origin.x,
											   _mainCollectionView.frame.origin.y,
											   _mainCollectionView.frame.size.width,
											   _mainCollectionView.frame.size.height - 167);
	} completion:^(BOOL finished) {
		[self scrollToLastItemAnimated:YES];
	}];
}

- (void)keyboardWillHide:(NSNotification *)note
{
	_collViewBottomConstraint.constant = 0;
	_ratings_view.hidden = YES;
	
	[UIView animateWithDuration:0.3 animations:^{
		_txtFieldBgView.transform = CGAffineTransformIdentity;
		_ratings_view.transform = CGAffineTransformIdentity;
		_mainCollectionView.frame = CGRectMake(_mainCollectionView.frame.origin.x,
											   _mainCollectionView.frame.origin.y,
											   _mainCollectionView.frame.size.width,
											   _mainCollectionView.frame.size.height + 167);
	} completion:^(BOOL finished) {
		[self scrollToLastItemAnimated:YES];
	}];
}

- (void)scrollToLastItemAnimated:(BOOL)animated;
{
	if (loaded_reviews.count == 0) { return; }
	
	NSIndexPath *path = [NSIndexPath indexPathForItem:loaded_reviews.count - 1
											inSection:0];
	
	[_mainCollectionView scrollToItemAtIndexPath:path
								atScrollPosition:UICollectionViewScrollPositionCenteredVertically
										animated:animated];
}

#pragma mark - Helper Methods
- (void)showOnMap
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"placeDetailViewData" object:_selectedAddress];
	if (self.tabBarController.selectedIndex == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	[self.tabBarController setSelectedIndex:0];
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

- (void)updateTableViewContent {
	_responseTableRepresentation = @{
									 //@"DB_ID": (_selectedAddress.db_id ? : @"N/A"),
									 @"Name": (_selectedAddress.place_name ? : @"N/A"),
									 @"Location": [NSString stringWithFormat:@"(%@, %@)", _selectedAddress.place_lat, _selectedAddress.place_lon],
									 //@"ICON_URL": (_selectedAddress.place_icon_url ? : @"N/A"),
									 @"Address": (_selectedAddress.place_string ? : @"N/A"),
									 @"Form. phone": (_selectedAddress.place_phone_number ? : @"N/A"),
									 @"Int. phone": (_selectedAddress.place_int_phone_number ? : @"N/A"),
									 @"Rating": (_selectedAddress.place_rating ? : @"N/A"),
									 @"Types": (_selectedAddress.place_types ? : @"N/A"),
									 @"Website:": (_selectedAddress.place_website_url ? : @"N/A"),
									 @"URL:": (_selectedAddress.place_google_url ? : @"N/A"),
									 //@"Reference": (_selectedAddress.place_google_id ? : @"N/A"),
									 @"UTC Offset": (_selectedAddress.place_utc_offset ? : @"N/A"),
									 //@"Cover Pic URL": (_selectedAddress.place_cover_pic ? : @"N/A"),
									 };
	
	[_mainCollectionView reloadData];
}

@end
