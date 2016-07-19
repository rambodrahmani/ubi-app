//
//  UserDetailViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 24/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import "UbiStatus.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TimelineCell.h"
#import "UserDetailsHeader.h"
#import "UIImageView+WebCache.h"
#import <Accelerate/Accelerate.h>
#import "NewStatusViewController.h"
#import "ImageviewViewController.h"
#import "StatusDetailsViewController.h"

@interface UserDetailsViewController : UIViewController <CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
	NSMutableArray * statusCaricati;
    
    UbiUser * currentUbiUser;
	
	CLLocationManager * locationManager;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, retain) UbiUser * selectedUbiUser;

@end
