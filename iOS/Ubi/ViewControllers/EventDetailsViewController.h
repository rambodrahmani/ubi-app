//
//  EventDetailsViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 29/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UbiEvent.h"
#import "UbiUser.h"
#import "EventHeader.h"
#import "ImageviewViewController.h"
#import <Accelerate/Accelerate.h>
#import "AFNetworking.h"

@interface EventDetailsViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
	UbiUser * currentUbiUser;
	
	NSMutableDictionary * dati_utenti_caricati;
	NSMutableArray * loaded_reviews;
	
	NSInteger reviewRating;
	
	UIImage * coverImage;
	
	NSString * buttonTitle;
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

@property (nonatomic, strong) UbiEvent * ubi_event;

- (IBAction)post_event_review:(id)sender;

@end
