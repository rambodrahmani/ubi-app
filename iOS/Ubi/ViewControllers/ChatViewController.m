//
//  ChatViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 06/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

#define kNotificationDidReceiveNewMessage @"kNotificationDidReceiveNewMessage"
#define kNotificationDidReceiveNewMessageFromRoom @"kNotificationDidReceiveNewMessageFromRoom"
#define UserPassword @"password"

#pragma mark - ViewController lyfe cycle
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	_sendMessageButton.layer.borderWidth = 1;
	_sendMessageButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	_sendMessageButton.layer.cornerRadius = 10;

	recipientFullName = @"";
	
	_messages = [[NSMutableArray alloc] init];
	
	_messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [QBChat instance].delegate = self;
}

- (void)chatDidFailWithError:(NSInteger)code
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    extendedAuthRequest.userLogin = [defaults objectForKey:@"current_user_email"];
    extendedAuthRequest.userPassword = UserPassword;
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest successBlock:^(QBResponse *response, QBASession *session)
     {
         QBUUser *currentUser = [QBUUser user];
         currentUser.ID = session.userID;
         currentUser.login = [defaults objectForKey:@"current_user_email"];
         currentUser.password = UserPassword;
         currentUser.fullName = [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:@"current_user_name"], [defaults objectForKey:@"current_user_surname"]];
         currentUser.email = [defaults objectForKey:@"current_user_email"];
         currentUser.customData = [defaults objectForKey:@"current_user_profile_pic"];
         
         [QBChat instance].delegate = self;
         
         [[LocalStorageService shared] setCurrentUser:currentUser];
         
         [[QBChat instance] loginWithUser:currentUser];
     } errorBlock:^(QBResponse *response) {
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    _messages = [[NSMutableArray alloc] init];
    
	// Set keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	// Set chat notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
												 name:kNotificationDidReceiveNewMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
												 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
	
	// Set title
	if (self.dialog.type == QBChatDialogTypePrivate)
	{
		QBUUser *recipient = [LocalStorageService shared].usersAsDictionary[@(self.dialog.recipientID)];
		self.title = recipient.fullName == nil ? self.dialog.name : recipient.fullName;
		recipientFullName = recipient.fullName;
	}
	else
	{
		self.title = self.dialog.name;
	}
	
	// Join room
	if (self.dialog.type != QBChatDialogTypePrivate)
	{
		self.chatRoom = [self.dialog chatRoom];
		[[ChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
			// joined
		}];
	}
	
	// get messages history
	[QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.chatRoom leaveRoom];
	self.chatRoom = nil;
}

#pragma mark - Actions
- (IBAction)sendMessage:(id)sender
{
	if (self.messageTextField.text.length == 0)
	{
		return;
	}
	
	// create a message
	QBChatMessage *message = [[QBChatMessage alloc] init];
	message.text = self.messageTextField.text;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"save_to_history"] = @YES;
	[message setCustomParameters:params];
	
	// 1-1 Chat
	if (self.dialog.type == QBChatDialogTypePrivate)
	{
		// send message
		message.recipientID = [self.dialog recipientID];
		message.senderID = [LocalStorageService shared].currentUser.ID;
		
		[[ChatService instance] sendMessage:message];
		
		// save message
		[self.messages addObject:message];
		
		// Group Chat
	}
	else
	{
		[[ChatService instance] sendMessage:message toRoom:self.chatRoom];
	}
	
	// Reload table
	[self.messagesTableView reloadData];
	if (self.messages.count > 0)
	{
		[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
									  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
	
	// Clean text field
	[self.messageTextField setText:nil];
}

#pragma mark - Chat Notifications
- (void)chatDidReceiveMessageNotification:(NSNotification *)notification
{
	QBChatMessage *message = notification.userInfo[kMessage];
	if (message.senderID != self.dialog.recipientID)
	{
		return;
	}
	
	// save message
	[self.messages addObject:message];
	
	// Reload table
	[self.messagesTableView reloadData];
	if (self.messages.count > 0)
	{
		[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
									  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification
{
	QBChatMessage *message = notification.userInfo[kMessage];
	NSString *roomJID = notification.userInfo[kRoomJID];
	
	if (![self.chatRoom.JID isEqualToString:roomJID])
	{
		return;
	}
	
	// save message
	[self.messages addObject:message];
	
	// Reload table
	[self.messagesTableView reloadData];
	if (self.messages.count > 0)
	{
		[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
									  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
	
	ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
	if (cell == nil)
	{
		cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	QBChatAbstractMessage *message = self.messages[indexPath.row];
	//
	[cell configureCellWithMessage:message andRecipientFullName:recipientFullName];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
	CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
	return cellHeight;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[_messageTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note
{
    self.tableBottomConstraint.constant = 173;
    [self.messagesTableView needsUpdateConstraints];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -167);
        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -167);
        self.bgView.transform = CGAffineTransformMakeTranslation(0, -167);
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  self.messagesTableView.frame.size.height - 167);
    } completion:^(BOOL finished) {
        
    }];
	
	if (self.messages.count > 0)
	{
		[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
									  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

- (void)keyboardWillHide:(NSNotification *)note
{
	self.tableBottomConstraint.constant = 8;
	[self.messagesTableView needsUpdateConstraints];
	
	[UIView animateWithDuration:0.3 animations:^{
		self.messageTextField.transform = CGAffineTransformIdentity;
		self.sendMessageButton.transform = CGAffineTransformIdentity;
        self.bgView.transform = CGAffineTransformIdentity;
		self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
												  self.messagesTableView.frame.origin.y,
												  self.messagesTableView.frame.size.width,
												  self.messagesTableView.frame.size.height + 167);
    } completion:^(BOOL finished) {
        
    }];
	
	if (self.messages.count > 0)
	{
		[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
									  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

#pragma mark - QBActionStatusDelegate
- (void)completedWithResult:(Result *)result
{
	if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class])
	{
		QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
		NSArray *messages = res.messages;
		[self.messages addObjectsFromArray:[messages mutableCopy]];
		//
		[self.messagesTableView reloadData];
		if (self.messages.count > 0)
		{
			[self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
										  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
		}
	}
}

@end
