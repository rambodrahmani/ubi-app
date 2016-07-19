//
//  SettingsMappaViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 26/10/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "SettingsMappaViewController.h"

@interface SettingsMappaViewController ()

@end

@implementation SettingsMappaViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString * tipoMappa = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"mapType"]];
	
	if ([tipoMappa isEqualToString:@"Ibrida"]) {
		[_mapTypeSegmentedController setSelectedSegmentIndex:0];
	}
	else if ([tipoMappa isEqualToString:@"Satellite"]) {
		[_mapTypeSegmentedController setSelectedSegmentIndex:1];
	}
	else if ([tipoMappa isEqualToString:@"Standard"]) {
		[_mapTypeSegmentedController setSelectedSegmentIndex:2];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[self.navigationItem setTitle:@"Mappa"];
	
	[_mapTypeSegmentedController addTarget:self
									action:@selector(action:)
						  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)action:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[_mapTypeSegmentedController titleForSegmentAtIndex:_mapTypeSegmentedController.selectedSegmentIndex] forKey:@"mapType"];
}

@end
