//
//  UsersViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 06/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "ThirdViewController.h"
#import "UIImageView+WebCache.h"

@interface ChatUsersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate, QBChatDelegate>
{
	NSMutableArray * id_caricati;
	NSMutableDictionary * dati_utenti_caricati;
	
	NSString * chatDialogName;
    
    UbiUser * currentUbiUser;
}

@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, weak) IBOutlet UITableView *usersTableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

@end
