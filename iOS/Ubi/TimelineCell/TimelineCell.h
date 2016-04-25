//
//  timelineCell.h
//  Ubi
//
//  Created by Rambod Rahmani on 30/09/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UbiStatusTag.h"
#import "UbiPlace.h"

@interface TimelineCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView * imgViewProfilo;
@property (weak, nonatomic) IBOutlet UILabel * lblNome;
@property (weak, nonatomic) IBOutlet UITextView * txtViewPost;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewMedia;
@property (weak, nonatomic) IBOutlet UILabel *lblData;
@property (weak, nonatomic) IBOutlet UILabel *lblWith;
@property (weak, nonatomic) IBOutlet UILabel *lblAt;
@property (weak, nonatomic) IBOutlet UILabel *lblTags;
@property (weak, nonatomic) IBOutlet UILabel *lblLoc;
@property (weak, nonatomic) IBOutlet UILabel *lblLikesComm;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnComm;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblWidth_width;

- (void)initProfileImgView:(NSIndexPath *)indexPath :(NSURL *)imageURL;
- (void)initLblData:(NSString *)Data;
- (void)initLblTags:(NSArray *)tags;
- (void)initLblLoc:(UbiPlace *)status_place;
- (void)initTxtViewPost:(NSString *)StatusText;
- (void)initImgViewMedia:(NSURL *)MediaURL;
- (void)initLblLikesComm:(NSNumber *)likes_num :(NSNumber *)comments_num :(NSIndexPath *)indexPath;

@end
