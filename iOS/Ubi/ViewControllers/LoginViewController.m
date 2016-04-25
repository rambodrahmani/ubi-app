//
//  LoginViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 31/07/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <FBLoginViewDelegate>

@end

@implementation LoginViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"

#pragma mark - ViewController lyfe cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	_btnGPlus.hidden = YES;
	_imgViewGPlus.hidden = YES;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		__block BOOL can_login = NO;
		
		iHasApp *detectionObject = [[iHasApp alloc] init];
		[detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
		} withSuccess:^(NSArray *appDictionaries) {
			for (NSDictionary * appInfo in appDictionaries) {
				NSString * app_bundle_id = [appInfo valueForKey:@"bundleId"];
				if ([app_bundle_id containsString:@"com.google.GooglePlus"])
				{
					can_login = YES;
					break;
				}
			}
			if (can_login) {
				_btnGPlus.hidden = NO;
				_imgViewGPlus.hidden = NO;
			}
		} withFailure:^(NSError *error) {
			[self showErrorMessage:error.description];
		}];
	});
	
    _acIndicView.clipsToBounds = YES;
    _acIndicView.layer.cornerRadius = 7;
    _acIndicView.layer.borderWidth = 1.0;
    _acIndicView.layer.borderColor = [[UIColor colorWithRed:(34.0/255.0) green:(206.0/255.0) blue:(210.0/255.0) alpha:1] CGColor];
    _acIndicView.hidden = YES;
    
    [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
	currentUbiUser = [[UbiUser alloc] init];
	accessoFacebookEseguito = FALSE;
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
	
    for (id obj in _fbLoginView.subviews)
    {
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"Registrati con Facebook";
            loginLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
	_fbLoginView.readPermissions = @[@"email", @"public_profile", @"user_about_me", @"user_activities", @"user_birthday", @"user_friends", @"user_status"];

    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"aLzI0FVPPugbQlvqwbyMXYYzo" andSecret:@"f9N5iODESOMdo4DJuvh9uDB0BwTxQWE0NJ0spSkBdNkaPfn5Xh"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    _btnTwitter.clipsToBounds = YES;
    _btnTwitter.layer.cornerRadius = 2;
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = [NSString stringWithFormat:@"586980769222-mdj7jjavai8ajkvtnkq90fksk1apa04d.apps.googleusercontent.com"];
    signIn.scopes = @[ kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe, kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopePlusUserinfoProfile ];
    signIn.delegate = self;
    [signIn trySilentAuthentication];
    _btnGPlus.clipsToBounds = YES;
    _btnGPlus.layer.cornerRadius = 2;
    
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[self showNoInternetConnectionMessage];
	}
	
	if ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ) {
		_logoUbi_height.constant = 260.0;
		_logoUbi_width.constant = 300.0;
		_imgViewLogoTopConstraint.constant = 70;
		[_imgViewLogo needsUpdateConstraints];
	}
	
	_btnUbiSignUp.layer.borderWidth = 1;
	_btnUbiSignUp.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_btnUbiSignUp.layer.cornerRadius = 10;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if ( !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ) {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if (orientation == UIInterfaceOrientationPortrait) {
			_imgViewLogoTopConstraint.constant = 40;
		}
		else {
			_imgViewLogoTopConstraint.constant = 10;
		}
		[_imgViewLogo needsUpdateConstraints];
	}
}

#pragma mark - Ubi Sign Up
- (IBAction)openUbiSignUpView:(id)sender
{
	[self performSegueWithIdentifier:@"ShowUbiSignupView" sender:self];
}

#pragma mark - Facebook Login
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
	accessoFacebookEseguito = TRUE;
    _acIndicView.hidden = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:NO forKey:@"accessoGPInCorso"];
	
	if (accessoFacebookEseguito) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
        [self getUserFacebookInfo];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
	if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
        [self showErrorMessage:[FBErrorUtility userMessageForError:error]];
	} else {
		if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            [self showErrorMessage:@"Login cancelled."];
		} else {
			NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
											   objectForKey:@"body"]
											  objectForKey:@"error"];
			if ([errorInformation objectForKey:@"message"] != NULL) {
                [self showErrorMessage:[errorInformation objectForKey:@"message"]];
			}
		}
	}
}

- (void)getUserFacebookInfo
{
    [FBSession openActiveSessionWithReadPermissions:@[]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         if (!error){
             if (state == FBSessionStateOpen){
                 [FBRequestConnection startWithGraphPath:@"/me"
                                              parameters:nil
                                              HTTPMethod:@"GET"
                                       completionHandler:^(
                                                           FBRequestConnection *connection,
                                                           id result,
                                                           NSError *error
                                                           )
                 {
                     currentUbiUser.email = [result valueForKey:@"email"];
                     currentUbiUser.name = [result valueForKey:@"first_name"];
                     currentUbiUser.surname = [result valueForKey:@"last_name"];
                     NSString * userID = [result valueForKey:@"id"];
                     currentUbiUser.profile_pic = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userID]];
                     currentUbiUser.profile_url = [NSURL URLWithString:[result objectForKey:@"link"]];
                     currentUbiUser.bio = [result valueForKey:@"bio"];
                     currentUbiUser.bio = [self stringByStrippingHTML:currentUbiUser.bio];
                     NSString * Compleanno = [result valueForKey:@"birthday"];
                     NSArray * CompleannoArr = [Compleanno componentsSeparatedByString: @"/"];
                     NSString * day = [CompleannoArr objectAtIndex: 0];
                     NSString * month = [CompleannoArr objectAtIndex: 1];
                     NSString * year = [CompleannoArr objectAtIndex: 2];
                     currentUbiUser.birthday = [NSString stringWithFormat:@"%@/%@/%@", year, month, day];
                     NSString * gender = [result valueForKey:@"gender"];
                     if ([gender  isEqual: @"male"]) {
                         currentUbiUser.gender = @"M";
                     }else{
                         currentUbiUser.gender = @"F";
                     }
                 }];
                 
                 [FBRequestConnection startWithGraphPath:@"/me/statuses"
                                              parameters:nil
                                              HTTPMethod:@"GET"
                                       completionHandler:^(
                                                           FBRequestConnection *connection,
                                                           id result,
                                                           NSError *error
                                                           )
                 {
                     NSString * dataLastPost = [result valueForKey:@"data"];
                     NSArray * myArray = [dataLastPost valueForKey:@"message"];
                     currentUbiUser.last_status_text = [NSString stringWithFormat:@"%@", [myArray objectAtIndex:0]];
                     currentUbiUser.last_status_text = [self stringByStrippingHTML:currentUbiUser.last_status_text];
					 
					 currentUbiUser.sign_in_account = @"facebook";
					 
                     [self goToHome];
                 }];
             }
             else {
				 if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                     [self showErrorMessage:[FBErrorUtility userMessageForError:error]];
				 } else {
					 if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                         [self showErrorMessage:@"Login cancelled."];
					 } else {
						 NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
															objectForKey:@"body"]
														   objectForKey:@"error"];
						 if ([errorInformation objectForKey:@"message"] != NULL) {
                             [self showErrorMessage:[errorInformation objectForKey:@"message"]];
						 }
					 }
				 }
             }
         }
     }];
}

#pragma mark - Twitter Login
- (IBAction)twitterLogin:(id)sender
{	
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
		[self showNoInternetConnectionMessage];
    } else {
        _acIndicView.hidden = NO;
        [self twitterSigninMethod];
    }
}

- (void)showTwitterView
{
	[_btnTwitter.titleLabel setText:[NSString stringWithFormat:@"Log out"]];
    _acIndicView.hidden = YES;
    [self performSegueWithIdentifier:@"ShowTwitterLoginView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowTwitterLoginView"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didDismissTwitterLoginViewController)
													 name:@"TwitterLoginViewControllerDismissed"
												   object:nil];
		
        TwitterLoginViewController *destinationViewContoller = (TwitterLoginViewController *)segue.destinationViewController;
        destinationViewContoller.currentUbiUser = currentUbiUser;
    }
}

- (void)didDismissTwitterLoginViewController {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"TwitterLoginViewControllerDismissed"
												  object:nil];
	
	[self performSegueWithIdentifier:@"ShowTabBarController" sender:nil];
}

- (void)storeAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)twitterSigninMethod
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
             if ([arrayOfAccounts count] > 0)
             {
                 if ([arrayOfAccounts count] > 1) {
                     [self performSelectorOnMainThread:@selector(twitterActionSheet)
                                            withObject:nil
                                         waitUntilDone:YES];
                 }
                 else {
                     [self getUserTwitterInfo:(int)(arrayOfAccounts.count - 1)];
                 }
             }
             else
             {
                 UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                     if (success) {
						 [_acIndicView setHidden:NO];
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         [defaults setBool:YES forKey:@"accessoTwitterWeb"];
                         [self logTwitterTimeline];
                     }
                     else
                     {
                         [self showErrorMessage:@""];
                     }
                 }];
				 [self presentViewController:loginController animated:YES completion:^{
					 [_acIndicView setHidden:YES];
				 }];
             }
         }
         else
         {
             if(error.code == 6)
             {
                 [self showErrorMessage:@""];
             }
             UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                 if (success) {
					 [_acIndicView setHidden:NO];
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setBool:YES forKey:@"accessoTwitterWeb"];
                     [self logTwitterTimeline];
                 }
                 else
                 {
                     [self showErrorMessage:@""];
                 }
             }];
             [self presentViewController:loginController animated:YES completion:^{
				 [_acIndicView setHidden:YES];
			 }];
         }
     }];
}

- (void)twitterActionSheet
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
    UIActionSheet *chooseaccount = [[UIActionSheet alloc] initWithTitle:@"Account Twitter:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (int i = 0; i < [arrayOfAccounts count]; i++) {
        ACAccount * accountname = [arrayOfAccounts objectAtIndex:i];
        [chooseaccount addButtonWithTitle:accountname.username];
    }https:
    
    [chooseaccount addButtonWithTitle:@"Cancel"];
    chooseaccount.cancelButtonIndex = arrayOfAccounts.count;
    chooseaccount.tag = 1;
    [chooseaccount showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)chooseaccount clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (chooseaccount.tag) {
        case 1: {
            [self getUserTwitterInfo:(int)buttonIndex];
            break;
        }
        default:
            break;
    }
}

- (void)getUserTwitterInfo:(int)usernameIndex
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
			
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:usernameIndex];
				
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
                
                [twitterInfoRequest setAccount:twitterAccount];
				
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
						
                        if ([urlResponse statusCode] == 429) {
                            [self showErrorMessage:@""];
                            return;
                        }

                        if (error) {
                            [self showErrorMessage:@""];
                            return;
                        }
                        
                        if (responseData) {
                            NSError *error;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];

							if (!error) {
								NSString * name = [(NSDictionary *)TWData objectForKey:@"name"];
								NSArray* nameSplit = [name componentsSeparatedByString: @" "];
								currentUbiUser.name = [nameSplit objectAtIndex:0];
								currentUbiUser.surname = [nameSplit objectAtIndex:1];
								currentUbiUser.profile_pic = [NSURL URLWithString:[[(NSDictionary *)TWData objectForKey:@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
								NSString * screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
								currentUbiUser.profile_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@", screen_name]];
								currentUbiUser.bio = [(NSDictionary *)TWData objectForKey:@"description"];
								currentUbiUser.bio = [self stringByStrippingHTML:currentUbiUser.bio];
								currentUbiUser.gender = @"U";
								currentUbiUser.birthday = @"";
							}
							else
							{
								[self showErrorMessage:error.description];
							}
                        }
                    });
                }];
				
                SLRequest *twitterInfoRequest2 = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
                
                [twitterInfoRequest2 setAccount:twitterAccount];
				
                [twitterInfoRequest2 performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
						
                        if ([urlResponse statusCode] == 429) {
                            [self showErrorMessage:@""];
                            return;
                        }
						
                        if (error) {
                            [self showErrorMessage:error.description];
                            return;
                        }
                        
                        if (responseData) {
                            NSError *error;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
							
							if (!error) {
								NSString * data_0 = [TWData objectAtIndex:0];
								currentUbiUser.last_status_text = [data_0 valueForKey:@"text"];
								currentUbiUser.last_status_text = [self stringByStrippingHTML:currentUbiUser.last_status_text];
							}
							else
							{
								[self showErrorMessage:error.description];
							}
                        }
						
						[self showTwitterView];
                    });
                }];
                
            }
        } else {
            [self showErrorMessage:error.description];
        }
    }];
}

- (void)logTwitterTimeline
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSArray *TWData = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID] isID:YES count:1];
            NSString * data_0 = [TWData objectAtIndex:0];
			
            NSString * user = [data_0 valueForKey:@"user"];
            NSString * name = [user valueForKey:@"name"];
            NSArray* nameSplit = [name componentsSeparatedByString: @" "];
            currentUbiUser.name = [nameSplit objectAtIndex:0];
            currentUbiUser.surname = [nameSplit objectAtIndex:1];
			currentUbiUser.profile_pic = [NSURL URLWithString:[[user valueForKey:@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""]];
            NSString * screen_name = [user valueForKey:@"screen_name"];
            currentUbiUser.profile_url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@", screen_name]];
            currentUbiUser.bio = [user valueForKey:@"description"];
			currentUbiUser.bio = [self stringByStrippingHTML:currentUbiUser.bio];
            currentUbiUser.last_status_text = [data_0 valueForKey:@"text"];
            currentUbiUser.last_status_text = [self stringByStrippingHTML:currentUbiUser.last_status_text];
            currentUbiUser.gender = @"U";
            currentUbiUser.birthday = @"";
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"accessoTwitterWeb"];
                    [self showTwitterView];
                }
            });
        }
    });
}

#pragma mark Google - Plus Login
- (IBAction)googlePlusLogin:(id)sender
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
		[self showNoInternetConnectionMessage];
    } else {
        _acIndicView.hidden = NO;
        [_btnGPlus.titleLabel setText:[NSString stringWithFormat:@"Log out"]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"accessoGPInCorso"];
		
		__block BOOL can_login = NO;
		
		iHasApp *detectionObject = [[iHasApp alloc] init];
		[detectionObject detectAppDictionariesWithIncremental:^(NSArray *appDictionaries) {
		} withSuccess:^(NSArray *appDictionaries) {
			
			for (NSDictionary * appInfo in appDictionaries) {
				NSString * app_bundle_id = [appInfo valueForKey:@"bundleId"];
				if ([app_bundle_id containsString:@"com.google.GooglePlus"])
				{
					can_login = YES;
					break;
				}
			}
			
			if (can_login) {
				[[GPPSignIn sharedInstance] authenticate];
			}
			else
			{
				_btnGPlus.hidden = YES;
				_imgViewGPlus.hidden = YES;
				/*
				[[[UIAlertView alloc] initWithTitle:@"Google Plus"
											message:@"Installa l'app di Google Plus sul tuo dispositivo per poter procedere."
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];*/
			}
			
		} withFailure:^(NSError *error) {
			[self showErrorMessage:error.description];
		}];
    }
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *) error
{
    if (error) {
        [self showErrorMessage:@""];
    } else {
        if ([[GPPSignIn sharedInstance] authentication]) {
            [_btnGPlus.titleLabel setText:[NSString stringWithFormat:@"Log out"]];
			
			currentUbiUser.sign_in_account = @"googleplus";
			
            [self getGooglePlusUserInfo];
        } else {
            // Perform other actions here
        }
    }
}

- (void)getGooglePlusUserInfo
{
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    [self showErrorMessage:@""];
                } else {
					currentUbiUser.google_plus_id = person.identifier;
                    GTLPlusPersonEmailsItem *email = person.emails[0];
                    currentUbiUser.email = email.value;
                    GTLPlusPersonName *fullName = person.name;
                    currentUbiUser.name = fullName.givenName;
                    currentUbiUser.surname = fullName.familyName;
                    currentUbiUser.profile_pic = [NSURL URLWithString:person.image.url];
					currentUbiUser.profile_pic = [NSURL URLWithString:[[currentUbiUser.profile_pic absoluteString] stringByReplacingOccurrencesOfString:@"?sz=50" withString:@""]];
                    currentUbiUser.profile_url = [NSURL URLWithString:person.url];
                    currentUbiUser.bio = person.aboutMe;
					currentUbiUser.bio = [self stringByStrippingHTML:currentUbiUser.bio];
                    NSString * birthday = person.birthday;
                    NSArray * splitBirthday = [birthday componentsSeparatedByString:@"-"];
                    NSString * year = [splitBirthday objectAtIndex:0];
                    NSString * month = [splitBirthday objectAtIndex:1];
                    NSString * day = [splitBirthday objectAtIndex:2];
                    currentUbiUser.birthday = [NSString stringWithFormat:@"%@/%@/%@", year, month, day];
                    if ([person.gender  isEqual: @"male"]) {
                        currentUbiUser.gender = @"M";
                    }else{
                        currentUbiUser.gender = @"F";
                    }
                    
                    GTLQueryPlus *query2 =
                    [GTLQueryPlus queryForActivitiesListWithUserId:@"me" collection:kGTLPlusCollectionPublic];
                    
                    [[[GPPSignIn sharedInstance] plusService] executeQuery:query2
                                                         completionHandler:^(GTLServiceTicket *ticket,
                                                                             GTLPlusActivityFeed *actFeed,
                                                                             NSError *error)
                                                 {
                                                     if (error) {
                                                         [self showErrorMessage:@""];
                                                     }
                                                     else
                                                     {
                                                         NSMutableArray * dateArray = [[NSMutableArray alloc] init];
                                                         for (GTLPlusActivity *activity in actFeed.items)
                                                         {
                                                             GTLDateTime * postDate = [activity published];
                                                             [dateArray addObject:[postDate date]];
                                                         }
                                                         NSDate *maxDate = [dateArray valueForKeyPath:@"@max.self"];
                                                         
                                                         currentUbiUser.last_status_text = @"NOT_PRESENT";
                                                         
                                                         for (GTLPlusActivity *activity in actFeed.items)
                                                         {
                                                             GTLDateTime * postDate = [activity published];
                                                             if ([[postDate date] isEqual:maxDate]) {
                                                                 GTLQueryPlus *query3 = [GTLQueryPlus queryForActivitiesGetWithActivityId:[activity identifier]];
                                                                 
                                                                 [plusService executeQuery:query3
                                                                         completionHandler:^(GTLServiceTicket *ticket,
                                                                                             GTLPlusActivity *acti,
                                                                                             NSError *error) {
                                                                             if (error) {
                                                                                 [self showErrorMessage:@""];
                                                                             } else {
                                                                                 GTLPlusActivityObject * objecto = [acti object];
                                                                                 currentUbiUser.last_status_text = [NSString stringWithFormat:@"%@", [objecto content]];
                                                                                 currentUbiUser.last_status_text = [self stringByStrippingHTML:currentUbiUser.last_status_text];
                                                                             }
                                                                         }];
                                                                 break;
                                                             }
                                                         }
                                                         
                                                         NSRange range = [currentUbiUser.last_status_text rangeOfString:@"NOT_PRESENT"];
                                                         if (range.length != 0) {
                                                             currentUbiUser.last_status_text = @"";
                                                         }
														 
														 [self goToHome];
                                                     }
                                                 }
                     ];
                }
            }];
}

#pragma mark - Helper methods
- (NSString *)stringByStrippingHTML:(NSString *)text
{
    if (!text) {
        return @"";
    }
    
	NSRange r;
	while ((r = [text rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		text = [text stringByReplacingCharactersInRange:r withString:@""];
    
	return text;
}

#define UserPassword @"password"

- (void)goToHome
{
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = currentUbiUser.email;
    extendedAuthRequest.userPassword = UserPassword;
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
     {
         currentUbiUser.chat_id = [NSNumber numberWithUnsignedInteger:session.userID];
         if ([currentUbiUser signUp]) {
             [self performSegueWithIdentifier:@"ShowTabBarController" sender:nil];
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
                  user.login = currentUbiUser.email;
                  user.password = UserPassword;
                  user.fullName = [NSString stringWithFormat:@"%@ %@", currentUbiUser.name, currentUbiUser.surname];
                  user.email = currentUbiUser.email;
                  user.customData = [currentUbiUser.profile_pic absoluteString];
                  
                  [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user)
                   {
                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response.data options:0 error:nil];
                       currentUbiUser.chat_id = [NSNumber numberWithUnsignedInteger:[[NSString stringWithFormat:@"%@", [[json valueForKey:@"user"] valueForKey:@"id"]] integerValue]];
                       
					   if ([currentUbiUser signUp]) {
                           [self performSegueWithIdentifier:@"ShowTabBarController" sender:nil];
                       }
                       else
                       {
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           [defaults setObject:@"" forKey:@"current_user_sign_in_account"];
                       }
                   } errorBlock:^(QBResponse *response) {
                       [self showErrorMessage:@"chat signup"];
                   }];
                  
              } errorBlock:^(QBResponse *response) {
                  [self showErrorMessage:@"chat signup"];
              }];
         }
         else
         {
             [self showErrorMessage:@"chat login"];
         }
     }];
}

- (void)showErrorMessage:(NSString *)message {
	[_acIndicView setHidden:YES];
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

- (void)showNoInternetConnectionMessage {
	[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
								message:@"The internet connection appears to be offline."
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

@end