//
//  MapFilteringViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 16/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "MapFilteringViewController.h"

@interface MapFilteringViewController ()

@end

@implementation MapFilteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _filtersView.clipsToBounds = YES;
    _filtersView.layer.cornerRadius = 7;
    _filtersView.layer.borderWidth = 2.0;
    _filtersView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	
	_placesTypesView.clipsToBounds = YES;
	_placesTypesView.layer.cornerRadius = 7;
	_placesTypesView.layer.borderWidth = 2.0;
	_placesTypesView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	
    UITapGestureRecognizer *singleTapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTapDetected:)];
    singleTapBgView.numberOfTapsRequired = 1;
    [_bgView setUserInteractionEnabled:YES];
    [_bgView addGestureRecognizer:singleTapBgView];
    
    UITapGestureRecognizer *singleTapFiltersView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filtersViewTapDetected:)];
    singleTapFiltersView.numberOfTapsRequired = 1;
    [_filtersView setUserInteractionEnabled:YES];
    [_filtersView addGestureRecognizer:singleTapFiltersView];
	
	UITapGestureRecognizer *singleTapPlaceTypesView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filtersViewTapDetected:)];
	singleTapPlaceTypesView.numberOfTapsRequired = 1;
	[_placesTypesView setUserInteractionEnabled:YES];
	[_placesTypesView addGestureRecognizer:singleTapPlaceTypesView];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * filtriMappa = [defaults objectForKey:@"mapFilters"];
    if ([filtriMappa containsObject:@"people"]) {
        [_btnPeople setImage:[UIImage imageNamed:@"people_selected.png"] forState:UIControlStateNormal];
        _btnPeople.tag = 1;
    }
    if ([filtriMappa containsObject:@"events"]) {
        [_btnEvents setImage:[UIImage imageNamed:@"events_selected.png"] forState:UIControlStateNormal];
        _btnEvents.tag = 1;
    }
    if ([filtriMappa containsObject:@"places"]) {
        [_btnPlaces setImage:[UIImage imageNamed:@"places_selected.png"] forState:UIControlStateNormal];
        _btnPlaces.tag = 1;
    }
	
	[self checkTypesFilters];
}

- (void)checkTypesFilters
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * filtriGooglePlaces = [defaults objectForKey:@"mapPlacesFilters"];
	if ([filtriGooglePlaces containsObject:@"restaurant"]) {
		[_btnTypeRestaurant setImage:[UIImage imageNamed:@"restaurant_selected.png"] forState:UIControlStateNormal];
		_btnTypeRestaurant.tag = 1;
	}
	else {
		[_btnTypeRestaurant setImage:[UIImage imageNamed:@"restaurant.png"] forState:UIControlStateNormal];
		_btnTypeRestaurant.tag = 0;
	}
	
	if ([filtriGooglePlaces containsObject:@"night_club"]) {
		[_btnTypeDisco setImage:[UIImage imageNamed:@"disco_selected.png"] forState:UIControlStateNormal];
		_btnTypeDisco.tag = 1;
	}
	else {
		[_btnTypeDisco setImage:[UIImage imageNamed:@"disco.png"] forState:UIControlStateNormal];
		_btnTypeDisco.tag = 0;
	}
	
	if ([filtriGooglePlaces containsObject:@"cafe"]) {
		[_btnTypeCafe setImage:[UIImage imageNamed:@"cafe_selected.png"] forState:UIControlStateNormal];
		_btnTypeCafe.tag = 1;
	}
	else {
		[_btnTypeCafe setImage:[UIImage imageNamed:@"cafe.png"] forState:UIControlStateNormal];
		_btnTypeCafe.tag = 0;
	}
	
	if ([filtriGooglePlaces containsObject:@"bar"]) {
		[_btnTypeBar setImage:[UIImage imageNamed:@"bar_selected.png"] forState:UIControlStateNormal];
		_btnTypeBar.tag = 1;
	}
	else {
		[_btnTypeBar setImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateNormal];
		_btnTypeBar.tag = 0;
	}
	
	if ( ((filtriGooglePlaces.count > 3) && ( (![filtriGooglePlaces containsObject:@"restaurant"]) || (![filtriGooglePlaces containsObject:@"night_club"]) || (![filtriGooglePlaces containsObject:@"cafe"]) || (![filtriGooglePlaces containsObject:@"bar"]) )) || (filtriGooglePlaces.count > 4) ) {
		[_btnMoreTypes setImage:[UIImage imageNamed:@"more_selected.png"] forState:UIControlStateNormal];
	}
	else {
		[_btnMoreTypes setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowPlaceTypesView"]) {
		//[_btnMoreTypes setImage:[UIImage imageNamed:@"more_selected.png"] forState:UIControlStateNormal];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(placeTypesViewControllerDismissed)
													 name:@"PlaceTypesViewControllerDismissed"
												   object:nil];
	}
}

- (void)placeTypesViewControllerDismissed {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"PlaceTypesViewControllerDismissed"
												  object:nil];
	
	[self checkTypesFilters];
}

- (void)bgViewTapDetected:(UIGestureRecognizer *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MapFilteringViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)filtersViewTapDetected:(UIGestureRecognizer *)sender
{
    return;
}

- (IBAction)addPeople:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * sharedFilters = [defaults objectForKey:@"mapFilters"];
    NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedFilters];
    if (_btnPeople.tag == 0) {
        _btnPeople.tag = 1;
        [_btnPeople setImage:[UIImage imageNamed:@"people_selected.png"] forState:UIControlStateNormal];
        if (![filters containsObject:@"people"]) {
            [filters addObject:@"people"];
        }
    } else {
        _btnPeople.tag = 0;
        [_btnPeople setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
        [filters removeObject:@"people"];
    }
    [defaults setObject:filters forKey:@"mapFilters"];
}

- (IBAction)addEvents:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * sharedFilters = [defaults objectForKey:@"mapFilters"];
    NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedFilters];
    if (_btnEvents.tag == 0) {
        _btnEvents.tag = 1;
        [_btnEvents setImage:[UIImage imageNamed:@"events_selected.png"] forState:UIControlStateNormal];
        if (![filters containsObject:@"events"]) {
            [filters addObject:@"events"];
        }
    } else {
        _btnEvents.tag = 0;
        [_btnEvents setImage:[UIImage imageNamed:@"events.png"] forState:UIControlStateNormal];
        [filters removeObject:@"events"];
    }
    [defaults setObject:filters forKey:@"mapFilters"];
}

- (IBAction)addPlaces:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray * sharedFilters = [defaults objectForKey:@"mapFilters"];
    NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedFilters];
    if (_btnPlaces.tag == 0) {
        _btnPlaces.tag = 1;
        [_btnPlaces setImage:[UIImage imageNamed:@"places_selected.png"] forState:UIControlStateNormal];
        if (![filters containsObject:@"places"]) {
            [filters addObject:@"places"];
        }
		[_placesTypesView setAlpha:0.0f];
		[_placesTypesView setHidden:NO];
		//fade in
		[UIView animateWithDuration:0.8f animations:^{
			[_placesTypesView setAlpha:1.0f];
		} completion:^(BOOL finished) {
		}];
    } else {
        _btnPlaces.tag = 0;
        [_btnPlaces setImage:[UIImage imageNamed:@"places.png"] forState:UIControlStateNormal];
        [filters removeObject:@"places"];
    }
    [defaults setObject:filters forKey:@"mapFilters"];
}

- (IBAction)addRestaurant:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * sharedPlacesFilters = [defaults objectForKey:@"mapPlacesFilters"];
	NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedPlacesFilters];
	if (_btnTypeRestaurant.tag == 0) {
		_btnTypeRestaurant.tag = 1;
		[_btnTypeRestaurant setImage:[UIImage imageNamed:@"restaurant_selected.png"] forState:UIControlStateNormal];
		if (![filters containsObject:@"restaurant"]) {
			[filters addObject:@"restaurant"];
		}
	} else {
		_btnTypeRestaurant.tag = 0;
		[_btnTypeRestaurant setImage:[UIImage imageNamed:@"restaurant.png"] forState:UIControlStateNormal];
		[filters removeObject:@"restaurant"];
	}
	[defaults setObject:filters forKey:@"mapPlacesFilters"];
}

- (IBAction)addDisco:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * sharedPlacesFilters = [defaults objectForKey:@"mapPlacesFilters"];
	NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedPlacesFilters];
	if (_btnTypeDisco.tag == 0) {
		_btnTypeDisco.tag = 1;
		[_btnTypeDisco setImage:[UIImage imageNamed:@"disco_selected.png"] forState:UIControlStateNormal];
		if (![filters containsObject:@"night_club"]) {
			[filters addObject:@"night_club"];
		}
	} else {
		_btnTypeDisco.tag = 0;
		[_btnTypeDisco setImage:[UIImage imageNamed:@"disco.png"] forState:UIControlStateNormal];
		[filters removeObject:@"night_club"];
	}
	[defaults setObject:filters forKey:@"mapPlacesFilters"];
}

- (IBAction)addCafe:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * sharedPlacesFilters = [defaults objectForKey:@"mapPlacesFilters"];
	NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedPlacesFilters];
	if (_btnTypeCafe.tag == 0) {
		_btnTypeCafe.tag = 1;
		[_btnTypeCafe setImage:[UIImage imageNamed:@"cafe_selected.png"] forState:UIControlStateNormal];
		if (![filters containsObject:@"cafe"]) {
			[filters addObject:@"cafe"];
		}
	} else {
		_btnTypeCafe.tag = 0;
		[_btnTypeCafe setImage:[UIImage imageNamed:@"cafe.png"] forState:UIControlStateNormal];
		[filters removeObject:@"cafe"];
	}
	[defaults setObject:filters forKey:@"mapPlacesFilters"];
}

- (IBAction)addBar:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * sharedPlacesFilters = [defaults objectForKey:@"mapPlacesFilters"];
	NSMutableArray * filters = [[NSMutableArray alloc] initWithArray:sharedPlacesFilters];
	if (_btnTypeBar.tag == 0) {
		_btnTypeBar.tag = 1;
		[_btnTypeBar setImage:[UIImage imageNamed:@"bar_selected.png"] forState:UIControlStateNormal];
		if (![filters containsObject:@"bar"]) {
			[filters addObject:@"bar"];
		}
	} else {
		_btnTypeBar.tag = 0;
		[_btnTypeBar setImage:[UIImage imageNamed:@"bar.png"] forState:UIControlStateNormal];
		[filters removeObject:@"bar"];
	}
	[defaults setObject:filters forKey:@"mapPlacesFilters"];
}

- (IBAction)goBack:(id)sender
{
	[_placesTypesView setAlpha:1.0f];
	//fade out
	[UIView animateWithDuration:0.8f animations:^{
		[_placesTypesView setAlpha:0.0f];
	} completion:^(BOOL finished) {
		[_placesTypesView setHidden:YES];
	}];
}

@end
