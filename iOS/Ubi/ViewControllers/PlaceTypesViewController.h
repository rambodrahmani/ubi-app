//
//  PlaceTypesViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 19/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceTypesTableViewCell.h"

@interface PlaceTypesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSArray * googleApiPlaces;
	
	NSArray * googleApiPlaces_types;
	
	NSArray * googleApiPlaces_Actual_types;
}

@property (weak, nonatomic) IBOutlet UITableView *placeTypesTableView;

- (IBAction)closePlaceTypesView:(id)sender;

@end
