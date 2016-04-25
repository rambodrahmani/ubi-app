//
//  PlaceDetailViewController.h
//  GooglePlacesApi
//
//  Created by Rambod Rahmani on 18/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ReviewCell.h"
#import <UIKit/UIKit.h>
#import "ReviewsHeader.h"
#import "FTGooglePlacesAPI.h"
#import "FirstViewController.h"
#import "UIImageView+WebCache.h"
#import "UbiPlaceReview.h"
#import "UbiPlace.h"
#import "ImagesGalleryViewController.h"

@interface PlaceDetailsViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
	UbiUser * currentUbiUser;
	
	NSMutableDictionary * dati_utenti_caricati;
	NSMutableArray * loaded_reviews;
	
	NSMutableArray * loaded_place_pictures;
	
	NSInteger reviewRating;
	
	UIImage * coverImage;
	
	CLLocationManager * locationManager;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *reviewTextField;
@property (weak, nonatomic) IBOutlet UIView *txtFieldBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;

@property (weak, nonatomic) IBOutlet UIView *ratings_view;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_start_1;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_start_2;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_start_3;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_start_4;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_start_5;

@property (nonatomic, strong) NSDictionary *responseTableRepresentation;

@property (nonatomic, strong) UbiPlace * selectedAddress;

- (IBAction)post_place_review:(id)sender;

@end
