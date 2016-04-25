//
//  NewPostViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 24/10/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "NewStatusViewController.h"

@interface NSMutableArray (Resizing)

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

@interface NewStatusViewController ()

@end

@implementation NewStatusViewController

#define BASE_URL @"http://server.ubisocial.it"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    allUsersHaveBeenLoaded = FALSE;
    picFromCamera = FALSE;
    
    _searchPlacesResults = [[NSMutableArray array] init];
    _searchUsersResults = [[NSMutableArray array] init];
    _results = [NSMutableArray array];
    
    selectedFriends = [[NSMutableArray alloc] init];
    selectedSocials = [[NSMutableArray alloc] init];
    selectedPlace = [[FTGooglePlacesAPISearchResultItem alloc] init];
    
    socialsTableViewOpen = FALSE;
    locationsTableViewOpen = FALSE;
    friendsTableViewOpen = FALSE;
    
    currentUbiUser = [[UbiUser alloc] initFromCache];

    _selectedImageView.hidden = YES;
    _searchBar.hidden = YES;
    
    _mainTableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTableView.layer.borderWidth = 1;
	_mainTableView.layer.borderColor = [[UIColor colorWithRed:(30.0/255.0) green:(32.0/255.0) blue:(43.0/255.0) alpha:1.0] CGColor];
    _mainTableView.hidden = YES;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    FTGooglePlacesAPINearbySearchRequest *request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:locationManager.location.coordinate];
    request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
    request.types = @[@"accounting", @"airport", @"amusement_park", @"aquarium", @"art_gallery", @"atm", @"bakery", @"bank", @"bar", @"beauty_salon", @"bicycle_store", @"book_store", @"bowling_alley", @"bus_station", @"cafe", @"campground", @"car_dealer", @"car_rental", @"car_repair", @"car_wash", @"casino", @"cemetery", @"church", @"city_hall", @"clothing_store", @"convenience_store", @"courthouse", @"dentist", @"department_store", @"doctor", @"electrician", @"electronics_store", @"embassy", @"establishment", @"finance", @"fire_station", @"florist", @"food", @"funeral_home", @"furniture_store", @"gas_station", @"general_contractor", @"grocery_or_supermarket", @"gym", @"hair_care", @"hardware_store", @"health", @"hindu_temple", @"home_goods_store", @"hospital", @"insurance_agency", @"jewelry_store", @"laundry", @"lawyer", @"library", @"liquor_store", @"local_government_office", @"locksmith", @"lodging", @"meal_delivery", @"meal_takeaway", @"mosque", @"movie_rental", @"movie_theater", @"moving_company", @"museum", @"night_club", @"painter", @"park", @"parking", @"pet_store", @"pharmacy", @"physiotherapist", @"place_of_worship", @"plumber", @"police", @"post_office", @"real_estate_agency", @"restaurant", @"roofing_contractor", @"rv_park", @"school", @"shoe_store", @"shopping_mall", @"spa", @"stadium", @"storage", @"store", @"subway_station", @"synagogue", @"taxi_stand", @"train_station", @"travel_agency", @"university", @"veterinary_care", @"zoo"];
    
    _initialRequest = request;
    _actualRequest = request;
    
    id_caricati = [[NSMutableArray alloc] initWithCapacity:4];
    dati_utenti_caricati = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
    dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    id_caricati = [defaults objectForKey:@"id_caricati"];
    if ([id_caricati count] < 4) {
        allUsersHaveBeenLoaded = TRUE;
    }
    else {
        id_caricati = [id_caricati resize:4];
    }
    
    [_txtViewPost becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note
{
    _toolBarBottomSpace.constant = 215.0;
    [_toolBar needsUpdateConstraints];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    _toolBarBottomSpace.constant = 0.0;
    [_toolBar needsUpdateConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (socialsTableViewOpen) {
        return 3;
    }
    else if (locationsTableViewOpen) {
        return [_results count] + ([_lastResponse hasNextPage]) + [_searchPlacesResults count];
    }
    else if (friendsTableViewOpen) {
        return [id_caricati count] + (allUsersHaveBeenLoaded ? 0 : 1);
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
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
    
    if (socialsTableViewOpen) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell"];
            NSRange range = [currentUbiUser.profile_url.absoluteString rangeOfString:@"facebook"];
            if (!(range.length != 0))
            {
                [cell.imageView setImage:[self convertImageToGrayScale:cell.imageView.image]];
                cell.userInteractionEnabled = FALSE;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
            NSRange range = [currentUbiUser.profile_url.absoluteString rangeOfString:@"twitter"];
            if (!(range.length != 0))
            {
                [cell.imageView setImage:[self convertImageToGrayScale:cell.imageView.image]];
                cell.userInteractionEnabled = FALSE;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"GPlusCell"];
            NSRange range = [currentUbiUser.profile_url.absoluteString rangeOfString:@"google"];
            if (!(range.length != 0))
            {
                [cell.imageView setImage:[self convertImageToGrayScale:cell.imageView.image]];
                cell.userInteractionEnabled = FALSE;
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
    }
    else if (locationsTableViewOpen) {
        if ([self isLoadMoreResultsCellAtIndexPath:indexPath])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMorePlacesCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMorePlacesCell"];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = @"Load more places...";
            }
        }
        else
        {
            if ( ([_searchPlacesResults count] > 0) && (indexPath.row < _searchPlacesResults.count) ) {
                FTGooglePlacesAPISearchResultItem *resultItem = _searchPlacesResults[indexPath.row];
                cell = [tableView dequeueReusableCellWithIdentifier:resultItem.placeId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:resultItem.placeId];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    cell.textLabel.text = resultItem.name;
                    if (resultItem.location) {
                        CLLocationDistance distance = [resultItem.location distanceFromLocation:locationManager.location];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.0fm", distance];
                    }
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:resultItem.iconImageUrl]
									  placeholderImage:[UIImage imageNamed:@""]];
                }
				
				if ( selectedPlace == resultItem ) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
            }
            else {
                FTGooglePlacesAPISearchResultItem *resultItem = _results[indexPath.row - _searchPlacesResults.count];
                cell = [tableView dequeueReusableCellWithIdentifier:resultItem.placeId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:resultItem.placeId];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    cell.textLabel.text = resultItem.name;
                    if (resultItem.location) {
                        CLLocationDistance distance = [resultItem.location distanceFromLocation:locationManager.location];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.0fm", distance];
                    }
                    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:resultItem.iconImageUrl]
									  placeholderImage:[UIImage imageNamed:@""]];
                }
				
				if ( selectedPlace == resultItem ) {
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
            }
        }
    }
    else if (friendsTableViewOpen) {
        if ([self isLoadMoreUsersCellAtIndexPath:indexPath])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreUsersCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreUsersCell"];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = @"Load more users...";
            }
        }
        else {
            UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:indexPath.row]];
            
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
                
                if ([selectedFriends containsObject:newUbiUser]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (socialsTableViewOpen) {
        if ([selectedSocials containsObject:selectedCell.textLabel.text])
        {
            [selectedSocials removeObject:selectedCell.textLabel.text];
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            [selectedSocials addObject:selectedCell.textLabel.text];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (locationsTableViewOpen) {
        if ([self isLoadMoreResultsCellAtIndexPath:indexPath])
        {
            id<FTGooglePlacesAPIRequest> nextPageRequest = [_lastResponse nextPageRequest];
            _actualRequest = nextPageRequest;
            [self startSearching];
        }
        else
        {
            FTGooglePlacesAPISearchResultItem * resultItem;
            if ( ([_searchPlacesResults count] > 0) && (indexPath.row < _searchPlacesResults.count) ) {
                resultItem = _searchPlacesResults[indexPath.row];
            }
            else {
                resultItem = _results[indexPath.row - _searchPlacesResults.count];
            }
            if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
                selectedCell.accessoryType = UITableViewCellAccessoryNone;
                selectedPlace = [[FTGooglePlacesAPISearchResultItem alloc] init];
            }
            else {
                for (UITableViewCell * myCell in _mainTableView.visibleCells) {
                    myCell.accessoryType = UITableViewCellAccessoryNone;
                }
                selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                selectedPlace = resultItem;
            }
        }
    }
    else if (friendsTableViewOpen) {
        if ([self isLoadMoreUsersCellAtIndexPath:indexPath])
        {
            allUsersHaveBeenLoaded = TRUE;
            
            id_caricati = [[NSMutableArray alloc] init];
            dati_utenti_caricati = [[NSMutableDictionary alloc] init];
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
            dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            id_caricati = [defaults objectForKey:@"id_caricati"];
            
            [_mainTableView reloadData];
        }
        else {
            UbiUser * newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:indexPath.row]];
            
            if ([selectedFriends containsObject:newUbiUser]) {
                [selectedFriends removeObject:newUbiUser];
                selectedCell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                if ([selectedFriends count] < 16) {
                    [selectedFriends addObject:newUbiUser];
                    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:@"Too Many Friends"
                                                message:@"You can tag up to 15 friends in your post."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }
        }
    }
}

#pragma mark - Helper methods
- (BOOL)isLoadMoreResultsCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRows = [self tableView:_mainTableView numberOfRowsInSection:indexPath.section];
    return ((indexPath.row == numberOfRows - 1) && [_lastResponse hasNextPage]);
}

- (BOOL)isLoadMoreUsersCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (allUsersHaveBeenLoaded) {
        return FALSE;
    }
    
    if ([id_caricati count] > 0) {
        if (indexPath.row == [id_caricati count]) {
            return TRUE;
        }
    }
    
    return FALSE;
}

#pragma mark - FTGooglePlacesAPI performing search request
- (void)startSearching
{
    [FTGooglePlacesAPIService executeSearchRequest:_actualRequest
                             withCompletionHandler:^(FTGooglePlacesAPISearchResponse *response, NSError *error)
     {
         if (error)
         {
             NSRange range = [[error localizedDescription] rangeOfString:@"The operation couldn’t be completed. (Cocoa error 3840.)"];
             if (range.length != 0)
             {
                 [[[UIAlertView alloc] initWithTitle:@"Places Nearby"
                                             message:@"Please use the search bar to find the place you are looking for."
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
             else {
                 [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                             message:[error localizedFailureReason]
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
         _lastResponse = response;
         [_results addObjectsFromArray:response.results];
         [_mainTableView reloadData];
     }];
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hideTableView];
    
	if ([textView.text isEqualToString:@"Condividi qualcosa..."]) {
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
	[textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:@""]) {
		textView.text = @"Condividi qualcosa...";
		textView.textColor = [UIColor lightGrayColor];
	}
	[textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
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
                 [_mainTableView reloadData];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             });
             return;
         }
         
         _searchPlacesResults = [[NSMutableArray alloc] initWithArray:response.results];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [_mainTableView reloadData];
         });
     }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchPlacesResults = [[NSMutableArray alloc] init];
    [_mainTableView reloadData];
    
    [searchBar setText:@""];
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
        [_mainTableView reloadData];
    }
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (locationsTableViewOpen) {
        [searchBar resignFirstResponder];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        _searchPlacesResults = [[NSMutableArray alloc] init];
        
        NSString * searchQuery = [searchBar text];
        
        FTGooglePlacesAPINearbySearchRequest *request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:locationManager.location.coordinate];
        request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
        request.radius = 1000;
        request.keyword = searchQuery;
        request.types = @[@"accounting", @"airport", @"amusement_park", @"aquarium", @"art_gallery", @"atm", @"bakery", @"bank", @"bar", @"beauty_salon", @"bicycle_store", @"book_store", @"bowling_alley", @"bus_station", @"cafe", @"campground", @"car_dealer", @"car_rental", @"car_repair", @"car_wash", @"casino", @"cemetery", @"church", @"city_hall", @"clothing_store", @"convenience_store", @"courthouse", @"dentist", @"department_store", @"doctor", @"electrician", @"electronics_store", @"embassy", @"establishment", @"finance", @"fire_station", @"florist", @"food", @"funeral_home", @"furniture_store", @"gas_station", @"general_contractor", @"grocery_or_supermarket", @"gym", @"hair_care", @"hardware_store", @"health", @"hindu_temple", @"home_goods_store", @"hospital", @"insurance_agency", @"jewelry_store", @"laundry", @"lawyer", @"library", @"liquor_store", @"local_government_office", @"locksmith", @"lodging", @"meal_delivery", @"meal_takeaway", @"mosque", @"movie_rental", @"movie_theater", @"moving_company", @"museum", @"night_club", @"painter", @"park", @"parking", @"pet_store", @"pharmacy", @"physiotherapist", @"place_of_worship", @"plumber", @"police", @"post_office", @"real_estate_agency", @"restaurant", @"roofing_contractor", @"rv_park", @"school", @"shoe_store", @"shopping_mall", @"spa", @"stadium", @"storage", @"store", @"subway_station", @"synagogue", @"taxi_stand", @"train_station", @"travel_agency", @"university", @"veterinary_care", @"zoo"];
        
        [self startSearchingPlaces:request];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Ricerca amici"
                                    message:@"La ricerca nella lobby non è ancora stata abilitata."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - imagePickerController methods
- (IBAction)addPicture:(id)sender
{
    [self hideTableView];
    
    [[[UIActionSheet alloc] initWithTitle:@"Select from:"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
		picker.delegate = self;
		picker.allowsEditing = YES;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		
        picFromCamera = FALSE;
        
		[self presentViewController:picker animated:YES completion:NULL];
	}
	else if (buttonIndex == 1)
	{
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Device has no camera."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
		}
		else
		{
            picFromCamera = TRUE;
            
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
			picker.delegate = self;
			picker.allowsEditing = YES;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			
			[self presentViewController:picker animated:YES completion:NULL];
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *chosenImage = [info[UIImagePickerControllerEditedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    _txtViewLeftConstraint.constant = _selectedImageView.frame.size.width - 5;
    [_txtViewPost updateConstraints];
    
    [_selectedImageView setHidden:NO];
	[_selectedImageView setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - IBActions
- (IBAction)sharePressed:(id)sender
{
    if (_mainTableView.hidden == YES || !socialsTableViewOpen) {
        socialsTableViewOpen = TRUE;
        locationsTableViewOpen = FALSE;
        friendsTableViewOpen = FALSE;
        
        [self showTableView:NO];
    } else {
        if (socialsTableViewOpen) {
            [self hideTableView];
        }
    }
}

- (IBAction)locationPressed:(id)sender
{
    if (_mainTableView.hidden == YES || !locationsTableViewOpen) {
        socialsTableViewOpen = FALSE;
        locationsTableViewOpen = TRUE;
        friendsTableViewOpen = FALSE;
        
        if ([_results count] == 0) {
            [self startSearching];
        }
        
        [self showTableView:YES];
    } else {
        if (locationsTableViewOpen) {
            [self hideTableView];
        }
    }
}

- (IBAction)tagPressed:(id)sender
{
    if (_mainTableView.hidden == YES || !friendsTableViewOpen) {
        socialsTableViewOpen = FALSE;
        locationsTableViewOpen = FALSE;
        friendsTableViewOpen = TRUE;
        
        [self showTableView:YES];
    } else {
        if (friendsTableViewOpen) {
            [self hideTableView];
        }
    }
}

- (void)showTableView:(BOOL)scrolling
{
    _txtViewBottomConstraint.constant = _mainTableView.frame.size.height + (scrolling ? (7 + _searchBar.frame.size.height) : 7);
    [_txtViewPost updateConstraints];
    [_txtViewPost resignFirstResponder];
    [_searchBar resignFirstResponder];
	
    _searchBar.hidden = !scrolling;
    
    _mainTableView.scrollEnabled = scrolling;
    _mainTableView.showsVerticalScrollIndicator = scrolling;
    _mainTableView.hidden = NO;
    
    [_mainTableView reloadData];
}

- (void)hideTableView
{
    socialsTableViewOpen = FALSE;
    locationsTableViewOpen = FALSE;
    friendsTableViewOpen = FALSE;
    
    _mainTableView.hidden = YES;
    _searchBar.hidden = YES;
    _txtViewBottomConstraint.constant = 8;
    [_txtViewPost updateConstraints];
}

- (IBAction)closeNewPost:(id)sender
{
    [_txtViewPost resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendNewPost:(id)sender
{
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
        if ( (selectedFriends.count == 0) && (selectedPlace.name.length < 1) && ([_txtViewPost.text isEqualToString:@"Condividi qualcosa..."] || _txtViewPost.text.length < 1) && (!_selectedImageView.image) ) {
            [[[UIAlertView alloc] initWithTitle:@"Errore"
                                        message:@"Non puoi inviare un post vuoto"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        
        NSDateFormatter *formatter;
        NSString * fileName;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        fileName = [formatter stringFromDate:[NSDate date]];
        fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
        fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@""];
        fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
        fileName = [NSString stringWithFormat:@"%@.png", fileName];
        
        NSMutableArray *tagged_users = [[NSMutableArray alloc] init];
        for (UbiUser * newUbiUSer in selectedFriends) {
			[tagged_users addObject:newUbiUSer.db_id];
        }
		NSString * tagged_ids;
        if ([tagged_users count] > 0) {
			tagged_ids = [tagged_users componentsJoinedByString:@" "];
        }
        else {
            tagged_ids = @"NO_TAGS";
        }
		
		NSString * place_name = @"NO_LOC";
		if (selectedPlace.name.length > 0) {
			place_name = selectedPlace.name;
		}
		
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSData *imageData;
        if (_selectedImageView.image) {
            imageData = UIImageJPEGRepresentation(_selectedImageView.image, 0.5);
        }
        
        NSString * postContent = [[NSString alloc] init];
        if ([_txtViewPost.text isEqualToString:@"Condividi qualcosa..."]) {
            postContent = @"";
        }
        else {
            postContent = _txtViewPost.text;
        }
        
        NSString * mediaURL = [NSString stringWithFormat:@"%@/uploads/statuses/%@/%@", BASE_URL, currentUbiUser.db_id, fileName];
        if (!_selectedImageView.image) {
            mediaURL = @"NO_MEDIA";
        }
		
		NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
		NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
		float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
		NSNumber * timeZoneInMins = [NSNumber numberWithFloat:(float)(timeZoneOffset*60)];
		
		NSDictionary *params = @{@"place_google_id": ([place_name isEqualToString:@"NO_LOC"] ? place_name : selectedPlace.placeId),
								 
								 @"status_author_id": currentUbiUser.db_id,
								 @"status_content_text": postContent,
								 @"status_content_media": mediaURL,
								 
								 @"status_date_utc_offset": timeZoneInMins,
								 
								 @"tagged_people": tagged_ids};
		
        [[manager POST:@"/php/1.1/post_new_status.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
		{
			if (_selectedImageView.image) {
				[formData appendPartWithFileData:imageData name:@"uploadedfile" fileName:fileName mimeType:@"image/jpeg"];
			}
          } success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSRange range = [operation.responseString rangeOfString:@"ERROR"];
              if (range.length == 0)
              {
                  if (_selectedImageView.image) {
                      if (picFromCamera) {
                          UIImageWriteToSavedPhotosAlbum(_selectedImageView.image,
                                                 nil,
                                                 nil,
                                                 nil);
                      }
                  }

				  [currentUbiUser saveCurrentUserToCache];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserStatusData" object:postContent];
                  [self dismissViewControllerAnimated:YES completion:nil];
              }
			  else {
				  [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
											  message:@"Please retry."
											 delegate:self
									cancelButtonTitle:@"OK"
									otherButtonTitles:nil] show];
			  }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [[[UIAlertView alloc] initWithTitle:@"Errore"
                                          message:[NSString stringWithFormat:@"Si è verificato un errore durante il caricamento del media allegato al post. %@", error.description]
                                         delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil] show];
          }] start];
    }
}

#pragma mark - helper methods
- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    UIImage *newImage;
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    newImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

@end
