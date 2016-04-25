//
//  SearchViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 20/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <MapKit/MapKit.h>
#import "FTGooglePlacesAPI.h"
#import "UIImageView+WebCache.h"
#import "UserDetailsViewController.h"
#import "PlaceDetailsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	CLLocationManager * locationManager;
	
	NSMutableArray * id_caricati;
	NSMutableDictionary * dati_utenti_caricati;
	
	BOOL allUsersHaveBeenLoaded;
	BOOL allPlacesHaveBeenLoaded;
	
    Reachability *networkReachability;
	
	NSMutableArray * loadedNearbyPlaces;
}

@property (weak, nonatomic) IBOutlet UITableView * resultsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar * searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicatorView;

@property (nonatomic, strong) NSMutableArray * nearbyPlacesResults;
@property (nonatomic, strong) NSMutableArray * searchPlacesResults;
@property (nonatomic, strong) NSMutableArray * searchUsersResults;

@end
