//
//  ReviewsHeader.h
//  Ubi
//
//  Created by Rambod Rahmani on 29/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewsHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView * imgViewCover;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewIcon;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewRating;
@property (weak, nonatomic) IBOutlet UILabel * lblNome;
@property (weak, nonatomic) IBOutlet UILabel * lbl_place_string;
@property (weak, nonatomic) IBOutlet UITableView * detailsTableView;
@property (weak, nonatomic) IBOutlet UIButton * btnVediSullaMappa;
@property (weak, nonatomic) IBOutlet UIButton * btnVediFoto;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;

@end
