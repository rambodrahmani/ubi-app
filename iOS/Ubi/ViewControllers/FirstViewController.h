//
//  FirstViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 06/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import "UbiPlace.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <MapKit/MapKit.h>
#import "PlaceAnnotation.h"
#import "FTGooglePlacesAPI.h"
#import "UserMapAnnotation.h"
#import "PlaceMapAnnotation.h"
#import "EventMapAnnotation.h"
#import "ThirdViewController.h"
#import "UIImageView+WebCache.h"
#import "WebViewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "UserCalloutMapAnnotation.h"
#import "PlaceCalloutMapAnnotation.h"
#import "EventCalloutMapAnnotation.h"
#import "UserDetailsViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "UIViewController+ECSlidingViewController.h"
#import "SearchViewController.h"
#import "EventDetailsViewController.h"

@interface FirstViewController : UIViewController <UIAlertViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITabBarControllerDelegate, UITabBarDelegate>
{
	UbiUser * currentUbiUser;
	
	BOOL canRequest;
	BOOL refreshUserData;
	
    CLLocationManager * locationManager;
	
	NSMutableArray * id_caricati;
	NSMutableDictionary * dati_utenti_caricati;
	
    UbiPlace * placeDetails;
    
    Reachability * networkReachability;
    
    NSString * chatDialogName;
	
	NSArray * filtriMappa;
	
	NSMutableArray * loaded_places;
	
	NSMutableArray * loaded_events_ids;
	NSMutableArray * loaded_events_data;
}

@property (weak, nonatomic) IBOutlet MKMapView * mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnSearch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnSideBar;
@property (weak, nonatomic) IBOutlet UIView *btnFiltersView;
@property (weak, nonatomic) IBOutlet UIView *btnUserLocView;

@property (nonatomic, retain) MKAnnotationView * selectedAnnotationView;

@property (nonatomic, retain) UserCalloutMapAnnotation * userCalloutAnnotation;
@property (nonatomic, retain) PlaceCalloutMapAnnotation * placeCalloutAnnotation;
@property (nonatomic, retain) EventCalloutMapAnnotation * eventCalloutAnnotation;

- (IBAction)showMapFilteringView:(id)sender;
- (IBAction)showUserLocation:(id)sender;

@end

