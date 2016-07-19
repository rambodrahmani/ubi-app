//
//  SettingsAccountViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 14/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import <Accelerate/Accelerate.h>

@interface SettingsAccountViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UbiUser * currentUbiUser;
    
    BOOL picFromCamera;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCoverPic;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblSocialNetwork;
@property (weak, nonatomic) IBOutlet UILabel *lblNome;
@property (weak, nonatomic) IBOutlet UILabel *lblCognome;
@property (weak, nonatomic) IBOutlet UILabel *lblDataDiNascita;
@property (weak, nonatomic) IBOutlet UILabel *lblSesso;
@property (weak, nonatomic) IBOutlet UILabel *lblLastPost;
@property (weak, nonatomic) IBOutlet UILabel *lblBio;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
