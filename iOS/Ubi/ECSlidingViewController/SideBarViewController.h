//
//  MenuViewController.h
//  SlideOutDemo
//
//  Created by Rambod Rahmani on 15/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface SideBarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate>

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)scValueChanged:(id)sender;

@end
