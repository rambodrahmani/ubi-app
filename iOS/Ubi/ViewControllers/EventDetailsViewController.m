//
//  EventDetailsViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 29/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

#pragma mark - ViewController lyfe cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = _ubi_event.event_name;
	
	_btnPost.layer.borderWidth = 1;
	_btnPost.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnPost.layer.cornerRadius = 10;
	
	currentUbiUser = [[UbiUser alloc] initFromCache];
	
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
	
	reviewRating = 0;
	loaded_reviews = [[NSMutableArray alloc] init];
	
	[self setTitle:_ubi_event.event_name];
	_mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
	
	[self loadEventParticipants];
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

- (void)loadEventParticipants
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSDictionary* params = @{@"event_id": _ubi_event.db_id};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_event_participants.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSError* error;
			NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					[_ubi_event.event_participants_ids addObject:[NSNumber numberWithInt:[[tempDictionary objectForKey:@"user_id"] intValue]]];
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			[_mainCollectionView reloadData];
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowImageviewView"]) {
		if (sender) {
			UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
			ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
			destinationViewController.selectedImageURL = _ubi_event.event_picture_url;
		}
		else {
			UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
			ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
			destinationViewController.selectedImage = coverImage;
		}
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [[UICollectionViewCell alloc] init];
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
	newCellSize.height = 245;
	return newCellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *reusableview = nil;
	
	if (kind == UICollectionElementKindSectionHeader) {
		EventHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EventHeaderView" forIndexPath:indexPath];
		
		[headerView.imgViewCover sd_setImageWithURL:_ubi_event.event_picture_url placeholderImage:[UIImage imageNamed:@""]];
		coverImage = headerView.imgViewCover.image;
		
		SDImageCache *imageCache = [SDImageCache sharedImageCache];
		[imageCache queryDiskCacheForKey:_ubi_event.event_picture_url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
			if (image) {
				coverImage = image;
				[headerView.imgViewCover setImage:[self applyBlurOnImage:image withRadius:0.5f]];
				[headerView.imgViewIcon setImage:image];
			}
			else {
				[SDWebImageDownloader.sharedDownloader downloadImageWithURL:_ubi_event.event_picture_url
																	options:0
																   progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
																  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
																	  if (image && finished) {
																		  coverImage = image;
																		  [headerView.imgViewCover setImage:[self applyBlurOnImage:image withRadius:0.5f]];
																		  [headerView.imgViewIcon setImage:image];
																		  [[SDImageCache sharedImageCache] storeImage:image forKey:_ubi_event.event_picture_url.absoluteString toDisk:YES];
																	  }
																  }];
			}
		}];
		
		[headerView.imgViewIcon setContentMode:UIViewContentModeScaleToFill];
		headerView.imgViewIcon.layer.cornerRadius = (headerView.imgViewIcon.frame.size.width/2);
		headerView.imgViewIcon.clipsToBounds = YES;
		UITapGestureRecognizer *singleTapProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetected:)];
		singleTapProfilePic.numberOfTapsRequired = 1;
		[headerView.imgViewIcon setUserInteractionEnabled:YES];
		[headerView.imgViewIcon addGestureRecognizer:singleTapProfilePic];
		
		UITapGestureRecognizer *singleTapRevCellHeader = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reviewCellHeaderImageTapDetected:)];
		singleTapRevCellHeader.numberOfTapsRequired = 1;
		[headerView.imgViewCover setUserInteractionEnabled:YES];
		[headerView.imgViewCover addGestureRecognizer:singleTapRevCellHeader];
		
		headerView.lblNome.text = _ubi_event.event_name;
		
		headerView.lbl_event_description.text = _ubi_event.event_description;
		
		if ([_ubi_event.event_participants_ids containsObject:currentUbiUser.db_id]) {
			buttonTitle = [[NSString alloc] initWithFormat:@"  Non Partecipare  "];
		}
		else {
			buttonTitle = [[NSString alloc] initWithFormat:@"  Partecipa  "];
		}
		
		[headerView.btnPartecipa setTitle:buttonTitle forState:UIControlStateNormal];
		[headerView.btnPartecipa addTarget:self action:@selector(joinEvent) forControlEvents:UIControlEventTouchUpInside];
		headerView.btnPartecipa.layer.borderWidth = 1;
		headerView.btnPartecipa.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		headerView.btnPartecipa.layer.cornerRadius = 10;
		
		[headerView.imgViewRating setHidden:YES];
		//[headerView.imgViewRating setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ldstelle.png", (long)[_ubi_event.place_rating integerValue]]]];
		
		reusableview = headerView;
	}
	
	return reusableview;
}

- (void)profileTapDetected:(UIGestureRecognizer *)sender
{
	[self performSegueWithIdentifier:@"ShowImageviewView" sender:self];
}

- (void)reviewCellHeaderImageTapDetected:(UIGestureRecognizer *)sender
{
	if (coverImage) {
		[self performSegueWithIdentifier:@"ShowImageviewView" sender:nil];
	}
}

- (void)joinEvent
{
	if ([buttonTitle isEqualToString:@"  Partecipa  "]) {
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		
		NSDictionary *params = @{@"event_id": _ubi_event.db_id,
								 @"user_id": currentUbiUser.db_id};
		
		[manager POST:[NSString stringWithFormat:@"%@/post_event_participant.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([operation.responseString containsString:@"ERROR"]) {
					[self showErrorMessage:operation.responseString];
				}
				else {
					buttonTitle = @"  Non Partecipare  ";
					[[[UIAlertView alloc] initWithTitle:@"Eventi"
												message:@"Partecipazione all'evento inserita."
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil] show];
					[_ubi_event.event_participants_ids addObject:currentUbiUser.db_id];
					[_mainCollectionView reloadItemsAtIndexPaths:[_mainCollectionView indexPathsForVisibleItems]];
					[_mainCollectionView reloadData];
				}
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
		}];
	}
	else if ([buttonTitle isEqualToString:@"  Non Partecipare  "])
	{
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		
		NSDictionary *params = @{@"event_id": _ubi_event.db_id,
								 @"user_id": currentUbiUser.db_id};
		
		[manager POST:[NSString stringWithFormat:@"%@/drop_event_participant.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([operation.responseString containsString:@"ERROR"]) {
					[self showErrorMessage:operation.responseString];
				}
				else {
					buttonTitle = @"  Partecipa  ";
					[[[UIAlertView alloc] initWithTitle:@"Eventi"
												message:@"Partecipazione all'evento rimossa."
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil] show];
					[_ubi_event.event_participants_ids removeObject:currentUbiUser.db_id];
					[_mainCollectionView reloadItemsAtIndexPaths:[_mainCollectionView indexPathsForVisibleItems]];
					[_mainCollectionView reloadData];
				}
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
		}];
	}
}

- (IBAction)post_event_review:(id)sender
{
	
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

- (void)showNoInternetConnectionMessage {
	[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
								message:@"The internet connection appears to be offline."
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

@end
