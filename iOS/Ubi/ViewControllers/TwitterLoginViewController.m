//
//  TwitterLoginViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 11/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "TwitterLoginViewController.h"

@interface TwitterLoginViewController ()

@end

@implementation TwitterLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mainView.clipsToBounds = YES;
    _mainView.layer.cornerRadius = 5;
	_mainView.layer.borderWidth = 1.0;
	_mainView.layer.borderColor = [[UIColor colorWithRed:(34.0/255.0) green:(206.0/255.0) blue:(210.0/255.0) alpha:1] CGColor];
	
    _datePickerView.clipsToBounds = YES;
    _datePickerView.layer.cornerRadius = 5;
    
    _btnTwitter.clipsToBounds = YES;
    _btnTwitter.layer.cornerRadius = 4;
    
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.0;
	
    _acIndicView.clipsToBounds = YES;
    _acIndicView.layer.cornerRadius = 7;
    _acIndicView.layer.borderWidth = 1.0;
	_acIndicView.layer.borderColor = [[UIColor colorWithRed:(34.0/255.0) green:(206.0/255.0) blue:(210.0/255.0) alpha:1] CGColor];
    _acIndicView.hidden = YES;
	
	if ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ) {
		_mainView_top.constant = 280.0;
		[_mainView needsUpdateConstraints];
		
		_lblSignIn_top.constant = 294.0;
		[_lblSignIn needsUpdateConstraints];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[UIView animateWithDuration:0.8 animations:^(void) {
		_bgView.alpha = 0.7;
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)twitterGoToHome:(id)sender
{
    if ( ([_txtFieldEmail.text isEqual: @""]) || ([_txtFieldEmail.text rangeOfString:@"@"].location == NSNotFound) || ([_txtFieldEmail.text rangeOfString:@"."].location == NSNotFound)) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid Email Address"
									message:@"Provide a valid email address in order to sign up."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
    }
    else
    {
		_acIndicView.hidden = NO;
		_currentUbiUser.email = [_txtFieldEmail text];
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		NSString *theDate = [dateFormat stringFromDate:[_datePicker date]];
		_currentUbiUser.birthday = theDate;
		if ((long)[_segmentedControl selectedSegmentIndex] == 0) {
			_currentUbiUser.gender = @"M";
		}
		else {
			_currentUbiUser.gender = @"F";
		}
		_currentUbiUser.sign_in_account = @"twitter";
		[self goToHome];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#define UserPassword @"password"

- (void)goToHome
{
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = _currentUbiUser.email;
    extendedAuthRequest.userPassword = UserPassword;
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
     {
         _currentUbiUser.chat_id = [NSNumber numberWithUnsignedInteger:session.userID];
		 if ([_currentUbiUser signUp]) {
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterLoginViewControllerDismissed"
																 object:nil
															   userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:@"" forKey:@"current_user_sign_in_account"];
         }
     } errorBlock:^(QBResponse *response) {
         NSRange range = [[response description] rangeOfString:@"status: 401"];
         if (range.length != 0) {
             [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session)
              {
                  QBUUser *user = [QBUUser user];
                  user.login = _currentUbiUser.email;
                  user.password = UserPassword;
                  user.fullName = [NSString stringWithFormat:@"%@ %@", _currentUbiUser.name, _currentUbiUser.surname];
                  user.email = _currentUbiUser.email;
                  user.customData = [_currentUbiUser.profile_pic absoluteString];
                  
                  [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user)
                   {
                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.data options:0 error:nil];
                       _currentUbiUser.chat_id = [NSNumber numberWithUnsignedInteger:[[NSString stringWithFormat:@"%@", [[json valueForKey:@"user"] valueForKey:@"id"]] integerValue]];
                       
					   if ([_currentUbiUser signUp]) {
						   [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterLoginViewControllerDismissed"
																			   object:nil
																			 userInfo:nil];
						   [self dismissViewControllerAnimated:YES completion:nil];
                       }
                       else
                       {
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           [defaults setObject:@"" forKey:@"current_user_sign_in_account"];
                       }
                   } errorBlock:^(QBResponse *response) {
					   [self showErrorMessage:@"twitterloginview - chat signup"];
                   }];
                  
              } errorBlock:^(QBResponse *response) {
				  [self showErrorMessage:@"twitterloginview - chat signup"];
              }];
         }
         else
         {
			 [self showErrorMessage:@"twitterloginview - chat login"];
         }
     }];
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
