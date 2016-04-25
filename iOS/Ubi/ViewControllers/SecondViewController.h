//
//  SecondViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 06/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import "UbiStatus.h"
#import <UIKit/UIKit.h>
#import "TimelineCell.h"
#import "Reachability.h"
#import "UIImageView+WebCache.h"
#import "UserDetailsViewController.h"
#import "StatusDetailsViewController.h"
#import "UbiStatusLike.h"
#import "UbiStatusTag.h"

@interface SecondViewController : UIViewController <CLLocationManagerDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate>
{
	NSMutableArray * id_caricati;
	NSMutableDictionary * dati_utenti_caricati;
    
	NSMutableArray * statusCaricati;
    
    UbiUser * currentUbiUser;
	
	CLLocationManager * locationManager;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)createNewPost:(id)sender;

@end

