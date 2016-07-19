//
//  UserDetailsHeader.h
//  Ubi
//
//  Created by Rambod Rahmani on 31/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailsHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView * imgViewCover;
@property (weak, nonatomic) IBOutlet UIImageView * imgViewProfile;
@property (weak, nonatomic) IBOutlet UILabel * lblNome;
@property (weak, nonatomic) IBOutlet UILabel * lblBio;
@property (weak, nonatomic) IBOutlet UIToolbar * toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem * btnDirectMessage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem * btnFriendRequest;
@property (weak, nonatomic) IBOutlet UIBarButtonItem * btnBuzz;

@end
