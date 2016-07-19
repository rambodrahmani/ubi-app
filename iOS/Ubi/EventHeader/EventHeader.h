//
//  EventHeader.h
//  Ubi
//
//  Created by Rambod Rahmani on 02/02/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView * imgViewCover;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewIcon;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewRating;
@property (weak, nonatomic) IBOutlet UILabel * lblNome;
@property (weak, nonatomic) IBOutlet UILabel * lbl_event_description;
@property (weak, nonatomic) IBOutlet UILabel * lbl_event_date;
@property (weak, nonatomic) IBOutlet UIButton * btnPartecipa;

@end
