//
//  LoginViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 31/07/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import <UIKit/UIKit.h>
#import "ChatService.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <Social/Social.h>
#import "FHSTwitterEngine.h"
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleOpenSource/GTLPlus.h>
#import <GoogleOpenSource/GTLPlusActivity.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "TwitterLoginViewController.h"
#import "iHasApp.h"

@class GPPSignInButton;

@interface LoginViewController : UIViewController <UIActionSheetDelegate, FHSTwitterEngineAccessTokenDelegate, GPPSignInDelegate, QBChatDelegate, QBActionStatusDelegate>
{
    BOOL accessoFacebookEseguito;
	
	UbiUser* currentUbiUser;
}

@property (weak, nonatomic) IBOutlet FBLoginView* fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton* btnGPlus;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewGPlus;
@property (weak, nonatomic) IBOutlet UIButton* btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton* btnUbiSignUp;
@property (weak, nonatomic) IBOutlet UIView* acIndicView;
@property (weak, nonatomic) IBOutlet UIImageView* imgViewLogo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoUbi_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoUbi_width;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* imgViewLogoTopConstraint;

- (IBAction)twitterLogin:(id)sender;
- (IBAction)googlePlusLogin:(id)sender;
- (IBAction)openUbiSignUpView:(id)sender;

@end
