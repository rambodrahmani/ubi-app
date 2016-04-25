//
//  FourthViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 04/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "FourthViewController.h"

@interface FourthViewController ()

@end

@implementation FourthViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	elencoSettings = [[NSArray alloc] initWithObjects:@"Mappa", @"Messaggi", @"Account", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [elencoSettings count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCellIdentifier"];
	[cell.textLabel  setText:[elencoSettings objectAtIndex:indexPath.row]];
	
	return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"ShowSettingsMappaView" sender:nil];
	}
	else if (indexPath.row == 1) {
		NSLog(@"Messaggi");
	}
	else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ShowSettingsAccountView" sender:nil];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSettingsMappaView"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"ShowSettingsAccountView"]) {
        
    }
}

@end
