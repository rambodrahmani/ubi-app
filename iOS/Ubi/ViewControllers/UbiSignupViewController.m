//
//  UbiSignupViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 28/03/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "UbiSignupViewController.h"

@interface UbiSignupViewController ()

@end

@implementation UbiSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	currentUbiUser = [[UbiUser alloc] init];
	
	picFromCamera = FALSE;
	
	_btnContinua.layer.borderWidth = 1;
	_btnContinua.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnContinua.layer.cornerRadius = 10;
	
	_btnAnnulla.layer.borderWidth = 1;
	_btnAnnulla.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnAnnulla.layer.cornerRadius = 10;
	
	_datePickerView.layer.borderWidth = 1;
	_datePickerView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_datePickerView.layer.cornerRadius = 10;
	
	//The setup code (in viewDidLoad in your view controller)
	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
																					  action:@selector(handleSingleTap:)];
	[_backgroundView addGestureRecognizer:singleFingerTap];
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapImgView:)];
	singleTap.numberOfTapsRequired = 1;
	[_imgViewProfilePic setUserInteractionEnabled:YES];
	[_imgViewProfilePic addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)handleSingleTapImgView:(UITapGestureRecognizer *)recognizer
{
	[[[UIActionSheet alloc] initWithTitle:@"Select from:"
								 delegate:self
						cancelButtonTitle:@"Cancel"
				   destructiveButtonTitle:nil
						otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

#pragma mark - imagePickerController methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
		picker.delegate = self;
		picker.allowsEditing = YES;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		
		picFromCamera = FALSE;
		
		[self presentViewController:picker animated:YES completion:NULL];
	}
	else if (buttonIndex == 1)
	{
		if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[[[UIAlertView alloc] initWithTitle:@"Error"
										message:@"Device has no camera."
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles: nil] show];
		}
		else
		{
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
			picker.delegate = self;
			picker.allowsEditing = YES;
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			
			picFromCamera = TRUE;
			
			[self presentViewController:picker animated:YES completion:NULL];
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *chosenImage = [info[UIImagePickerControllerEditedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	
	[_imgViewProfilePic setImage:chosenImage];
	
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *theDate = [dateFormat stringFromDate:[_datePicker date]];
	[_txtFieldBirthday setText:theDate];
	_backgroundView.hidden = YES;
	_datePickerView.hidden = YES;
	_datePicker.hidden = YES;
	[_txtFieldBirthday resignFirstResponder];
	[_imgViewProfilePic becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:@"Bio..."]) {
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
	[textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:@""]) {
		textView.text = @"Bio...";
		textView.textColor = [UIColor lightGrayColor];
	}
	[textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}

- (IBAction)showCalendar:(id)sender;
{
	[_txtFieldBirthday resignFirstResponder];
	_backgroundView.hidden = NO;
	_datePickerView.hidden = NO;
	_datePicker.hidden = NO;
}

- (IBAction)continueWithSignup:(id)sender
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
		currentUbiUser.email = [_txtFieldEmail text];
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		NSString *theDate = [dateFormat stringFromDate:[_datePicker date]];
		currentUbiUser.birthday = theDate;
		if ((long)[_scSex selectedSegmentIndex] == 0) {
			currentUbiUser.gender = @"M";
		}
		else {
			currentUbiUser.gender = @"F";
		}
		currentUbiUser.sign_in_account = @"twitter";
	}
}

- (IBAction)goBack:(id)sender
{
	[self performSegueWithIdentifier:@"ShowLoginView" sender:self];
}

@end
