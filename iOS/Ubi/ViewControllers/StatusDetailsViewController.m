//
//  StatusDetailsViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 12/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "StatusDetailsViewController.h"

@interface StatusDetailsViewController ()

@end

@implementation StatusDetailsViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_btnPost.layer.borderWidth = 1;
	_btnPost.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnPost.layer.cornerRadius = 10;
	
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.title = _selectedUser.name;
    
    [_commentsCollView setContentInset:UIEdgeInsetsMake(8, 0, 8, 0)];
    
    [_commentsCollView reloadData];
    [self loadComments];
    
    currentUbiUser = [[UbiUser alloc] initFromCache];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadComments {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"status_id": _selectedStatus.db_id};
    
    [manager POST:[NSString stringWithFormat:@"%@/read_status_comments.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dati_utenti_caricati = [[NSMutableDictionary alloc] init];
		commentiCaricati = [[NSMutableArray alloc] init];
		
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
				
				UbiStatusComment * newComment = [[UbiStatusComment alloc] initWithParametersCommentID:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"comment_id"] description] intValue]]
																							status_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"status_id"] description] intValue]]
																							  user_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_id"] description] intValue]]
																				 comment_content_text:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"comment_content_text"] description]]
																						 comment_date:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"comment_date"] description]]];
				[commentiCaricati addObject:newComment];
			}
		}
		else
		{
			[self showErrorMessage:error.description];
		}
		
        dispatch_async(dispatch_get_main_queue(), ^{
            [_commentsCollView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[_commentsCollView reloadData];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (dati_utenti_caricati > 0 ? 1 + [_selectedStatus.comments_num intValue] : 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TimelineCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimelineCell" forIndexPath:indexPath];

        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[cell initProfileImgView:indexPath :_selectedUser.profile_pic];
		
        UITapGestureRecognizer *singleTapProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedSD:)];
        singleTapProfilePic.numberOfTapsRequired = 1;
        [cell.imgViewProfilo setUserInteractionEnabled:YES];
        [cell.imgViewProfilo addGestureRecognizer:singleTapProfilePic];
        
        cell.lblNome.text = [NSString stringWithFormat:@"%@ %@", _selectedUser.name, _selectedUser.surname];
        cell.lblNome.tag = indexPath.row;
        
        UITapGestureRecognizer *singleTapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedSD:)];
        singleTapName.numberOfTapsRequired = 1;
        [cell.lblNome setUserInteractionEnabled:YES];
        [cell.lblNome addGestureRecognizer:singleTapName];
        
        [cell initLblData:_selectedStatus.status_date];
        
        [cell initLblTags:_selectedStatus.tags];
        
		if (![cell.lblTags.text isEqualToString:@"NO_TAGS"]) {
			UITapGestureRecognizer *singleTaplblTags = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblTagsTapDetected:)];
			singleTaplblTags.numberOfTapsRequired = 1;
			[cell.lblTags setUserInteractionEnabled:YES];
			[cell.lblTags addGestureRecognizer:singleTaplblTags];
		}
		
        [cell initLblLoc:_selectedStatus.status_place];
		
		if ([cell.lblWith.text isEqualToString:@"at"]) {
			UITapGestureRecognizer *singleTaplblLoc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblLocTapDetected:)];
			singleTaplblLoc.numberOfTapsRequired = 1;
			[cell.lblTags setUserInteractionEnabled:YES];
			[cell.lblTags addGestureRecognizer:singleTaplblLoc];
		}
		else {
			UITapGestureRecognizer *singleTaplblLoc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblLocTapDetected:)];
			singleTaplblLoc.numberOfTapsRequired = 1;
			[cell.lblLoc setUserInteractionEnabled:YES];
			[cell.lblLoc addGestureRecognizer:singleTaplblLoc];
		}
		
		[cell.txtViewPost setText:nil];
        [cell initTxtViewPost:_selectedStatus.content_text];
        
        [cell initImgViewMedia:_selectedStatus.content_media];
		
		UITapGestureRecognizer *singleTapImgViewMedia = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewTapDetected:)];
		singleTapImgViewMedia.numberOfTapsRequired = 1;
		[cell.imgViewMedia setUserInteractionEnabled:YES];
		[cell.imgViewMedia addGestureRecognizer:singleTapImgViewMedia];
		
        [cell initLblLikesComm:[NSNumber numberWithUnsignedInteger:_selectedStatus.likes_array.count] :_selectedStatus.comments_num :indexPath];
        
        UITapGestureRecognizer *singleTaplblLikesComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesCommTapDetectedSD:)];
        singleTaplblLikesComm.numberOfTapsRequired = 1;
        [cell.lblLikesComm setUserInteractionEnabled:YES];
        [cell.lblLikesComm addGestureRecognizer:singleTaplblLikesComm];
        
		if ( [_selectedStatus.likes_array containsObject:currentUbiUser.db_id] ) {
			[cell.btnLike setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		} else {
			[cell.btnLike setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
		}
		cell.btnLike.layer.borderWidth = 1;
		cell.btnLike.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		cell.btnLike.layer.cornerRadius = 10;
		
		cell.btnLike.tag = indexPath.row;
		[cell.btnLike addTarget:self action:@selector(btnLikeTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		cell.btnInfo.tag = indexPath.row;
		[cell.btnInfo addTarget:self action:@selector(btnInfoTapped:) forControlEvents:UIControlEventTouchUpInside];
		
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        return cell;
    }
    else {
        CommentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CommentCell" forIndexPath:indexPath];
		UbiStatusComment * newComment = [commentiCaricati objectAtIndex:indexPath.row - 1];
        UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:newComment.user_id];
		 
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        cell.lblNome.text = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
        cell.lblNome.tag = indexPath.row-1;
        
        UITapGestureRecognizer *singleTapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedComm:)];
        singleTapName.numberOfTapsRequired = 1;
        [cell.lblNome setUserInteractionEnabled:YES];
        [cell.lblNome addGestureRecognizer:singleTapName];
		
		NSArray * splitter = [[newComment valueForKey:@"comment_date"] componentsSeparatedByString:@"-"];
		int monthNumber = [[splitter objectAtIndex:1] intValue];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		NSString *monthName = [[df monthSymbols] objectAtIndex:(monthNumber-1)];
		NSString *shortMonthName = [monthName substringToIndex:3];
		cell.lblData.text = [NSString stringWithFormat:@"%d %@ %d", [[splitter objectAtIndex:2] intValue], shortMonthName, [[splitter objectAtIndex:0] intValue]];
		
		[cell.txtViewComment setText:nil];
        cell.txtViewComment.text = [newComment valueForKey:@"comment_content_text"];
		cell.txtViewComment.tag = indexPath.row-1;
		UITapGestureRecognizer *singleTapCommCell = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commCellTapDetected:)];
		singleTapCommCell.numberOfTapsRequired = 1;
		[cell.txtViewComment setUserInteractionEnabled:YES];
		[cell.txtViewComment addGestureRecognizer:singleTapCommCell];
		//[cell.txtViewComment scrollRangeToVisible:NSMakeRange(0, 0)];
		
		[cell initProfileImgView:indexPath :newUbiUser.profile_pic];
		
        UITapGestureRecognizer *singleTapProfilePicComm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetectedComm:)];
        singleTapProfilePicComm.numberOfTapsRequired = 1;
        [cell.imgViewProfilo setUserInteractionEnabled:YES];
        [cell.imgViewProfilo addGestureRecognizer:singleTapProfilePicComm];
		
		if (indexPath.row == [_selectedStatus.comments_num intValue]) {
			cell.separatorView.hidden = YES;
		} else {
			cell.separatorView.hidden = NO;
		}
		
        return cell;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize newCellSize = _commentsCollView.frame.size;
    newCellSize.width -= 16;
	
    if (indexPath.row == 0) {
        int finalHeight = 410;
        if ( !([_selectedStatus.content_text length] > 0) ) {
            finalHeight -= 70;
        }
        if ( !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) )
        {
            if ([_selectedStatus.content_text length] > 0 && [_selectedStatus.content_text length] < 21) { finalHeight -= 34; }
            else if ([_selectedStatus.content_text length] > 21 && [_selectedStatus.content_text length] < 43) { finalHeight -= 20; }
        }
        if ([_selectedStatus.content_media.absoluteString isEqualToString:@"NO_MEDIA"]) {
            finalHeight -= 185;
        }
		
        newCellSize.height = finalHeight;
        return newCellSize;
    }
    else {
        newCellSize.height = 110;
    }
	
    return newCellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedStatus.comments_num > 0) {
        if (indexPath.row > 0) {
			UbiStatusComment * newComment = [commentiCaricati objectAtIndex:indexPath.row-1];
			if ([newComment.user_id isEqualToNumber:currentUbiUser.db_id])
			{
				UIActionSheet * commentAS = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Comment: %@", newComment.comment_content_text]
																		delegate:self
															   cancelButtonTitle:@"Cancel"
														  destructiveButtonTitle:nil
															   otherButtonTitles:@"Delete Comment", nil];
				commentAS.tag = indexPath.row - 1;
				[commentAS showInView:self.view];
			}
        }
    }
}

- (void)commCellTapDetected:(UIGestureRecognizer *)sender
{
	UbiStatusComment * newComment = [commentiCaricati objectAtIndex:(long)sender.view.tag];
	if ([newComment.user_id isEqualToNumber:currentUbiUser.db_id])
	{
		UIActionSheet * commentAS = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Comment: %@", newComment.comment_content_text]
																delegate:self
													   cancelButtonTitle:@"Cancel"
												  destructiveButtonTitle:nil
													   otherButtonTitles:@"Delete Comment", nil];
		commentAS.tag = (long)sender.view.tag;
		[commentAS showInView:self.view];
	}
}

- (void)btnInfoTapped:(UIButton *)sender
{
	NSMutableArray * tag_ids = [[NSMutableArray alloc] init];
	for (NSDictionary * tag in _selectedStatus.tags) {
		[tag_ids addObject:[NSNumber numberWithInt:[[tag valueForKey:@"user_id"] intValue]]];
	}
	
	UIActionSheet * statusAS = [[UIActionSheet alloc] initWithTitle:@"Status:"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
											 destructiveButtonTitle:nil
												  otherButtonTitles:nil];
	
	if ([_selectedStatus.author_id isEqualToNumber:currentUbiUser.db_id]) {
		[statusAS addButtonWithTitle:@"Delete Status"];
	}
	if ([tag_ids containsObject:currentUbiUser.db_id]) {
		[statusAS addButtonWithTitle:@"Remove Tag"];
	}
	
	statusAS.tag = (long)sender.tag;
	[statusAS showInView:self.view];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	UbiStatusComment * newComment = [[UbiStatusComment alloc] init];
	if ( (commentiCaricati.count > 0) && ((int)actionSheet.tag < commentiCaricati.count) ) {
		newComment = [commentiCaricati objectAtIndex:(int)actionSheet.tag];
	}
	
	if ([actionSheet.title isEqualToString:[NSString stringWithFormat:@"Comment: %@", newComment.comment_content_text]]) {
		if (buttonIndex == 0) {
			[newComment dropComment];
			
			[commentiCaricati removeObject:newComment];
			_selectedStatus.comments_num = [NSNumber numberWithInt:[_selectedStatus.comments_num intValue] - 1];
			[_commentsCollView reloadData];
			[_commentTextField resignFirstResponder];
		}
	}
	else if ([actionSheet.title isEqualToString:@"Status:"]) {
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Status"]) {
			[_selectedStatus dropStatus];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
		else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove Tag"]) {
			UbiStatusTag * selected_tag = [[UbiStatusTag alloc] init];
			for (UbiStatusTag * tag in _selectedStatus.tags) {
				if ( [tag.user_id intValue] == [currentUbiUser.db_id intValue] ) {
					selected_tag = tag;
					break;
				}
			}
			//[selected_tag dropTag];
			
			NSMutableArray* new_tags_array = [[NSMutableArray alloc] initWithArray:_selectedStatus.tags];
			[new_tags_array removeObject:selected_tag];
			_selectedStatus.tags = [[NSArray alloc] initWithArray:new_tags_array];
			[_commentsCollView reloadData];
		}
	}
}

- (void)btnLikeTapped:(UIButton *)sender
{
	UbiStatusLike * status_like = [[UbiStatusLike alloc] initWithParametersStatusID:_selectedStatus.db_id
																			user_id:currentUbiUser.db_id];
	
	if ([_selectedStatus.likes_array containsObject:currentUbiUser.db_id]) {
		[status_like dropLike];
		
		NSMutableArray* newLikesArray = [[NSMutableArray alloc] initWithArray:_selectedStatus.likes_array];
		[newLikesArray removeObject:currentUbiUser.db_id];
		_selectedStatus.likes_array = [[NSArray alloc] initWithArray:newLikesArray];
		[_commentsCollView reloadData];
	}
	else {
		[status_like postLike];
		
		NSMutableArray* newLikesArray = [[NSMutableArray alloc] initWithArray:_selectedStatus.likes_array];
		[newLikesArray addObject:currentUbiUser.db_id];
		_selectedStatus.likes_array = [[NSArray alloc] initWithArray:newLikesArray];
		[_commentsCollView reloadData];
	}
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPeopleView"]) {
        PeopleViewController * destinationViewController = (PeopleViewController *)segue.destinationViewController;
        destinationViewController.peopleEmails = (NSArray *)sender;
    }
    else if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
        UbiUser *selectedUbiUser = (UbiUser *)sender;
        UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedUbiUser = selectedUbiUser;
    }
    else if ([segue.identifier isEqualToString:@"ShowPlaceDetailsView"]) {
        UbiPlace *newUbiPlace = (UbiPlace *)sender;
        PlaceDetailsViewController *destinationViewController = (PlaceDetailsViewController *)segue.destinationViewController;
        destinationViewController.selectedAddress = newUbiPlace;
    }
	else if ([segue.identifier isEqualToString:@"ShowImageviewView"]) {
		UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
		ImageviewViewController *destinationViewController = (ImageviewViewController *)destinationNavController.viewControllers[0];
		destinationViewController.selectedImageURL = _selectedStatus.content_media;
	}
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note
{
    _collViewBottomConstraint.constant = 167;
    
    [UIView animateWithDuration:0.3 animations:^{
        _txtFieldBgView.transform = CGAffineTransformMakeTranslation(0, -167);
        _commentsCollView.frame = CGRectMake(_commentsCollView.frame.origin.x,
                                             _commentsCollView.frame.origin.y,
                                             _commentsCollView.frame.size.width,
                                             _commentsCollView.frame.size.height - 167);
    } completion:^(BOOL finished) {
		[self scrollToLastItemAnimated:YES];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    _collViewBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        _txtFieldBgView.transform = CGAffineTransformIdentity;
        _commentsCollView.frame = CGRectMake(_commentsCollView.frame.origin.x,
                                             _commentsCollView.frame.origin.y,
                                             _commentsCollView.frame.size.width,
                                             _commentsCollView.frame.size.height + 167);
    } completion:^(BOOL finished) {
		[self scrollToLastItemAnimated:YES];
    }];
}

- (void)scrollToLastItemAnimated:(BOOL)animated;
{
	if (commentiCaricati.count == 0) { return; }
	
	NSIndexPath *path = [NSIndexPath indexPathForItem:commentiCaricati.count
											inSection:0];
	
	[_commentsCollView scrollToItemAtIndexPath:path
								atScrollPosition:UICollectionViewScrollPositionCenteredVertically
										animated:animated];
}

- (void)lblLocTapDetected:(UIGestureRecognizer *)sender
{
	UbiPlace * newUbiPlace = _selectedStatus.status_place;
    [self performSegueWithIdentifier:@"ShowPlaceDetailsView" sender:newUbiPlace];
}

- (void)lblTagsTapDetected:(UIGestureRecognizer *)sender
{
	NSMutableArray * tagged_people_ids = [[NSMutableArray alloc] init];
	for (UbiStatusTag * tag in _selectedStatus.tags) {
		[tagged_people_ids addObject:tag.user_id];
	}
	if (tagged_people_ids.count > 0) {
		[self performSegueWithIdentifier:@"ShowPeopleView" sender:tagged_people_ids];
	}
}

- (void)profileTapDetectedSD:(UIGestureRecognizer *)sender
{
    [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:_selectedUser];
}

- (void)imgViewTapDetected:(UIGestureRecognizer *)sender
{
	[self performSegueWithIdentifier:@"ShowImageviewView" sender:_selectedUser];
}

- (void)profileTapDetectedComm:(UIGestureRecognizer *)sender
{
	UbiStatusComment * newComment = [commentiCaricati objectAtIndex:(long)sender.view.tag];
	UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:newComment.user_id];
    [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:newUbiUser];
}

- (void)likesCommTapDetectedSD:(UIGestureRecognizer *)sender
{
    if (_selectedStatus.likes_array.count > 0) {
        [self performSegueWithIdentifier:@"ShowPeopleView" sender:_selectedStatus.likes_array];
    }
}

- (IBAction)postComment:(id)sender {
    if (_commentTextField.text.length > 0) {
		UbiStatusComment * newComment = [[UbiStatusComment alloc] postNewCommentWithUser_id:currentUbiUser.db_id
																				  status_id:_selectedStatus.db_id
																			   comment_text:_commentTextField.text];
		if (newComment) {
			[commentiCaricati addObject:newComment];
			
			[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
			_selectedStatus.comments_num = [NSNumber numberWithInt:[_selectedStatus.comments_num intValue] + 1];
			[_commentsCollView reloadData];
			[_commentTextField setText:@""];
			[_commentTextField resignFirstResponder];
		}
    }
    else {
		[self showErrorMessage:@"no text for comment"];
    }
}

#pragma mark - Helper methods
- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
