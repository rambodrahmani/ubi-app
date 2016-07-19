//
//  ChatViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 06/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatService.h"
#import <Quickblox/Quickblox.h>
#import "ChatMessageTableViewCell.h"

@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate, QBChatDelegate>
{
	NSString * recipientFullName;
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, strong) QBChatRoom *chatRoom;
@property (nonatomic, strong) QBChatDialog *dialog;

- (IBAction)sendMessage:(id)sender;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@end
