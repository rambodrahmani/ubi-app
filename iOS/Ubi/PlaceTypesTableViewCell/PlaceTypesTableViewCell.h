//
//  PlaceTypesTableViewCell.h
//  Ubi
//
//  Created by Rambod Rahmani on 19/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceTypesTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel * lblPlaceTitle;
@property (nonatomic, strong) IBOutlet UIImageView * imgViewPlaceIcon;
@property (nonatomic, strong) IBOutlet UISwitch * switchPlace;

@property (nonatomic, strong) NSString * place_type;

- (IBAction)switchPlaceValueChanged:(id)sender;

@end
