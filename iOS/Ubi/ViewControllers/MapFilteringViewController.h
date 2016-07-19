//
//  MapFilteringViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 16/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFilteringViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *filtersView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *placesTypesView;

@property (weak, nonatomic) IBOutlet UIButton *btnPeople;
@property (weak, nonatomic) IBOutlet UIButton *btnEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnPlaces;

@property (weak, nonatomic) IBOutlet UIButton *btnTypeBar;
@property (weak, nonatomic) IBOutlet UIButton *btnTypeCafe;
@property (weak, nonatomic) IBOutlet UIButton *btnTypeDisco;
@property (weak, nonatomic) IBOutlet UIButton *btnTypeRestaurant;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreTypes;

- (IBAction)addPeople:(id)sender;
- (IBAction)addEvents:(id)sender;
- (IBAction)addPlaces:(id)sender;
- (IBAction)addRestaurant:(id)sender;
- (IBAction)addDisco:(id)sender;
- (IBAction)addCafe:(id)sender;
- (IBAction)addBar:(id)sender;
- (IBAction)goBack:(id)sender;

@end
