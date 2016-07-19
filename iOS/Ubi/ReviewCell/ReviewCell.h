//
//  ReviewCell.h
//  Ubi
//
//  Created by Rambod Rahmani on 29/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface ReviewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView * imgViewProfilo;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewRating;
@property (weak, nonatomic) IBOutlet UILabel * lblNome;
@property (weak, nonatomic) IBOutlet UILabel * lblData;
@property (weak, nonatomic) IBOutlet UITextView * txtViewReview;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

- (void)initProfileImgView:(NSIndexPath *)indexPath :(NSURL *)imageURL;

@end
