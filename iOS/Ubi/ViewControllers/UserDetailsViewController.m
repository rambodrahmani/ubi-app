//
//  UserDetailViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 24/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UserDetailsViewController.h"

@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (void)viewDidLoad
{
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
	
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 8, 0)];

    currentUbiUser = [[UbiUser alloc] initFromCache];
    if ([_selectedUbiUser.db_id isEqualToNumber:currentUbiUser.db_id]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showNewPostView)];
        [self.navigationItem setRightBarButtonItem:rightButton];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
	[self setTitle:_selectedUbiUser.name];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadTimeline];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_collectionView reloadData];
}

- (void)showNewPostView
{
    [self performSegueWithIdentifier:@"ShowNewStatusView" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)applyBlurOnImage:(UIImage *)imageToBlur withRadius:(CGFloat)blurRadius
{
    UIImage *returnImage = nil;
    
    if ((blurRadius <= 0.0f) || (blurRadius > 1.0f)) {
        blurRadius = 0.5f;
    }
    int boxSize = (int)(blurRadius * 100);
    boxSize -= (boxSize % 2) + 1;
    CGImageRef rawImage = imageToBlur.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(imageToBlur.CGImage));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    returnImage = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
	return returnImage;
}

- (void)loadTimeline
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSDictionary *params = @{@"user_id": _selectedUbiUser.db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_user_timeline.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		statusCaricati = [[NSMutableArray alloc] init];
		
		NSError* error;
		NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
		
		if (!error) {
			for (NSDictionary *tempDictionary in jsonArray) {
				
				NSArray* tags = [[NSArray alloc] init];
				NSMutableArray* taggedPeople = [[NSMutableArray alloc] init];
				if (![[tempDictionary objectForKey:@"tags"] isKindOfClass:[NSString class]]) {
					tags = [tempDictionary objectForKey:@"tags"];
					for (NSDictionary *tempDictionary_1 in tags) {
						UbiStatusTag * status_tag = [[UbiStatusTag alloc] initWithParametersStatusID:[tempDictionary_1 objectForKey:@"status_id"]
																							 user_id:[tempDictionary_1 objectForKey:@"user_id"]
																						   user_name:[tempDictionary_1 objectForKey:@"user_name"]
																						user_surname:[tempDictionary_1 objectForKey:@"user_surname"]];
						[taggedPeople addObject:status_tag];
					}
				}
				
				UbiPlace * newUbiPlace = [[UbiPlace alloc] init];
				newUbiPlace.place_name = @"NO_LOC";
				NSDictionary* addressDic = [[NSDictionary alloc] init];
				if (![[tempDictionary objectForKey:@"place"] isKindOfClass:[NSString class]]) {
					addressDic = [tempDictionary objectForKey:@"place"];
					
					double lat_id = [[[addressDic objectForKey:@"place_lat"] description] floatValue];
					double long_id = [[[addressDic objectForKey:@"place_lon"] description] floatValue];
					
					CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
					CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
					
					newUbiPlace = [[UbiPlace alloc] initWithParameters_db_id:[NSNumber numberWithInt:[[[addressDic objectForKey:@"place_id"] description] intValue]]
																  place_name:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_name"] description]]
																   place_lat:[NSNumber numberWithFloat:[[[addressDic objectForKey:@"place_lat"] description] floatValue]]
																   place_lon:[NSNumber numberWithFloat:[[[addressDic objectForKey:@"place_lon"] description] floatValue]]
															  place_icon_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_icon_url"] description]]]
																place_string:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_string"] description]]
															 place_google_id:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_google_id"] description]]
																place_rating:[NSNumber numberWithFloat:[[[addressDic objectForKey:@"place_rating"] description] floatValue]]
																 place_types:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_types"] description]]
														   place_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_website_url"] description]]]
														  place_phone_number:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_phone_number"] description]]
													  place_int_phone_number:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_int_phone_number"] description]]
															place_utc_offset:[NSNumber numberWithInt:[[[addressDic objectForKey:@"place_utc_offset"] description] floatValue]]
															place_google_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_google_url"] description]]]
															 place_cover_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[addressDic objectForKey:@"place_cover_pic_url"] description]]]
															  place_distance:[NSNumber numberWithFloat:distance]];
				}
				
				NSArray* likes_array = [[NSArray alloc] init];
				NSMutableArray * likes_ids = [[NSMutableArray alloc] init];
				if (![[tempDictionary objectForKey:@"likes"] isKindOfClass:[NSString class]]) {
					likes_array = [tempDictionary objectForKey:@"likes"];
					
					for (NSDictionary * like_dic in likes_array) {
						[likes_ids addObject:[NSNumber numberWithInt:[[like_dic valueForKey:@"user_id"] intValue]]];
					}
				}
				
				NSNumber * commentsCount = [NSNumber numberWithInt:0];
				if (![[tempDictionary objectForKey:@"comments"] isKindOfClass:[NSString class]]) {
					commentsCount = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"comments"] objectForKey:@"comments_num"] intValue]];
				}
				
				NSDictionary* statusDic = [tempDictionary objectForKey:@"status"];
				
				UbiStatus * newUbiStatus = [[UbiStatus alloc] initWithParametersStatusID:[NSNumber numberWithInt:[[statusDic objectForKey:@"status_id"] intValue]]
																			   author_id:[NSNumber numberWithInt:[[statusDic objectForKey:@"status_author_id"] intValue]]
																		   content_media:[NSURL URLWithString:[[statusDic objectForKey:@"status_content_media"] description]]
																			content_text:[NSString stringWithFormat:@"%@", [[statusDic objectForKey:@"status_content_text"] description]]
																			 status_date:[NSString stringWithFormat:@"%@", [[statusDic objectForKey:@"status_date"] description]]
																			 likes_array:likes_ids
																			comments_num:commentsCount
																		 status_place:newUbiPlace
																					tags:taggedPeople];
				[statusCaricati addObject:newUbiStatus];
			}
		}
		else
		{
			[self showErrorMessage:error.description];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			[_collectionView reloadData];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

#pragma mark - UICollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [statusCaricati count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimelineCell" forIndexPath:indexPath];
	
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:indexPath.row];
    
	[cell initProfileImgView:indexPath :_selectedUbiUser.profile_pic];
	
    cell.lblNome.text = [NSString stringWithFormat:@"%@ %@", _selectedUbiUser.name, _selectedUbiUser.surname];
    cell.lblNome.tag = indexPath.row;
    
    [cell initLblData:newUbiStatus.status_date];
    
    [cell initLblTags:newUbiStatus.tags];
    
    [cell initLblLoc:newUbiStatus.status_place];
	
	[cell.txtViewPost setText:nil];
    [cell initTxtViewPost:newUbiStatus.content_text];
	[cell.txtViewPost setTag:indexPath.row];
	UITapGestureRecognizer *singleTaptxtViewPost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txtViewPostTapDetected:)];
	singleTaptxtViewPost.numberOfTapsRequired = 1;
	[cell.txtViewPost setUserInteractionEnabled:YES];
	[cell.txtViewPost addGestureRecognizer:singleTaptxtViewPost];
	
    [cell initImgViewMedia:newUbiStatus.content_media];
    
    [cell initLblLikesComm:[NSNumber numberWithUnsignedInteger:newUbiStatus.likes_array.count] :newUbiStatus.comments_num :indexPath];
	
    UITapGestureRecognizer *singleTaplblLikesComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesCommTapDetected:)];
    singleTaplblLikesComm.numberOfTapsRequired = 1;
    [cell.lblLikesComm setUserInteractionEnabled:YES];
    [cell.lblLikesComm addGestureRecognizer:singleTaplblLikesComm];
    
    UITapGestureRecognizer *singleTapBtnComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnCommTapDetected:)];
    singleTapBtnComm.numberOfTapsRequired = 1;
    cell.btnComm.tag = indexPath.row;
    [cell.btnComm setUserInteractionEnabled:YES];
    [cell.btnComm addGestureRecognizer:singleTapBtnComm];
	cell.btnComm.layer.borderWidth = 1;
	cell.btnComm.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	cell.btnComm.layer.cornerRadius = 10;
	
	if ( [newUbiStatus.likes_array containsObject:currentUbiUser.db_id] ) {
		[cell.btnLike setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	} else {
		[cell.btnLike setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
	}
	
	cell.btnLike.tag = indexPath.row;
	[cell.btnLike addTarget:self action:@selector(btnLikeTapped:) forControlEvents:UIControlEventTouchUpInside];
	cell.btnLike.layer.borderWidth = 1;
	cell.btnLike.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	cell.btnLike.layer.cornerRadius = 10;
	
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *reusableview = nil;
	
	if (kind == UICollectionElementKindSectionHeader) {
		UserDetailsHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UserDetailsHeaderView" forIndexPath:indexPath];
		
		SDImageCache *imageCache = [SDImageCache sharedImageCache];
		[imageCache queryDiskCacheForKey:_selectedUbiUser.profile_pic.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
			if (image) {
				[headerView.imgViewCover setImage:[self applyBlurOnImage:image withRadius:0.5f]];
				[headerView.imgViewProfile setImage:image];
			}
			else {
				[SDWebImageDownloader.sharedDownloader downloadImageWithURL:_selectedUbiUser.profile_pic
																	options:0
																   progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
																  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
																	  if (image && finished) {
																		  [headerView.imgViewCover setImage:[self applyBlurOnImage:image withRadius:0.5f]];
																		  [headerView.imgViewProfile setImage:image];
																		  [[SDImageCache sharedImageCache] storeImage:image forKey:_selectedUbiUser.profile_pic.absoluteString toDisk:YES];
																	  }
																  }];
			}
		}];
		
		[headerView.imgViewProfile setContentMode:UIViewContentModeScaleToFill];
		headerView.imgViewProfile.layer.cornerRadius = (headerView.imgViewProfile.frame.size.width/2);
		headerView.imgViewProfile.clipsToBounds = YES;
		UITapGestureRecognizer *singleTapProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetected:)];
		singleTapProfilePic.numberOfTapsRequired = 1;
		[headerView.imgViewProfile setUserInteractionEnabled:YES];
		[headerView.imgViewProfile addGestureRecognizer:singleTapProfilePic];
		
		[headerView.lblNome setText:[NSString stringWithFormat:@"%@ %@", _selectedUbiUser.name, _selectedUbiUser.surname]];
		
		[headerView.lblBio setText:[NSString stringWithFormat:@"%@", _selectedUbiUser.bio]];
		
		[headerView.toolbar setTranslucent:NO];
		
		[headerView.btnBuzz setAction:@selector(sendBuzz)];
		
		[headerView.btnDirectMessage setAction:@selector(sendDirectMessage)];
		
		[headerView.btnFriendRequest setAction:@selector(sendFriendRequest)];
		
		if ([_selectedUbiUser.db_id isEqualToNumber:currentUbiUser.db_id]) {
			[headerView.btnDirectMessage setStyle:UIBarButtonItemStylePlain];
			[headerView.btnDirectMessage setEnabled:NO];
			[headerView.btnDirectMessage setTitle:nil];
			
			[headerView.btnFriendRequest setStyle:UIBarButtonItemStylePlain];
			[headerView.btnFriendRequest setEnabled:NO];
			[headerView.btnFriendRequest setTitle:nil];
		}
		
		reusableview = headerView;
	}
	
	return reusableview;
}

- (void)sendBuzz
{
	// Create our Installation query
	PFQuery *pushQuery = [PFInstallation query];
	[pushQuery whereKey:@"User_DB_ID" equalTo:_selectedUbiUser.db_id];
 
	// Send push notification to query
	[PFPush sendPushMessageToQueryInBackground:pushQuery
								   withMessage:[NSString stringWithFormat:@"%@ %@ ti ha inviato un BUZZ!", currentUbiUser.name, currentUbiUser.surname]];
}

- (void)sendDirectMessage
{
	
}

- (void)sendFriendRequest
{
	// Create our Installation query
	PFQuery *pushQuery = [PFInstallation query];
	[pushQuery whereKey:@"User_DB_ID" equalTo:_selectedUbiUser.db_id];
 
	// Send push notification to query
	[PFPush sendPushMessageToQueryInBackground:pushQuery
								   withMessage:[NSString stringWithFormat:@"%@ %@ ti ha inviato una richiesta di amicizia!", currentUbiUser.name, currentUbiUser.surname]];
}

- (void)profileTapDetected:(UIGestureRecognizer *)sender
{
	[self performSegueWithIdentifier:@"ShowImageviewView" sender:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	CGSize newCellSize = _collectionView.frame.size;
	newCellSize.height = 180;
	return newCellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	int finalSize = 410;
	UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:indexPath.row];
	
	if ( !([newUbiStatus.content_text length] > 0) ) {
		finalSize -= 70;
	}
	
	if ( !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
	{
		if ([newUbiStatus.content_text length] > 0 && [newUbiStatus.content_text length] < 21) { finalSize -= 34; }
		else if ([newUbiStatus.content_text length] > 21 && [newUbiStatus.content_text length] < 43) { finalSize -= 25; }
	}
	
	if ([newUbiStatus.content_media.absoluteString isEqualToString:@"NO_MEDIA"]) {
		finalSize -= 185;
	}
	
	CGSize newCellSize = _collectionView.frame.size;
	newCellSize.height = finalSize;
	newCellSize.width -= 16;
	
    return newCellSize;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"ShowStatusDetailsView" sender:newUbiStatus];
}

- (void)txtViewPostTapDetected:(UIGestureRecognizer *)sender
{
	UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:(long)sender.view.tag];
	[self performSegueWithIdentifier:@"ShowStatusDetailsView" sender:newUbiStatus];
}

- (void)btnLikeTapped:(UIButton *)sender
{
	UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:(long)sender.tag];
	
	UbiStatusLike * status_like = [[UbiStatusLike alloc] initWithParametersStatusID:newUbiStatus.db_id
																			user_id:currentUbiUser.db_id];
	
	if ([newUbiStatus.likes_array containsObject:currentUbiUser.db_id]) {
		[status_like dropLike];
		
		NSMutableArray* newLikesArray = [[NSMutableArray alloc] initWithArray:newUbiStatus.likes_array];
		[newLikesArray removeObject:currentUbiUser.db_id];
		newUbiStatus.likes_array = [[NSArray alloc] initWithArray:newLikesArray];
		[statusCaricati removeObjectAtIndex:(long)sender.tag];
		[statusCaricati insertObject:newUbiStatus atIndex:(long)sender.tag];
		[_collectionView reloadData];
	}
	else {
		[status_like postLike];
		
		NSMutableArray* newLikesArray = [[NSMutableArray alloc] initWithArray:newUbiStatus.likes_array];
		[newLikesArray addObject:currentUbiUser.db_id];
		newUbiStatus.likes_array = [[NSArray alloc] initWithArray:newLikesArray];
		[statusCaricati removeObjectAtIndex:(long)sender.tag];
		[statusCaricati insertObject:newUbiStatus atIndex:(long)sender.tag];
		[_collectionView reloadData];
	}
}

- (void)likesCommTapDetected:(UIGestureRecognizer *)sender
{
    UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:(long)sender.view.tag];
    [self performSegueWithIdentifier:@"ShowStatusDetailsView" sender:newUbiStatus];
}

- (void)btnCommTapDetected:(UIGestureRecognizer *)sender
{
    UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:(long)sender.view.tag];
    [self performSegueWithIdentifier:@"ShowStatusDetailsView" sender:newUbiStatus];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowLikesView"]) {
        PeopleViewController * destinationViewController = (PeopleViewController *)segue.destinationViewController;
        destinationViewController.peopleEmails = (NSArray *)sender;
    }
    else if ([segue.identifier isEqualToString:@"ShowUserDetailView"]) {
        UbiUser *selectedUbiUser = (UbiUser *)sender;
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedUbiUser = selectedUbiUser;
    }
    else if ([segue.identifier isEqualToString:@"ShowStatusDetailsView"]) {
        UbiStatus * newUbiStatus = (UbiStatus *)sender;
        StatusDetailsViewController *destinationViewController = (StatusDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedStatus = newUbiStatus;
        destinationViewController.selectedUser = _selectedUbiUser;
    }
	else if ([segue.identifier isEqualToString:@"ShowImageviewView"]) {
		UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
		ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
		destinationViewController.selectedImageURL = _selectedUbiUser.profile_pic;
	}
}

#pragma mark - Helper methods
- (NSString *)stringByStrippingHTML:(NSString *)text
{
	NSRange r;
	while ((r = [text rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		text = [text stringByReplacingCharactersInRange:r withString:@""];
	return text;
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
