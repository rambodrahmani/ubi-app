//
//  UbiSignupViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 28/03/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UbiUser.h"

@interface UbiSignupViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
{
	UbiUser* currentUbiUser;
	
	BOOL picFromCamera;
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldNome;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldCognome;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scSex;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBio;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldBirthday;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfilePic;
@property (weak, nonatomic) IBOutlet UIButton *btnContinua;
@property (weak, nonatomic) IBOutlet UIButton *btnAnnulla;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;

- (IBAction)showCalendar:(id)sender;
- (IBAction)continueWithSignup:(id)sender;
- (IBAction)goBack:(id)sender;

@end
