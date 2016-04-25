//
//  ThirdViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 04/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import <UIKit/UIKit.h>
#import "ChatService.h"
#import "Reachability.h"
#import "ChatViewController.h"
#import "LocalStorageService.h"
#import <Quickblox/Quickblox.h>
#import "ChatUsersViewController.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"

@interface ThirdViewController : UIViewController <QBChatDelegate, UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>
{
	UbiUser * currentUbiUser;
}

@property (strong, nonatomic) QBChatDialog *createdDialog;
@property (strong, nonatomic) QBChatDialog *createdChat;

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBarCompose;

- (IBAction)createDialog:(id)sender;

@end

