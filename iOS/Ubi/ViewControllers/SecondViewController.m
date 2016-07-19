//
//  SecondViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 06/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

#pragma mark - ViewController lyfe cycle
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	id_caricati = [defaults objectForKey:@"id_caricati"];
    NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
    dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"Connessione Internet Assente"
									message:@"Connettiti ad internet per poter utilizzare Ubi."
								   delegate:self
						  cancelButtonTitle:@"OK!"
						  otherButtonTitles:nil] show];
	}
	else
	{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[self loadTimeline];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
    currentUbiUser = [[UbiUser alloc] initFromCache];
    
    [_collectionView setContentInset:UIEdgeInsetsMake(8, 0, 8, 0)];
	
	self.navigationController.delegate = self;
	
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
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController.title isEqualToString:@"Nearby You"]) {
		[self viewWillAppear:animated];
	}
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_collectionView reloadData];
}

- (void)loadTimeline
{
	NSString * user_ids = [NSString stringWithFormat:@""];
	
	for (NSString * userEmail in id_caricati) {
		UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:userEmail];
		user_ids = [NSString stringWithFormat:@"%@%@%@", user_ids, (user_ids.length > 0 ? @" " : @""), newUbiUser.db_id];
	}
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"user_ids": user_ids};

    [manager POST:[NSString stringWithFormat:@"%@/read_timeline.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
	UbiUser * newUbiUser  = [dati_utenti_caricati objectForKey:newUbiStatus.author_id];
	
	[cell initProfileImgView:indexPath :newUbiUser.profile_pic];
	
    UITapGestureRecognizer *singleTapProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedSV:)];
    singleTapProfilePic.numberOfTapsRequired = 1;
    [cell.imgViewProfilo setUserInteractionEnabled:YES];
    [cell.imgViewProfilo addGestureRecognizer:singleTapProfilePic];
    
    cell.lblNome.text = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
    cell.lblNome.tag = indexPath.row;
    
    UITapGestureRecognizer *singleTapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedSV:)];
    singleTapName.numberOfTapsRequired = 1;
    [cell.lblNome setUserInteractionEnabled:YES];
    [cell.lblNome addGestureRecognizer:singleTapName];
	
    [cell initLblData:newUbiStatus.status_date];
    
    [cell initLblTags:newUbiStatus.tags];
    
    [cell initLblLoc:newUbiStatus.status_place];
	
	[cell.txtViewPost setText:nil];
    [cell initTxtViewPost:newUbiStatus.content_text];
	[cell.txtViewPost setTag:indexPath.row];
	UITapGestureRecognizer *singleTaptxtViewPost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txtViewPostTapDetectedSV:)];
	singleTaptxtViewPost.numberOfTapsRequired = 1;
	[cell.txtViewPost setUserInteractionEnabled:YES];
	[cell.txtViewPost addGestureRecognizer:singleTaptxtViewPost];
	
    [cell initImgViewMedia:newUbiStatus.content_media];
    
    [cell initLblLikesComm:[NSNumber numberWithUnsignedInteger:newUbiStatus.likes_array.count] :newUbiStatus.comments_num :indexPath];
    
    UITapGestureRecognizer *singleTaplblLikesComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesCommTapDetectedSV:)];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int finalHeight = 410;
	UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:indexPath.row];
	
    if ( !([newUbiStatus.content_text length] > 0) ) {
        finalHeight -= 70;
    }
    
    if ( !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
    {
        if ([newUbiStatus.content_text length] > 0 && [newUbiStatus.content_text length] < 21) { finalHeight -= 34; }
        else if ([newUbiStatus.content_text length] > 21 && [newUbiStatus.content_text length] < 43) { finalHeight -= 25; }
    }
	
    if ([newUbiStatus.content_media.absoluteString isEqualToString:@"NO_MEDIA"]) {
        finalHeight -= 185;
    }
	
	CGSize newCellSize = _collectionView.frame.size;
	newCellSize.height = finalHeight;
	newCellSize.width -= 16;
	
	return newCellSize;
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowStatusDetailsView" sender:newUbiStatus];
}

- (void)txtViewPostTapDetectedSV:(UIGestureRecognizer *)sender
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

- (IBAction)createNewPost:(id)sender {
	UIActionSheet * commentAS = [[UIActionSheet alloc] initWithTitle:@"New Post:"
															delegate:self
												   cancelButtonTitle:@"Cancel"
											  destructiveButtonTitle:nil
												   otherButtonTitles:@"New Status", @"New Event", nil];
	[commentAS showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"New Status"]) {
		[self performSegueWithIdentifier:@"ShowNewStatusView" sender:self];
	}
	else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"New Event"]) {
		[self performSegueWithIdentifier:@"ShowNewEventView" sender:self];
	}
}

- (void)likesCommTapDetectedSV:(UIGestureRecognizer *)sender
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
    if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
        UbiUser *selectedUbiUser = (UbiUser *)sender;
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedUbiUser = selectedUbiUser;
    }
    else if ([segue.identifier isEqualToString:@"ShowStatusDetailsView"]) {
        UbiStatus * newUbiStatus = (UbiStatus *)sender;
        UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:newUbiStatus.author_id];
        
        StatusDetailsViewController *destinationViewController = (StatusDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedStatus = newUbiStatus;
        destinationViewController.selectedUser = newUbiUser;
    }
	else if ([segue.identifier isEqualToString:@"ShowNewStatusDetailsView"]) {
	}
	else if ([segue.identifier isEqualToString:@"ShowNewEventView"]) {
	}
}

- (void)profileTapDetectedSV:(UIGestureRecognizer *)sender
{
    UbiStatus * newUbiStatus = [statusCaricati objectAtIndex:(long)sender.view.tag];
    UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:newUbiStatus.author_id];
    [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
}

#pragma mark - Helper methods
- (NSString *)stringByStrippingHTML:(NSString *)text
{
    if (!text) {
        return @"";
    }
    
    NSRange r;
    while ((r = [text rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        text = [text stringByReplacingCharactersInRange:r withString:@""];
    
    return text;
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
