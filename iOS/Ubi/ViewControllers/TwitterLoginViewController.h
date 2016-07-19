//
//  TwitterLoginViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 11/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import "ChatService.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TwitterLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *acIndicView;
@property (weak, nonatomic) IBOutlet UILabel *lblSignIn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainView_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSignIn_top;

@property (copy, nonatomic) UbiUser* currentUbiUser;

- (IBAction)twitterGoToHome:(id)sender;

@end
