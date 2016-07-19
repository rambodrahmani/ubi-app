//
//  UsersViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 06/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ChatUsersViewController.h"

#define UserPassword @"password"

@interface ChatUsersViewController ()

@end

@implementation ChatUsersViewController

#pragma mark - ViewController lyfe cycle
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    currentUbiUser = [[UbiUser alloc] initFromCache];
    
	id_caricati = [[NSMutableArray alloc] init];
	dati_utenti_caricati = [[NSMutableDictionary alloc] init];
	self.selectedUsers = [NSMutableArray array];
    
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:@"dati_utenti_caricati"];
	dati_utenti_caricati = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	id_caricati = [defaults objectForKey:@"id_caricati"];
    
	_usersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
	[_usersTableView reloadData];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    [QBChat instance].delegate = self;
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
         currentUser.customData = [currentUbiUser.profile_pic absoluteString];
         
         [QBChat instance].delegate = self;
         
         [[LocalStorageService shared] setCurrentUser:currentUser];
         
         [[QBChat instance] loginWithUser:currentUser];
     } errorBlock:^(QBResponse *response) {
     }];
}

#pragma mark - Actions
- (IBAction)createDialog:(id)sender
{
	if (self.selectedUsers.count == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nuova Conversazione"
														message:@"Seleziona almeno un utente per poter continuare."
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles: nil];
		[alert show];
		return;
	}
	
	
	QBChatDialog *chatDialog = [QBChatDialog new];
	
	NSMutableArray *selectedUsersIDs = [NSMutableArray array];
	NSMutableArray *selectedUsersNames = [NSMutableArray array];
	for (UbiUser *newUbiUser in self.selectedUsers)
	{
		[selectedUsersIDs addObject:newUbiUser.chat_id];
		[selectedUsersNames addObject:[NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname]];
	}
	chatDialog.occupantIDs = selectedUsersIDs;
	
	if (self.selectedUsers.count == 1)
	{
		chatDialog.name = [selectedUsersNames objectAtIndex:0];
		chatDialogName = [selectedUsersNames objectAtIndex:0];
		chatDialog.type = QBChatDialogTypePrivate;
	}
	else
	{
		chatDialog.name = [selectedUsersNames componentsJoinedByString:@", "];
		chatDialogName = [selectedUsersNames componentsJoinedByString:@", "];
		chatDialog.type = QBChatDialogTypeGroup;
	}
	
	[QBChat createDialog:chatDialog delegate:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [dati_utenti_caricati count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UbiUser *newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:indexPath.row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newUbiUser.email];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:newUbiUser.email];
        
        cell.tag = indexPath.row;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
		
		[cell.imageView sd_setImageWithURL:newUbiUser.profile_pic
						  placeholderImage:[UIImage imageNamed:@""]];
        
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
        [cell.imageView.layer setCornerRadius:25];
        [cell.imageView.layer setMasksToBounds:YES];
        
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        if ([self.selectedUsers containsObject:newUbiUser]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if ([newUbiUser.email isEqualToString:currentUbiUser.email]) {
            cell.userInteractionEnabled = FALSE;
        }
    }
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	
	UbiUser *newUbiUser = [dati_utenti_caricati objectForKey:[id_caricati objectAtIndex:indexPath.row]];
	if ([self.selectedUsers containsObject:newUbiUser]) {
		[self.selectedUsers removeObject:newUbiUser];
		selectedCell.accessoryType = UITableViewCellAccessoryNone;
	}
	else {
		[self.selectedUsers addObject:newUbiUser];
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
}

#pragma mark - QBActionStatusDelegate
- (void)completedWithResult:(Result *)result
{
	if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
		QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
		dialogRes.dialog.name = chatDialogName;
		
		ThirdViewController *dialogsViewController = self.navigationController.viewControllers[0];
		dialogsViewController.createdDialog = dialogRes.dialog;
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
        [[[UIAlertView alloc] initWithTitle:@"Errors"
                                    message:[[result errors] componentsJoinedByString:@","]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil] show];
	}
}

@end
