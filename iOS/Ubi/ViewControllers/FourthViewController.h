//
//  FourthViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 04/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "settingsMappaViewController.h"

@interface FourthViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSArray * elencoSettings;
}

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

