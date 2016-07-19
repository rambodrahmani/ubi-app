//
//  ThirdViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 04/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ThirdViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kShowUsersViewControllerSegue @"ShowUsersViewControllerSegue"
#define kShowNewChatViewControllerSegue @"ShowNewChatViewControllerSegue"
#define UserPassword @"password"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	Reachability * networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"Connessione Internet Assente"
									message:@"Connettiti ad internet per poter utilizzare Ubi."
								   delegate:self
						  cancelButtonTitle:@"OK!"
						  otherButtonTitles:nil] show];
	} else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[_actIndicator startAnimating];

		if ([LocalStorageService shared].currentUser != nil) {
            [QBChat instance].delegate = self;
			[QBChat dialogsWithExtendedRequest:nil delegate:self];
			
            _btnBarCompose.enabled = YES;
            
			if (self.createdDialog != nil) {
				[self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
			}
            else if (self.createdChat != nil) {
                [self createDialogFromChat];
            }
		}
		else
		{
			QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
			extendedAuthRequest.userLogin = currentUbiUser.email;
			extendedAuthRequest.userPassword = UserPassword;
			[QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
			 {
				 QBUUser *currentUser = [QBUUser user];
				 currentUser.ID = session.userID;
				 currentUser.login = currentUbiUser.email;
				 currentUser.password = UserPassword;
				 currentUser.fullName = [NSString stringWithFormat:@"%@ %@", currentUbiUser.name, currentUbiUser.surname];
				 currentUser.email = currentUbiUser.email;
                 currentUser.customData = [currentUbiUser.profile_pic absoluteString];
                 
				 [QBChat instance].delegate = self;
				 [[LocalStorageService shared] setCurrentUser:currentUser];
				 
				 [[QBChat instance] loginWithUser:currentUser];
				 
				 [NSTimer scheduledTimerWithTimeInterval:60 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
				 
                 _btnBarCompose.enabled = YES;
                 
                 if (self.createdDialog != nil) {
                     [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
                 }
                 else if (self.createdChat != nil) {
                     [self createDialogFromChat];
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
							   [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
								{
									QBUUser *currentUser = [QBUUser user];
									currentUser.ID = session.userID;
									currentUser.login = currentUbiUser.email;
									currentUser.password = UserPassword;
									currentUser.fullName = [NSString stringWithFormat:@"%@ %@", currentUbiUser.name, currentUbiUser.surname];
									currentUser.email = currentUbiUser.email;
									currentUser.customData = [currentUbiUser.profile_pic absoluteString];
                                    
									[QBChat instance].delegate = self;
									
									[[LocalStorageService shared] setCurrentUser:currentUser];
									
									[[QBChat instance] loginWithUser:currentUser];
									
									[NSTimer scheduledTimerWithTimeInterval:60 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
									
                                    _btnBarCompose.enabled = YES;
                                    
                                    if (self.createdDialog != nil) {
                                        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
                                    }
                                    else if (self.createdChat != nil) {
                                        [self createDialogFromChat];
                                    }
								} errorBlock:^(QBResponse *response) {
                                    [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                                message:@"Please retry."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil] show];
								}];
							   
						   } errorBlock:^(QBResponse *response) {
                               [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                           message:@"Please retry."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil] show];
						   }];
						  
					  } errorBlock:^(QBResponse *response) {
                          [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                      message:@"Please retry."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil] show];
					  }];
				 }
                 else
                 {
                     [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
                                                 message:@"Please retry."
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
			 }];
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	currentUbiUser = [[UbiUser alloc] initFromCache];
	
    _dialogsTableView.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
	_dialogsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createDialogFromChat {
    [QBChat createDialog:_createdChat delegate:self];
}

#pragma mark -
#pragma mark QBChatDelegate
// Chat delegate
- (void)chatDidLogin
{
	if([LocalStorageService shared].currentUser != nil){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[_actIndicator startAnimating];
		
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
	}
}

- (void)chatDidNotLogin
{
    NSLog(@"CHAT DID NOT LOGIN CHAT DID NOT LOGIN");
}

- (void)chatDidFailWithError:(NSInteger)code
{
	QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
	extendedAuthRequest.userLogin = currentUbiUser.email;
	extendedAuthRequest.userPassword = UserPassword;
	[QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
	 {
		 QBUUser *currentUser = [QBUUser user];
		 currentUser.ID = session.userID;
		 currentUser.login = currentUbiUser.email;
		 currentUser.password = UserPassword;
		 currentUser.fullName = [NSString stringWithFormat:@"%@ %@", currentUbiUser.name, currentUbiUser.surname];
		 currentUser.email = currentUbiUser.email;
		 
		 [QBChat instance].delegate = self;
		 
		 [[LocalStorageService shared] setCurrentUser:currentUser];
		 
		 [[QBChat instance] loginWithUser:currentUser];		 
	 } errorBlock:^(QBResponse *response) {
	 }];
}

#pragma mark - Actions
- (IBAction)createDialog:(id)sender
{
	[self performSegueWithIdentifier:kShowUsersViewControllerSegue sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.destinationViewController isKindOfClass:ChatViewController.class])
	{
		ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
		
		if (self.createdDialog != nil)
		{
			destinationViewController.dialog = self.createdDialog;
			self.createdDialog = nil;
		}
		else
		{
			QBChatDialog *dialog = self.dialogs[((UITableViewCell *)sender).tag];
			destinationViewController.dialog = dialog;
		}
	}
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dialogs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:recipient.email];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.tag = indexPath.row;
	
	switch (chatDialog.type) {
		case QBChatDialogTypePrivate:{
			cell.detailTextLabel.text = chatDialog.lastMessageText;
			QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(chatDialog.recipientID)];
			
			cell.textLabel.text = recipient.fullName;
			cell.detailTextLabel.text = chatDialog.lastMessageText;
			cell.detailTextLabel.textColor = [UIColor grayColor];
			
			[cell.imageView sd_setImageWithURL:[NSURL URLWithString:recipient.customData]
							  placeholderImage:[UIImage imageNamed:@""]];
			
			[cell.imageView setContentMode:UIViewContentModeScaleToFill];
			[cell.imageView.layer setCornerRadius:25];
			[cell.imageView.layer setMasksToBounds:YES];
			
			cell.layer.shouldRasterize = YES;
			cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
		}
			break;
		case QBChatDialogTypeGroup:{
			cell.detailTextLabel.text = chatDialog.lastMessageText;
			cell.textLabel.text = chatDialog.name;
			[cell.imageView setImage:[UIImage imageNamed:@"chatRoomIcon"]];
			
			CGSize newSize = CGSizeMake(80, 80);
			UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
			[cell.imageView.image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
			cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
			break;
		case QBChatDialogTypePublicGroup:{
			cell.detailTextLabel.text = chatDialog.lastMessageText;
			cell.textLabel.text = chatDialog.name;
			[cell.imageView setImage:[UIImage imageNamed:@"chatRoomIcon"]];
			
			CGSize newSize = CGSizeMake(80, 80);
			UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
			[cell.imageView.image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
			cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
			break;
			
		default:
			break;
	}
	
	return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
	
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    ChatViewController *chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChatView"];
    chatViewController.dialog = chatDialog;
	
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - QBActionStatusDelegate
- (void)completedWithResult:(Result *)result
{
	if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]])
	{
		QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
		NSArray *dialogs = pagedResult.dialogs;
		self.dialogs = [dialogs mutableCopy];
		
		QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:100];
		NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
		[QBRequest usersWithIDs:[dialogsUsersIDs allObjects] page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[LocalStorageService shared].users = users;
				
				[_actIndicator stopAnimating];
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				[_dialogsTableView reloadData];
				
				[UIView animateWithDuration:0.5f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
				} completion:^(BOOL finished){
					if (finished) {
						[_dialogsTableView reloadRowsAtIndexPaths:[_dialogsTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
					}
				}];
			});
		} errorBlock:nil];
	}
    else if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
        QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
        dialogRes.dialog.name = _createdChat.name;
        
        self.createdChat = nil;
        self.createdDialog = dialogRes.dialog;
        [self performSegueWithIdentifier:kShowNewChatViewControllerSegue sender:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Errors"
                                    message:[[result errors] componentsJoinedByString:@","]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil] show];
    }
}

#pragma mark - Helper methods
- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

@end
