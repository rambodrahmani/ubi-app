//
//  ImagesGalleryViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 05/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UbiPlace.h"
#import "ImageviewViewController.h"
#import "GalleryPhotoCell.h"

@interface ImagesGalleryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
	NSMutableArray * fotoCaricate;
}

@property (nonatomic, strong) UbiPlace * selectedUbiPlace;
@property (weak, nonatomic) IBOutlet UICollectionView * collectionView;

@end
