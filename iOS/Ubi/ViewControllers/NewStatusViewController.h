//
//  NewPostViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 24/10/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import <MapKit/MapKit.h>
#import "FTGooglePlacesAPI.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager.h"

@interface NewStatusViewController : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UbiUser * currentUbiUser;
    
    CLLocationManager * locationManager;
    
    NSMutableArray * selectedSocials;
    NSMutableArray * selectedFriends;
    FTGooglePlacesAPISearchResultItem * selectedPlace;
    
    BOOL socialsTableViewOpen;
    BOOL locationsTableViewOpen;
    BOOL friendsTableViewOpen;
    
    BOOL allUsersHaveBeenLoaded;
	NSMutableArray * id_caricati;
	NSMutableDictionary * dati_utenti_caricati;
	
    BOOL picFromCamera;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mediaBarButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *txtViewPost;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomSpace;

@property (nonatomic, strong) id<FTGooglePlacesAPIRequest> initialRequest;
@property (nonatomic, strong) id<FTGooglePlacesAPIRequest> actualRequest;
@property (nonatomic, strong) FTGooglePlacesAPISearchResponse *lastResponse;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray * searchPlacesResults;

@property (nonatomic, strong) NSMutableArray * searchUsersResults;

- (IBAction)closeNewPost:(id)sender;
- (IBAction)sendNewPost:(id)sender;
- (IBAction)addPicture:(id)sender;
- (IBAction)sharePressed:(id)sender;
- (IBAction)locationPressed:(id)sender;
- (IBAction)tagPressed:(id)sender;

@end
