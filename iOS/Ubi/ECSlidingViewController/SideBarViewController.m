//
//  MenuViewController.m
//  SlideOutDemo
//
//  Created by Rambod Rahmani on 15/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "SideBarViewController.h"

@interface SideBarViewController ()

@end

@implementation SideBarViewController

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    if (self.slidingViewController.currentTopViewPosition == 0) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
    else {
        [self.slidingViewController anchorTopViewToLeftAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    _mainTableView.contentInset = UIEdgeInsetsMake(0, -8, 0, 0);
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

- (IBAction)scValueChanged:(id)sender
{	
    [_mainTableView reloadData];
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell;
	
	if (_segmentedControl.selectedSegmentIndex == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
	}
	else if (_segmentedControl.selectedSegmentIndex == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"PIMCell"];
	}
	
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
