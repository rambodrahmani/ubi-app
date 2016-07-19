//
//  FirstViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 06/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FirstViewController.h"
#import "UserCalloutMapAnnotationView.h"
#import "PlaceCalloutMapAnnotationView.h"
#import "EventCalloutMapAnnotationView.h"
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController ()

@end

@implementation FirstViewController

#define BASE_URL @"http://server.ubisocial.it/php/1.1"
#define app_version @"1.0"

#pragma mark - ViewController lyfe cycle
- (void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	NSString * tipoMappa = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"mapType"]];
	if ([tipoMappa isEqualToString:@"Ibrida"]) {
		[_mapView setMapType:MKMapTypeHybrid];
	}
	else if ([tipoMappa isEqualToString:@"Satellite"]) {
		[_mapView setMapType:MKMapTypeSatellite];
	}
	else if ([tipoMappa isEqualToString:@"Standard"]) {
		[_mapView setMapType:MKMapTypeStandard];
	}
	
	defaults = [NSUserDefaults standardUserDefaults];
	filtriMappa = [defaults objectForKey:@"mapFilters"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
    locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	refreshUserData = NO;
	canRequest = NO;
	
	currentUbiUser = [[UbiUser alloc] initFromCache];
	[currentUbiUser getUserInfoFromDB];
	
	self.view.autoresizesSubviews = YES;
	networkReachability = [Reachability reachabilityForInternetConnection];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(placeDataReceived:)
												 name:@"placeDetailViewData"
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentUbiUserStatus:)
                                                 name:@"updateUserStatusData"
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
	
	UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
									  initWithTarget:self action:@selector(didTapMap)];
	[_mapView addGestureRecognizer:tapRec];
	
	[self.view addGestureRecognizer:self.slidingViewController.panGesture];
	self.slidingViewController.anchorLeftPeekAmount = 70;
	self.tabBarController.delegate = self;
	
	_btnFiltersView.clipsToBounds = YES;
	_btnFiltersView.layer.cornerRadius = 7;
	_btnFiltersView.layer.borderWidth = 1.0;
	_btnFiltersView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	
	UITapGestureRecognizer *singleTapBgViewFiltersView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnFilterViewTapDetected:)];
	singleTapBgViewFiltersView.numberOfTapsRequired = 1;
	[_btnFiltersView setUserInteractionEnabled:YES];
	[_btnFiltersView addGestureRecognizer:singleTapBgViewFiltersView];
	
	_btnUserLocView.clipsToBounds = YES;
	_btnUserLocView.layer.cornerRadius = 7;
	_btnUserLocView.layer.borderWidth = 1.0;
	_btnUserLocView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
	
	UITapGestureRecognizer *singleTapBgViewBtnUserLoc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnUserLocViewTapDetected:)];
	singleTapBgViewBtnUserLoc.numberOfTapsRequired = 1;
	[_btnUserLocView setUserInteractionEnabled:YES];
	[_btnUserLocView addGestureRecognizer:singleTapBgViewBtnUserLoc];
	
	dati_utenti_caricati = [[NSMutableDictionary alloc] init];

	currentUbiUser.latitude = [NSNumber numberWithFloat:(float)locationManager.location.coordinate.latitude];
	currentUbiUser.longitude = [NSNumber numberWithFloat:(float)locationManager.location.coordinate.longitude];
	currentUbiUser.last_access = [NSString stringWithFormat:@"now"];
	currentUbiUser.distance = [NSNumber numberWithInt:0];
	[currentUbiUser saveCurrentUserToCache];
	
	[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dati_utenti_caricati];
	
    id_caricati = [[NSMutableArray alloc] init];
    [id_caricati addObject:currentUbiUser.db_id];
    
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:@"dati_utenti_caricati"];
	[defaults setObject:id_caricati forKey:@"id_caricati"];
	
	loaded_places = [[NSMutableArray alloc] init];
	loaded_events_ids = [[NSMutableArray alloc] init];
	loaded_events_data = [[NSMutableArray alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            if ([[[UIDevice currentDevice] systemVersion] integerValue] > 7)
            {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
            [_mapView setDelegate:self];
            [_mapView setShowsUserLocation:YES];
        }
        else if (status != kCLAuthorizationStatusAuthorizedAlways) {
            [[[UIAlertView alloc] initWithTitle:@"Location Services is disabled"
                                        message:@"Ubi needs access to your location. Please turn on Location Services in your device settings."
                                       delegate:self
                              cancelButtonTitle:@"Annulla"
                              otherButtonTitles:@"Impostazioni", nil] show];
        }
        else {
            [locationManager startUpdatingLocation];
            [_mapView setDelegate:self];
            [_mapView setShowsUserLocation:YES];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Location Services is disabled"
                                    message:@"Ubi needs access to your location. Please turn on Location Services in your device settings."
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setObject:currentUbiUser.db_id forKey:@"User_DB_ID"];
	currentInstallation.channels = @[ @"global" ];
	[currentInstallation saveInBackground];
	
	[self getAppVersion];
}

- (void)getAppVersion
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSDictionary *params = @{@"platform_id": [NSNumber numberWithInt:1]};
	
	[manager POST:[NSString stringWithFormat:@"%@/read_app_version.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError * error;
		NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
		
		if (!error) {
			NSNumber * version;
			for (NSDictionary * tempDic in jsonArray) {
				version = [[NSNumber alloc] initWithFloat:[[tempDic objectForKey:@"platform_version"] floatValue]];
			}
			
			if ([version floatValue] > 0) {
				if ( !([version floatValue] == [app_version floatValue]) )
				{
					[[[UIAlertView alloc] initWithTitle:@"Aggiornamento Disponibile"
												message:@"Una nuova versione di Ubi è disponibile nello store. Dato che ci troviamo nella fase di sviluppo della BETA devi installare la nuova versione per poter continuare a utilizzare Ubi."
											   delegate:self
									  cancelButtonTitle:@"Chiudi"
									  otherButtonTitles:nil] show];
				}
			}
		}
		else
		{
			[self showErrorMessage:error.description];
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self showErrorMessage:error.description];
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dati_utenti_caricati];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:@"dati_utenti_caricati"];
	[defaults setObject:id_caricati forKey:@"id_caricati"];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowWebviewView"]) {
		UINavigationController *destinationViewNavController = (UINavigationController *)segue.destinationViewController;
		WebViewViewController *destinationViewController = destinationViewNavController.viewControllers[0];
		if (sender) {
			destinationViewController.selectedURL = placeDetails.place_google_url;
			destinationViewController.webTitle = [NSString stringWithFormat:@"%@", placeDetails.place_name];
		} else {
			if (_userCalloutAnnotation.userMapAnnotation.relatedUbiUser) {
				destinationViewController.selectedURL = _userCalloutAnnotation.userMapAnnotation.relatedUbiUser.profile_url;
				destinationViewController.webTitle = [NSString stringWithFormat:@"%@ %@", _userCalloutAnnotation.userMapAnnotation.relatedUbiUser.name, _userCalloutAnnotation.userMapAnnotation.relatedUbiUser.surname];
			}
			else if (_placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace) {
				destinationViewController.selectedURL = _placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace.place_google_url;
				destinationViewController.webTitle = [NSString stringWithFormat:@"%@", _placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace.place_name];
			}
			else if (_eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent) {
				destinationViewController.selectedURL = _eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent.event_website_url;
				destinationViewController.webTitle = [NSString stringWithFormat:@"%@", _eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent.event_name];
			}
			
			[self removePopUpView];
		}
	}
	else if ([segue.identifier isEqualToString:@"ShowUserDetailsView"]) {
		UserDetailsViewController *destinationViewController = (UserDetailsViewController *)segue.destinationViewController;
		destinationViewController.selectedUbiUser = self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser;
		
		[self removePopUpView];
	}
	else if ([segue.identifier isEqualToString:@"ShowPlaceDetailsView"]) {
		PlaceDetailsViewController *destinationViewController = (PlaceDetailsViewController *)segue.destinationViewController;
		destinationViewController.selectedAddress = self.placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace;
		
		[self removePopUpView];
	}
	else if ([segue.identifier isEqualToString:@"ShowEventDetailsView"]) {
		EventDetailsViewController *destinationViewController = (EventDetailsViewController *)segue.destinationViewController;
		destinationViewController.ubi_event = self.eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent;
		
		[self removePopUpView];
	}
	else if ([segue.identifier isEqualToString:@"ShowSearchView"]) {
	}
	else if ([segue.identifier isEqualToString:@"ShowMapFilteringView"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didDismissMapFilteringViewController)
													 name:@"MapFilteringViewControllerDismissed"
												   object:nil];
		_btnFiltersView.alpha = 0.7;
	}
}

- (void)didDismissMapFilteringViewController {
	[UIView animateWithDuration:0.8 animations:^(void) {
		_btnFiltersView.alpha = 0.3;
	}];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"MapFilteringViewControllerDismissed"
												  object:nil];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	filtriMappa = [defaults objectForKey:@"mapFilters"];
	
	if ([filtriMappa containsObject:@"people"]) {
		[self caricaMappa:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else {
		dati_utenti_caricati = [[NSMutableDictionary alloc] init];
		id_caricati = [[NSMutableArray alloc] init];
		
		[id_caricati addObject:currentUbiUser.db_id];
		[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
		
		for (MKPointAnnotation * oldAnn in _mapView.annotations) {
			if ([oldAnn isKindOfClass:[UserMapAnnotation class]]) {
				[_mapView removeAnnotation:oldAnn];
			}
		}
	}
	
	if ([filtriMappa containsObject:@"places"]) {
		[self caricaNearbyPlaces:_mapView.region.center.latitude :_mapView.region.center.longitude];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else {
		loaded_places = [[NSMutableArray alloc] init];
		
		for (MKPointAnnotation * oldAnn in _mapView.annotations) {
			if ([oldAnn isKindOfClass:[PlaceMapAnnotation class]]) {
				[_mapView removeAnnotation:oldAnn];
			}
		}
	}
	
	if ([filtriMappa containsObject:@"events"]) {
		[self caricaEventi:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else {
		loaded_events_ids = [[NSMutableArray alloc] init];
		loaded_events_data = [[NSMutableArray alloc] init];
		
		for (MKPointAnnotation * oldAnn in _mapView.annotations) {
			if ([oldAnn isKindOfClass:[EventMapAnnotation class]]) {
				[_mapView removeAnnotation:oldAnn];
			}
		}
	}
}

- (void)placeDataReceived:(NSNotification *)notification
{
	placeDetails = notification.object;
	
	for (MKPointAnnotation * oldAnn in _mapView.annotations) {
		if ([oldAnn isKindOfClass:[PlaceAnnotation class]]) {
			[_mapView removeAnnotation:oldAnn];
		}
	}
	[_mapView removeOverlays:_mapView.overlays];
	
	if (placeDetails) {
		PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
		annotation.coordinate = CLLocationCoordinate2DMake([placeDetails.place_lat doubleValue], [placeDetails.place_lon doubleValue]);
		annotation.title = placeDetails.place_name;
		annotation.url = placeDetails.place_google_url;
		
		CLLocation * placeLocation = [[CLLocation alloc] initWithCoordinate:annotation.coordinate altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest course:0 speed:0 timestamp:0];
		
		CLLocationDistance distance = [placeLocation distanceFromLocation:locationManager.location];
		annotation.subtitle = [NSString stringWithFormat:@"Distance: %.0fm", distance];
		
		if (![_mapView.annotations containsObject:annotation]) {
			[self.mapView addAnnotation:annotation];
			
			[self.mapView selectAnnotation:annotation animated:YES];
			
			MKPlacemark *mkDest = [[MKPlacemark alloc]
								   initWithCoordinate:annotation.coordinate
								   addressDictionary:nil];
			
			MKMapItem * annItem = [[MKMapItem alloc] initWithPlacemark:mkDest];
			
			MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
			[request setSource:[MKMapItem mapItemForCurrentLocation]];
			[request setDestination:annItem];
			[request setTransportType:MKDirectionsTransportTypeAny];
			[request setRequestsAlternateRoutes:YES];
			MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
			[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
				if (!error) {
					for (MKRoute *route in [response routes]) {
						[_mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
						// You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.
					}
				}
			}];
		}
	}
}

- (void)updateCurrentUbiUserStatus:(NSNotification *)notification
{
	NSString * newStatus = notification.object;
	currentUbiUser.last_status_text = newStatus;
	[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	[_mapView setDelegate:self];
	[_mapView setShowsUserLocation:YES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	if ([viewController.title isEqualToString:@"ECSliding View"] && self.tabBarController.selectedIndex == 0) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
	if (self.slidingViewController.currentTopViewPosition == 0) {
		[self.slidingViewController resetTopViewAnimated:YES];
	}
	
	return YES;
}

#pragma mark - UITapGestureRecognizers
- (void)didTapMap
{
	[self removePopUpView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (_userCalloutAnnotation) {
		[_mapView removeAnnotation:_userCalloutAnnotation];
		[self showUserCallOutBuble:_selectedAnnotationView userMapAnnotation:_userCalloutAnnotation.userMapAnnotation];
	}
	
	if (_placeCalloutAnnotation) {
		[_mapView removeAnnotation:_placeCalloutAnnotation];
		[self showPlaceCallOutBuble:_selectedAnnotationView placeMapAnnotation:_placeCalloutAnnotation.placeMapAnnotation];
	}
	
	if (_eventCalloutAnnotation) {
		[_mapView removeAnnotation:_eventCalloutAnnotation];
		[self showEventCallOutBuble:_selectedAnnotationView eventMapAnnotation:_eventCalloutAnnotation.eventMapAnnotation];
	}
}

- (void)btnFilterViewTapDetected:(UIGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"ShowMapFilteringView" sender:self];
}

- (IBAction)showMapFilteringView:(id)sender {
    [self performSegueWithIdentifier:@"ShowMapFilteringView" sender:self];
}

- (void)btnUserLocViewTapDetected:(UIGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        _btnUserLocView.alpha = 0.7;
    });
    [self moveToUserLocation];
}

- (IBAction)showUserLocation:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        _btnUserLocView.alpha = 0.7;
    });
    [self moveToUserLocation];
}

- (void)moveToUserLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 100, 100);
    [UIView animateWithDuration:1.2f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    } completion:^(BOOL finished){
        if (finished) {
			[UIView animateWithDuration:0.8 animations:^(void) {
				_btnUserLocView.alpha = 0.3;
			}];
        }
    }];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Impostazioni"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
	
	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Chiudi"])
	{
		exit(0);
	}
}

#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	[_mapView setDelegate:self];
	[_mapView setShowsUserLocation:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// report any errors returned back from Location Services
}

#pragma mark - MKMapView delegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
		[renderer setStrokeColor:[UIColor blueColor]];
		[renderer setLineWidth:5.0];
		return renderer;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 100, 100);
		[UIView animateWithDuration:1.2f delay:0.5f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
			[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
		} completion:^(BOOL finished){
			if (finished) {
                _btnFiltersView.alpha = 0.7;
                _btnFiltersView.hidden = NO;
                
                _btnUserLocView.alpha = 0.7;
                _btnUserLocView.hidden = NO;
                
                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                if (networkStatus == NotReachable) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
					[self showNoInternetConnectionMessage];
					
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(networkDidChangeStatus:)
                                                                 name:kReachabilityChangedNotification
                                                               object:nil];
                    
                    [networkReachability startNotifier];
                }
                else
                {
                    [self inviaPosizioneUtente:userLocation.location.coordinate.latitude :userLocation.location.coordinate.longitude];
                    self.tabBarController.tabBar.userInteractionEnabled = YES;
                    _barBtnSideBar.enabled = TRUE;
                    _barBtnSearch.enabled = TRUE;
                }
			}
		}];
	});
}

- (void)networkDidChangeStatus:(NSNotification *)notice
{
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	
	if( !(networkStatus == NotReachable) )
	{
		[self inviaPosizioneUtente:locationManager.location.coordinate.latitude :locationManager.location.coordinate.longitude];
		self.tabBarController.tabBar.userInteractionEnabled = YES;
		_barBtnSideBar.enabled = TRUE;
		_barBtnSearch.enabled = TRUE;
	}
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	[UIView animateWithDuration:0.8 animations:^(void) {
		_btnFiltersView.alpha = 0.3;
		_btnUserLocView.alpha = 0.3;
	}];
    
	for (NSObject *annotation in [mapView annotations])
	{
		MKAnnotationView *view = [mapView viewForAnnotation:(MKUserLocation *)annotation];
		if ( ([annotation isKindOfClass:[_userCalloutAnnotation class]]) || (_userCalloutAnnotation.userMapAnnotation.relatedUbiUser && [view.annotation.title containsString:[NSString stringWithFormat:@"%@", self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.db_id]]) || ([annotation isKindOfClass:[_placeCalloutAnnotation class]]) || ([annotation isKindOfClass:[_eventCalloutAnnotation class]]) )
		{
			[[view superview] bringSubviewToFront:view];
		}
		else
		{
			[[view superview] sendSubviewToBack:view];
		}
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	for (NSObject *annotation in [mapView annotations])
	{
		MKAnnotationView *view = [mapView viewForAnnotation:(MKUserLocation *)annotation];
		if ( ([annotation isKindOfClass:[_userCalloutAnnotation class]]) || (_userCalloutAnnotation.userMapAnnotation.relatedUbiUser && [view.annotation.title containsString:[NSString stringWithFormat:@"%@", self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.db_id]]) || ([annotation isKindOfClass:[_placeCalloutAnnotation class]]) || ([annotation isKindOfClass:[_eventCalloutAnnotation class]]) )
		{
			[[view superview] bringSubviewToFront:view];
		}
		else
		{
			[[view superview] sendSubviewToBack:view];
		}
	}
	
    if (canRequest == YES) {
        canRequest = NO;
		if ([filtriMappa containsObject:@"people"]) {
			[self caricaMappa:mapView.region.center.latitude :mapView.region.center.longitude :mapView.region.span.latitudeDelta :mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"places"]) {
			[self caricaNearbyPlaces:mapView.region.center.latitude :mapView.region.center.longitude];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"events"]) {
			[self caricaEventi:mapView.region.center.latitude :mapView.region.center.longitude :mapView.region.span.latitudeDelta :mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if ([[view annotation] isKindOfClass:[UserMapAnnotation class]]) {
		UserMapAnnotation * userMapAnnotation = (UserMapAnnotation *)[view annotation];
		MKMapCamera * newCamera = [[_mapView camera] copy];
		if (newCamera.heading != 0.0) {
			[newCamera setHeading:0.0];
			[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
				[_mapView setCamera:newCamera animated:YES];
			} completion:^(BOOL finished){
				if (finished) {
					[self showUserCallOutBuble:view userMapAnnotation:userMapAnnotation];
				}
			}];
		}
		else
		{
			[self showUserCallOutBuble:view userMapAnnotation:userMapAnnotation];
		}
	}
	
	if ([[view annotation] isKindOfClass:[MKUserLocation class]]) {
		MKUserLocation * userLoc = [view annotation];
		UserMapAnnotation * userMapAnnotation = [[UserMapAnnotation alloc] initWithLatitude:userLoc.coordinate.latitude andLongitude:userLoc.coordinate.longitude];
		userMapAnnotation.title = [NSString stringWithFormat:@"user_%@", currentUbiUser.db_id];
		userMapAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@", currentUbiUser.name, currentUbiUser.surname];
		userMapAnnotation.relatedUbiUser = currentUbiUser;
		MKMapCamera * newCamera = [[_mapView camera] copy];
		if (newCamera.heading != 0.0) {
			[newCamera setHeading:0.0];
			[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
				[_mapView setCamera:newCamera animated:YES];
			} completion:^(BOOL finished){
				if (finished) {
					[self showUserCallOutBuble:view userMapAnnotation:userMapAnnotation];
				}
			}];
		}
		else
		{
			[self showUserCallOutBuble:view userMapAnnotation:userMapAnnotation];
		}
	}
	
	if ([[view annotation] isKindOfClass:[PlaceMapAnnotation class]]) {
		PlaceMapAnnotation * placeMapAnnotation = (PlaceMapAnnotation *)[view annotation];
		MKMapCamera * newCamera = [[_mapView camera] copy];
		if (newCamera.heading != 0.0) {
			[newCamera setHeading:0.0];
			[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
				[_mapView setCamera:newCamera animated:YES];
			} completion:^(BOOL finished){
				if (finished) {
					[self showPlaceCallOutBuble:view placeMapAnnotation:placeMapAnnotation];
				}
			}];
		}
		else
		{
			[self showPlaceCallOutBuble:view placeMapAnnotation:placeMapAnnotation];
		}
	}
	
	if ([[view annotation] isKindOfClass:[EventMapAnnotation class]]) {
		EventMapAnnotation * eventMapAnnotation = (EventMapAnnotation *)[view annotation];
		MKMapCamera * newCamera = [[_mapView camera] copy];
		if (newCamera.heading != 0.0) {
			[newCamera setHeading:0.0];
			[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState) animations:^{
				[_mapView setCamera:newCamera animated:YES];
			} completion:^(BOOL finished){
				if (finished) {
					[self showEventCallOutBuble:view eventMapAnnotation:eventMapAnnotation];
				}
			}];
		}
		else
		{
			[self showEventCallOutBuble:view eventMapAnnotation:eventMapAnnotation];
		}
	}
}

- (void)showUserCallOutBuble:(MKAnnotationView *)view userMapAnnotation:(UserMapAnnotation *)userMapAnnotation
{
	CLLocationCoordinate2D calloutAnnotationCoordinates;
	
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationPortrait) {
            calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude);
        }
        else {
            calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude + (_mapView.region.span.longitudeDelta / 30));
        }
    }
    else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationPortrait) {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 44), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 9));
        }
        else {
            calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 21), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 17));
        }
    }
					
	_userCalloutAnnotation = [[UserCalloutMapAnnotation alloc] initWithLatitude:calloutAnnotationCoordinates.latitude
																   andLongitude:calloutAnnotationCoordinates.longitude];
	_userCalloutAnnotation.title = [view.annotation title];
	
	_userCalloutAnnotation.userMapAnnotation = userMapAnnotation;
	
	if ([[view annotation] isKindOfClass:[MKUserLocation class]]) {
		_userCalloutAnnotation.title = [NSString stringWithFormat:@"%@", currentUbiUser.db_id];
	}
	
	[_mapView addAnnotation:_userCalloutAnnotation];
	_selectedAnnotationView = view;
}

- (void)showPlaceCallOutBuble:(MKAnnotationView *)view placeMapAnnotation:(PlaceMapAnnotation *)placeMapAnnotation
{
	CLLocationCoordinate2D calloutAnnotationCoordinates;
	
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if(orientation == UIInterfaceOrientationPortrait) {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude);
		}
		else {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude + (_mapView.region.span.longitudeDelta / 30));
		}
	}
	else {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if(orientation == UIInterfaceOrientationPortrait) {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 44), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 9));
		}
		else {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 21), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 17));
		}
	}
	
	_placeCalloutAnnotation = [[PlaceCalloutMapAnnotation alloc] initWithLatitude:calloutAnnotationCoordinates.latitude
																	 andLongitude:calloutAnnotationCoordinates.longitude];
	_placeCalloutAnnotation.title = [view.annotation title];
	
	_placeCalloutAnnotation.placeMapAnnotation = placeMapAnnotation;
	
	[_mapView addAnnotation:_placeCalloutAnnotation];
	_selectedAnnotationView = view;
}

- (void)showEventCallOutBuble:(MKAnnotationView *)view eventMapAnnotation:(EventMapAnnotation *)eventMapAnnotation
{
	CLLocationCoordinate2D calloutAnnotationCoordinates;
	
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if(orientation == UIInterfaceOrientationPortrait) {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude);
		}
		else {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 110), view.annotation.coordinate.longitude + (_mapView.region.span.longitudeDelta / 30));
		}
	}
	else {
		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
		if(orientation == UIInterfaceOrientationPortrait) {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 44), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 9));
		}
		else {
			calloutAnnotationCoordinates = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude - (_mapView.region.span.latitudeDelta / 21), view.annotation.coordinate.longitude - (_mapView.region.span.longitudeDelta / 17));
		}
	}
	
	_eventCalloutAnnotation = [[EventCalloutMapAnnotation alloc] initWithLatitude:calloutAnnotationCoordinates.latitude
																	 andLongitude:calloutAnnotationCoordinates.longitude];
	_eventCalloutAnnotation.title = [view.annotation title];
	
	_eventCalloutAnnotation.eventMapAnnotation = eventMapAnnotation;
	
	[_mapView addAnnotation:_eventCalloutAnnotation];
	_selectedAnnotationView = view;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	[self removePopUpView];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
	for (MKAnnotationView *annView in annotationViews)
	{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if ([[annView annotation] isKindOfClass:[MKUserLocation class]]) {
                CGRect endFrame = annView.frame;
                annView.frame = CGRectOffset(endFrame, 0, -500);
                [UIView animateWithDuration:0.7
                                 animations:^{ annView.frame = endFrame; }];
            }
        });
        
        if ( !( ([[annView annotation] isKindOfClass:[_userCalloutAnnotation class]]) || ([[annView annotation] isKindOfClass:[self.placeCalloutAnnotation class]]) || ([[annView annotation] isKindOfClass:[_eventCalloutAnnotation class]]) || ([[annView annotation] isKindOfClass:[PlaceAnnotation class]]) || ([[annView annotation] isKindOfClass:[MKUserLocation class]]) ) )
        {
            [annView setAlpha:0.0f];
            [UIView animateWithDuration:2.0f animations:^{
                [annView setAlpha:1.0f];
            } completion:^(BOOL finished) {
                
            }];
        }
		
		if ( ([[annView annotation] isKindOfClass:[_userCalloutAnnotation class]]) ||
            (_userCalloutAnnotation.userMapAnnotation.relatedUbiUser && [annView.annotation.title containsString:[NSString stringWithFormat:@"%@", _userCalloutAnnotation.userMapAnnotation.relatedUbiUser.db_id]]) || ([[annView annotation] isKindOfClass:[_placeCalloutAnnotation class]]) || ([[annView annotation] isKindOfClass:[_eventCalloutAnnotation class]]) ) {
			[[annView superview] bringSubviewToFront:annView];
		}
		else {
			[[annView superview] sendSubviewToBack:annView];
		}
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation == _userCalloutAnnotation)
	{
		UserCalloutMapAnnotationView *userCalloutMapAnnotationView = [[UserCalloutMapAnnotationView alloc] initWithAnnotation:annotation
																										  reuseIdentifier:@"UserCalloutAnnotation"];
		userCalloutMapAnnotationView.contentHeight = 155.0f;
        
        [userCalloutMapAnnotationView initProfilePicView:_userCalloutAnnotation.userMapAnnotation.relatedUbiUser];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDetailsTapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [userCalloutMapAnnotationView.profilePicView setUserInteractionEnabled:YES];
        [userCalloutMapAnnotationView.profilePicView addGestureRecognizer:singleTap];
        
        int coordY = [userCalloutMapAnnotationView initLabels:_userCalloutAnnotation.userMapAnnotation.relatedUbiUser :self.view.frame.size];
		
        [userCalloutMapAnnotationView initSocialLogo:coordY :[[NSString alloc] initWithFormat:@"%@", [_userCalloutAnnotation.userMapAnnotation.relatedUbiUser.profile_url absoluteString]]];
        
        UITapGestureRecognizer *singleTapSocial = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialTapDetected)];
        singleTapSocial.numberOfTapsRequired = 1;
        [userCalloutMapAnnotationView.SocialLogoView setUserInteractionEnabled:YES];
        [userCalloutMapAnnotationView.SocialLogoView addGestureRecognizer:singleTapSocial];
        
        if ( ![_userCalloutAnnotation.userMapAnnotation.relatedUbiUser.db_id isEqualToNumber:currentUbiUser.db_id] )
        {
            [userCalloutMapAnnotationView initAddFriend:coordY];
            UITapGestureRecognizer *singleTapAddFriend = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendTapDetected)];
            singleTapAddFriend.numberOfTapsRequired = 1;
            [userCalloutMapAnnotationView.addFriendLogoView setUserInteractionEnabled:YES];
            [userCalloutMapAnnotationView.addFriendLogoView addGestureRecognizer:singleTapAddFriend];
            
            [userCalloutMapAnnotationView initSendMessage:coordY];
            UITapGestureRecognizer *singleTapSendMessage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendMessageTapDetected)];
            singleTapSendMessage.numberOfTapsRequired = 1;
            [userCalloutMapAnnotationView.sendMessageLogoView setUserInteractionEnabled:YES];
            [userCalloutMapAnnotationView.sendMessageLogoView addGestureRecognizer:singleTapSendMessage];
            
            [userCalloutMapAnnotationView initBuzz:coordY];
            UITapGestureRecognizer *singleTapBuzz = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buzzTapDetected)];
            singleTapBuzz.numberOfTapsRequired = 1;
            [userCalloutMapAnnotationView.buzzLogoView setUserInteractionEnabled:YES];
            [userCalloutMapAnnotationView.buzzLogoView addGestureRecognizer:singleTapBuzz];
        }
        
        [userCalloutMapAnnotationView initLblDistance:_userCalloutAnnotation.userMapAnnotation.relatedUbiUser.distance :self.view.frame.size];
        
		userCalloutMapAnnotationView.parentAnnotationView = self.selectedAnnotationView;
		userCalloutMapAnnotationView.mapView = self.mapView;
		
		return userCalloutMapAnnotationView;
	}
	else if (annotation == _placeCalloutAnnotation)
	{
		PlaceCalloutMapAnnotationView *placeCalloutMapAnnotationView = [[PlaceCalloutMapAnnotationView alloc] initWithAnnotation:annotation
																												 reuseIdentifier:@"PlaceCalloutAnnotation"];
		placeCalloutMapAnnotationView.contentHeight = 155.0f;
		
		[placeCalloutMapAnnotationView initProfilePicView:_placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace];
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeDetailsTapDetected)];
		singleTap.numberOfTapsRequired = 1;
		[placeCalloutMapAnnotationView.profilePicView setUserInteractionEnabled:YES];
		[placeCalloutMapAnnotationView.profilePicView addGestureRecognizer:singleTap];
		
		int coordY = [placeCalloutMapAnnotationView initLabels:_placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace :self.view.frame.size];

		[placeCalloutMapAnnotationView initSocialLogo:coordY :[[NSString alloc] initWithFormat:@"%@", [_placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace.place_google_url absoluteString]]];
		
		UITapGestureRecognizer *singleTapSocial = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialTapDetected)];
		singleTapSocial.numberOfTapsRequired = 1;
		[placeCalloutMapAnnotationView.SocialLogoView setUserInteractionEnabled:YES];
		[placeCalloutMapAnnotationView.SocialLogoView addGestureRecognizer:singleTapSocial];
		
		[placeCalloutMapAnnotationView initLblDistance:_placeCalloutAnnotation.placeMapAnnotation.relatedUbiPlace.place_distance :self.view.frame.size];
		
		placeCalloutMapAnnotationView.parentAnnotationView = self.selectedAnnotationView;
		placeCalloutMapAnnotationView.mapView = self.mapView;
		
		return placeCalloutMapAnnotationView;
	}
	else if (annotation == _eventCalloutAnnotation)
	{
		EventCalloutMapAnnotationView *eventCalloutMapAnnotationView = [[EventCalloutMapAnnotationView alloc] initWithAnnotation:annotation
																											reuseIdentifier:@"EventCalloutAnnotation"];
		eventCalloutMapAnnotationView.contentHeight = 155.0f;
		
		[eventCalloutMapAnnotationView initProfilePicView:_eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent];
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventDetailsTapDetected)];
		singleTap.numberOfTapsRequired = 1;
		[eventCalloutMapAnnotationView.profilePicView setUserInteractionEnabled:YES];
		[eventCalloutMapAnnotationView.profilePicView addGestureRecognizer:singleTap];
		
		int coordY = [eventCalloutMapAnnotationView initLabels:_eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent :self.view.frame.size];
		
		[eventCalloutMapAnnotationView initSocialLogo:coordY :[[NSString alloc] initWithFormat:@"%@", [_eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent.event_website_url absoluteString]]];
		
		UITapGestureRecognizer *singleTapSocial = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialTapDetected)];
		singleTapSocial.numberOfTapsRequired = 1;
		[eventCalloutMapAnnotationView.SocialLogoView setUserInteractionEnabled:YES];
		[eventCalloutMapAnnotationView.SocialLogoView addGestureRecognizer:singleTapSocial];
		
		[eventCalloutMapAnnotationView initLblDistance:_eventCalloutAnnotation.eventMapAnnotation.relatedUbiEvent.relatedUbiPlace.place_distance :self.view.frame.size];
		
		eventCalloutMapAnnotationView.parentAnnotationView = self.selectedAnnotationView;
		eventCalloutMapAnnotationView.mapView = self.mapView;
		
		return eventCalloutMapAnnotationView;
	}
	else
	{
		if ([annotation isKindOfClass:[MKUserLocation class]])
		{
			MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"current_user_%@", currentUbiUser.db_id]];
			if(annotationView)
				return annotationView;
			else
			{
				annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"current_user_%@", currentUbiUser.db_id]];
				[annotationView setFrame:CGRectMake(0, 0, 70, 70)];
                annotationView.enabled = YES;
                
                UIImageView * imageViewPinBorder = [self mapMarkerBorder:[UIColor greenColor] :annotationView];
                [annotationView addSubview:imageViewPinBorder];
				
				UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userIcon"]];
				CGSize newSize = CGSizeMake(61, 61);
				imageView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
				
				[imageView sd_setImageWithURL:currentUbiUser.profile_pic
							 placeholderImage:[UIImage imageNamed:@""]];
				
				[imageView setContentMode:UIViewContentModeScaleToFill];
				imageView.layer.cornerRadius = (imageView.frame.size.width/2);
				imageView.clipsToBounds = YES;
				imageView.center = annotationView.center;
                [annotationView addSubview:imageView];
				
				return annotationView;
			}
		}
		else
		{
			if ([annotation isKindOfClass:[UserMapAnnotation class]])
			{
				MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[annotation title]];
				if(annotationView)
					return annotationView;
				else
				{
					UserMapAnnotation * newUbiUserAnnotation = (UserMapAnnotation *)annotation;
					
					annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
					[annotationView setFrame:CGRectMake(0, 0, 70, 70)];
                    annotationView.enabled = YES;
                    
                    UIImageView * imageViewPinBorder = [self mapMarkerBorder:[UIColor blueColor] :annotationView];
                    [annotationView addSubview:imageViewPinBorder];
					
					UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userIcon"]];
					CGSize newSize = CGSizeMake(60, 60);
					imageView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
					
					[imageView sd_setImageWithURL:newUbiUserAnnotation.relatedUbiUser.profile_pic
								 placeholderImage:[UIImage imageNamed:@""]];
					
					[imageView setContentMode:UIViewContentModeScaleToFill];
					imageView.layer.cornerRadius = (imageView.frame.size.width/2);
					imageView.clipsToBounds = YES;
					imageView.center = annotationView.center;
					[annotationView addSubview:imageView];
					
					annotationView.canShowCallout = NO;
					
					return annotationView;
				}
			}
			else if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
				MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"placeDetailAnn"];
				annotationView.canShowCallout = YES;
				annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
				annotationView.leftCalloutAccessoryView.tag = 0;
				
				UIButton *removeButton = [[UIButton  alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
				[removeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
				[removeButton setSelected:NO];
				annotationView.rightCalloutAccessoryView = removeButton;
				annotationView.rightCalloutAccessoryView.tag = 1;
				
				return annotationView;
			}
			else if ([annotation isKindOfClass:[PlaceMapAnnotation class]]) {
				MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[annotation title]];
				if(annotationView)
					return annotationView;
				else
				{
					PlaceMapAnnotation * newPlaceAnnotation = (PlaceMapAnnotation *)annotation;
					
					annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
					[annotationView setFrame:CGRectMake(0, 0, 55, 73)];
					annotationView.enabled = YES;
					
					UIImageView * imageViewPinBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place_marker"]];
					CGSize newSize = CGSizeMake(55, 73);
					imageViewPinBorder.frame = CGRectMake(0, 0, newSize.width, newSize.height);
					imageViewPinBorder.layer.cornerRadius = (imageViewPinBorder.frame.size.width/2);
					imageViewPinBorder.clipsToBounds = YES;
					imageViewPinBorder.center = annotationView.center;
					[annotationView addSubview:imageViewPinBorder];
					
					UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
					newSize = CGSizeMake(41, 41);
					imageView.frame = CGRectMake(7, 7, newSize.width, newSize.height);
					
					[imageView sd_setImageWithURL:newPlaceAnnotation.relatedUbiPlace.place_icon_url
								 placeholderImage:[UIImage imageNamed:@""]];
					
					[imageView setContentMode:UIViewContentModeScaleToFill];
					imageView.layer.cornerRadius = (imageView.frame.size.width/2);
					imageView.clipsToBounds = YES;
					[annotationView addSubview:imageView];
					
					annotationView.canShowCallout = NO;
					
					return annotationView;
				}
			}
			else if ([annotation isKindOfClass:[EventMapAnnotation class]]) {
				MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:[annotation title]];
				if(annotationView)
					return annotationView;
				else
				{
					EventMapAnnotation * newEventMapAnnotation = (EventMapAnnotation *)annotation;
					
					annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
					[annotationView setFrame:CGRectMake(0, 0, 55, 73)];
					annotationView.enabled = YES;
					
					UIImageView * imageViewPinBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"event_marker"]];
					CGSize newSize = CGSizeMake(55, 73);
					imageViewPinBorder.frame = CGRectMake(0, 0, newSize.width, newSize.height);
					imageViewPinBorder.layer.cornerRadius = (imageViewPinBorder.frame.size.width/2);
					imageViewPinBorder.clipsToBounds = YES;
					imageViewPinBorder.center = annotationView.center;
					[annotationView addSubview:imageViewPinBorder];
					
					UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
					newSize = CGSizeMake(47, 47);
					imageView.frame = CGRectMake(4, 4, newSize.width, newSize.height);
					
					[imageView sd_setImageWithURL:newEventMapAnnotation.relatedUbiEvent.event_picture_url
								 placeholderImage:[UIImage imageNamed:@""]];
					
					[imageView setContentMode:UIViewContentModeScaleToFill];
					imageView.layer.cornerRadius = (imageView.frame.size.width/2);
					imageView.clipsToBounds = YES;
					[annotationView addSubview:imageView];
					
					annotationView.canShowCallout = NO;
					
					return annotationView;
				}
			}
		}
	}
	
	return nil;
}

- (UIImageView *)mapMarkerBorder:(UIColor *)borderColor :(MKAnnotationView *)annotationView {
    UIImageView * imageViewPinBorder = [[UIImageView alloc] initWithImage:nil];
    CGSize newSize = CGSizeMake(67, 67);
    imageViewPinBorder.frame = CGRectMake(0, 0, newSize.width, newSize.height);
    imageViewPinBorder.layer.cornerRadius = (imageViewPinBorder.frame.size.width/2);
    imageViewPinBorder.clipsToBounds = YES;
    imageViewPinBorder.layer.borderColor = [borderColor CGColor];
    imageViewPinBorder.layer.borderWidth = 1;
    imageViewPinBorder.backgroundColor = [UIColor whiteColor];
    imageViewPinBorder.center = annotationView.center;
    
    return imageViewPinBorder;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (control.tag == 0) {
        [self performSegueWithIdentifier:@"ShowWebviewView" sender:self];
    }
	else if (control.tag == 1)
	{
		[_mapView removeAnnotation:[view annotation]];
		[_mapView removeOverlays:_mapView.overlays];
	}
}

- (void)buzzTapDetected
{
	// Create our Installation query
	PFQuery *pushQuery = [PFInstallation query];
	[pushQuery whereKey:@"User_DB_ID" equalTo:_userCalloutAnnotation.userMapAnnotation.relatedUbiUser.db_id];
 
	// Send push notification to query
	[PFPush sendPushMessageToQueryInBackground:pushQuery
								   withMessage:[NSString stringWithFormat:@"%@ %@ ti ha inviato un BUZZ!", currentUbiUser.name, currentUbiUser.surname]];
	
    [self removePopUpView];
}

- (void)sendMessageTapDetected
{
    QBChatDialog *chatDialog = [QBChatDialog new];

    chatDialog.occupantIDs = [[NSArray alloc] initWithObjects:self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.chat_id, nil];
    
    chatDialog.name = [[NSString alloc] initWithFormat:@"%@ %@", self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.name, self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.surname];
    chatDialogName = [[NSString alloc] initWithFormat:@"%@ %@", self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.name, self.userCalloutAnnotation.userMapAnnotation.relatedUbiUser.surname];
    chatDialog.type = QBChatDialogTypePrivate;
    
    UINavigationController * navController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    ThirdViewController *dialogsViewController = (ThirdViewController *)[navController.viewControllers objectAtIndex:0];
    dialogsViewController.createdChat = chatDialog;
    [self.tabBarController setSelectedIndex:2];
    
    [self removePopUpView];
}

- (void)addFriendTapDetected
{
    [self showErrorMessage:@"ADD FRIEND ADD FRIEND"];
    [self removePopUpView];
}

- (void)userDetailsTapDetected
{
    [self performSegueWithIdentifier:@"ShowUserDetailsView" sender:nil];
}

- (void)placeDetailsTapDetected
{
	[self performSegueWithIdentifier:@"ShowPlaceDetailsView" sender:nil];
}

- (void)eventDetailsTapDetected
{
	[self performSegueWithIdentifier:@"ShowEventDetailsView" sender:nil];
}

- (void)socialTapDetected
{
    [self performSegueWithIdentifier:@"ShowWebviewView" sender:nil];
}

- (void)removePopUpView
{
	_selectedAnnotationView = [[MKAnnotationView alloc] init];
	
    if (_userCalloutAnnotation && [_mapView.annotations containsObject:_userCalloutAnnotation]) {
		[_mapView removeAnnotation:_userCalloutAnnotation];
		_userCalloutAnnotation = nil;
		
		NSArray *selectedAnnotations = _mapView.selectedAnnotations;
		for (UserMapAnnotation *userMapAnn in selectedAnnotations) {
			[_mapView deselectAnnotation:userMapAnn animated:YES];
		}
    }
	
	if (_placeCalloutAnnotation && [_mapView.annotations containsObject:_placeCalloutAnnotation]) {
		[_mapView removeAnnotation:_placeCalloutAnnotation];
		_placeCalloutAnnotation = nil;
		
		NSArray *selectedAnnotations = _mapView.selectedAnnotations;
		for (PlaceMapAnnotation *placeMapAnn in selectedAnnotations) {
			[_mapView deselectAnnotation:placeMapAnn animated:YES];
		}
	}
	
	if (_eventCalloutAnnotation && [_mapView.annotations containsObject:_eventCalloutAnnotation]) {
		[_mapView removeAnnotation:_eventCalloutAnnotation];
		_eventCalloutAnnotation = nil;
		
		NSArray *selectedAnnotations = _mapView.selectedAnnotations;
		for (EventMapAnnotation *eventMapAnn in selectedAnnotations) {
			[_mapView deselectAnnotation:eventMapAnn animated:YES];
		}
	}
}

- (void)inviaPosizioneUtente:(float)latitudine :(float)longitudine
{
	if ([currentUbiUser updateUserLocationToDB:latitudine :longitudine]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		filtriMappa = [defaults objectForKey:@"mapFilters"];
		
		if ([filtriMappa containsObject:@"people"]) {
			[self caricaMappa:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"places"]) {
			[self caricaNearbyPlaces:_mapView.region.center.latitude :_mapView.region.center.longitude];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"events"]) {
			[self caricaEventi:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
        
		[NSTimer scheduledTimerWithTimeInterval:4.0
										 target:self
									   selector:@selector(onTickCanRequest)
									   userInfo:nil
										repeats:YES];
		
		[NSTimer scheduledTimerWithTimeInterval:900.0
										 target:self
									   selector:@selector(onTickUpdateUserLocation)
									   userInfo:nil
										repeats:YES];
	}
}

- (void)onTickCanRequest
{
	canRequest = YES;
}

- (void)onTickUpdateUserLocation
{
	if ([currentUbiUser updateUserLocationToDB:locationManager.location.coordinate.latitude :locationManager.location.coordinate.longitude]) {
		dati_utenti_caricati = [[NSMutableDictionary alloc] init];
		id_caricati = [[NSMutableArray alloc] init];
		
		[id_caricati addObject:currentUbiUser.db_id];
		[dati_utenti_caricati setObject:currentUbiUser forKey:currentUbiUser.db_id];
		
		refreshUserData = YES;

		if ([filtriMappa containsObject:@"people"]) {
			[self caricaMappa:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"places"]) {
			[self caricaNearbyPlaces:_mapView.region.center.latitude :_mapView.region.center.longitude];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
		
		if ([filtriMappa containsObject:@"events"]) {
			[self caricaEventi:_mapView.region.center.latitude :_mapView.region.center.longitude :_mapView.region.span.latitudeDelta :_mapView.region.span.longitudeDelta];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
	}
}

- (void)caricaMappa:(float)latitudine :(float)longitudine :(float)latDelta :(float)longDelta
{
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
        [[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                    message:@"The internet connection appears to be offline."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
	}
	else
	{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *params = @{@"lat": [NSNumber numberWithFloat:latitudine],
                                 @"lon": [NSNumber numberWithFloat:longitudine],
                                 @"latdelta": [NSNumber numberWithFloat:latDelta],
                                 @"londelta": [NSNumber numberWithFloat:longDelta]};
        
        [manager POST:[NSString stringWithFormat:@"%@/read_map.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            canRequest = NO;
            
            NSError *error;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				if (refreshUserData) {
					refreshUserData = NO;
					for (MKPointAnnotation * oldAnn in _mapView.annotations) {
						if ([oldAnn isKindOfClass:[UserMapAnnotation class]]) {
							[_mapView removeAnnotation:oldAnn];
						}
					}
				}
				
				for (NSDictionary *tempDictionary in jsonArray) {
					canRequest = NO;
					
					NSNumber * user_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_id"] description] intValue]];
					
					if (![user_id isEqualToNumber:currentUbiUser.db_id])
					{
						if (![id_caricati containsObject:user_id])
						{
							double lat_id = [[[tempDictionary objectForKey:@"user_lat"] description] floatValue];
							double long_id = [[[tempDictionary objectForKey:@"user_lon"] description] floatValue];
							
							CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
							CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
							
							UbiUser * newUbiUser = [[UbiUser alloc] initWithParametersUserID:user_id
																					 chat_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"user_chat_id"] description] intValue]]
																					   email:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_email"] description]]
																						name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_name"] description]]
																					 surname:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_surname"] description]]
																				 profile_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_pic"] description]]]
																				 profile_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_profile_url"] description]]]
																			last_status_text:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"status_content_text"] description]]
																						 bio:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_bio"] description]]
																					birthday:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_birthday"] description]]
																					  gender:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_gender"] description]]
																					latitude:[NSNumber numberWithFloat:lat_id]
																				   longitude:[NSNumber numberWithFloat:long_id]
																				 last_access:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"user_lastaccess"] description]]
																					distance:[NSNumber numberWithFloat:distance]];
							
							UserMapAnnotation * newUserAnnotation = [[UserMapAnnotation alloc] initWithLatitude:lat_id andLongitude:long_id];
							newUserAnnotation.title = [NSString stringWithFormat:@"user_%@", newUbiUser.db_id];
							newUserAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@", newUbiUser.name, newUbiUser.surname];
							newUserAnnotation.relatedUbiUser = newUbiUser;
							
							[self.mapView addAnnotation:newUserAnnotation];
							[dati_utenti_caricati setObject:newUbiUser forKey:user_id];
							[id_caricati addObject:user_id];
						}
					}
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dati_utenti_caricati];
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:data forKey:@"dati_utenti_caricati"];
                [defaults setObject:id_caricati forKey:@"id_caricati"];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
        }];
	}
}

- (void)caricaNearbyPlaces:(float)latitudine :(float)longitudine
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray * placesTypesArray = [defaults objectForKey:@"mapPlacesFilters"];
	NSString * placesTypesArrayToString = [placesTypesArray componentsJoinedByString:@"|"];
	
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
									message:@"The internet connection appears to be offline."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
	else
	{
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		NSDictionary *params = @{@"location": [NSString stringWithFormat:@"%f,%f", latitudine, longitudine],
								 @"place_types": placesTypesArrayToString};
		
		[manager POST:[NSString stringWithFormat:@"%@/radar_search.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			canRequest = NO;
			
			NSError *error;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					canRequest = NO;
					
					NSNumber * place_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"place_id"] description] intValue]];
					
					if (![loaded_places containsObject:place_id])
					{
						double lat_id = [[[tempDictionary objectForKey:@"place_lat"] description] floatValue];
						double long_id = [[[tempDictionary objectForKey:@"place_lon"] description] floatValue];
						
						CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
						CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
						
						UbiPlace * newUbiPlace = [[UbiPlace alloc] initWithParameters_db_id:place_id
																				 place_name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_name"] description]]
																				  place_lat:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lat"] description] floatValue]]
																				  place_lon:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lon"] description] floatValue]]
																			 place_icon_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_icon_url"] description]]]
																			   place_string:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_string"] description]]
																			place_google_id:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_id"] description]]
																			   place_rating:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_rating"] description] floatValue]]
																				place_types:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_types"] description]]
																		  place_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_website_url"] description]]]
																		 place_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_phone_number"] description]]
																	 place_int_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_int_phone_number"] description]]
																		   place_utc_offset:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"place_utc_offset"] description] floatValue]]
																		   place_google_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_url"] description]]]
																			place_cover_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_cover_pic_url"] description]]]
																			 place_distance:[NSNumber numberWithFloat:distance]];
						
						PlaceMapAnnotation * newPlaceAnnotation = [[PlaceMapAnnotation alloc] initWithLatitude:[newUbiPlace.place_lat floatValue] andLongitude:[newUbiPlace.place_lon floatValue]];
						newPlaceAnnotation.title = [NSString stringWithFormat:@"place_%@", newUbiPlace.db_id];
						newPlaceAnnotation.subtitle = [NSString stringWithFormat:@"%@", newUbiPlace.place_name];
						newPlaceAnnotation.relatedUbiPlace = newUbiPlace;
						
						[self.mapView addAnnotation:newPlaceAnnotation];
						[loaded_places addObject:newUbiPlace.db_id];
					}
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
		}];
	}
}

- (void)caricaEventi:(float)latitudine :(float)longitudine :(float)latDelta :(float)longDelta
{
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
									message:@"The internet connection appears to be offline."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
	else
	{
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFHTTPResponseSerializer serializer];
		NSDictionary *params = @{@"lat": [NSNumber numberWithFloat:latitudine],
								 @"lon": [NSNumber numberWithFloat:longitudine],
								 @"latdelta": [NSNumber numberWithFloat:latDelta],
								 @"londelta": [NSNumber numberWithFloat:longDelta]};
		
		[manager POST:[NSString stringWithFormat:@"%@/read_events.php", BASE_URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			canRequest = NO;
			
			NSError *error;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
			
			if (!error) {
				for (NSDictionary *tempDictionary in jsonArray) {
					canRequest = NO;
					
					NSNumber * event_id = [NSNumber numberWithInt:[[[tempDictionary objectForKey:@"event_id"] description] intValue]];
					
					if (![loaded_events_ids containsObject:event_id])
					{
						double lat_id = [[[tempDictionary objectForKey:@"place_lat"] description] floatValue];
						double long_id = [[[tempDictionary objectForKey:@"place_lon"] description] floatValue];
						
						CLLocation * location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat_id, long_id) altitude:0 horizontalAccuracy:kCLLocationAccuracyBest verticalAccuracy:kCLLocationAccuracyBest timestamp:nil];
						CLLocationDistance distance = [location distanceFromLocation:locationManager.location];
						
						UbiPlace * newUbiPlace = [[UbiPlace alloc] initWithParameters_db_id:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_id"] description] floatValue]]
																				 place_name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_name"] description]]
																				  place_lat:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lat"] description] floatValue]]
																				  place_lon:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_lon"] description] floatValue]]
																			 place_icon_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_icon_url"] description]]]
																			   place_string:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_string"] description]]
																			place_google_id:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_id"] description]]
																			   place_rating:[NSNumber numberWithFloat:[[[tempDictionary objectForKey:@"place_rating"] description] floatValue]]
																				place_types:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_types"] description]]
																		  place_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_website_url"] description]]]
																		 place_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_phone_number"] description]]
																	 place_int_phone_number:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_int_phone_number"] description]]
																		   place_utc_offset:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"place_utc_offset"] description] floatValue]]
																		   place_google_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_google_url"] description]]]
																			place_cover_pic:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"place_cover_pic_url"] description]]]
																			 place_distance:[NSNumber numberWithFloat:distance]];
						
						UbiEvent * newUbiEvent = [[UbiEvent alloc] initWithParametersEventID:event_id
																			 event_author_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"event_author_id"] description] intValue]]
																				  event_name:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_description"] description]]
																		   event_picture_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_picture_url"] description]]]
																		   event_description:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_description"] description]]
																			  event_place_id:[NSNumber numberWithInt:[[[tempDictionary objectForKey:@"event_place_id"] description] intValue]]
																			event_start_date:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_start_date"] description]]
																			  event_end_date:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_end_date"] description]]
																				  event_type:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_type"] description]]
																		   event_website_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_website_url"] description]]]
																	 event_facebook_page_url:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[tempDictionary objectForKey:@"event_facebook_page_url"] description]]]
																	  event_participants_ids:[[NSMutableArray alloc] init]
																			 relatedUbiPlace:newUbiPlace];
						
						EventMapAnnotation * newEventMapAnnotation = [[EventMapAnnotation alloc] initWithLatitude:[newUbiPlace.place_lat floatValue] andLongitude:[newUbiPlace.place_lon floatValue]];
						newEventMapAnnotation.title = [NSString stringWithFormat:@"event_%@", newUbiEvent.db_id];
						newEventMapAnnotation.subtitle = [NSString stringWithFormat:@"%@", newUbiPlace.place_name];
						newEventMapAnnotation.relatedUbiEvent = newUbiEvent;
						
						[self.mapView addAnnotation:newEventMapAnnotation];
						[loaded_events_ids addObject:newUbiEvent.db_id];
						[loaded_events_data addObject:newUbiEvent];
					}
				}
			}
			else
			{
				[self showErrorMessage:error.description];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			});
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self showErrorMessage:error.description];
		}];
	}
}

- (void)showErrorMessage:(NSString *)message {
	NSLog(@"Something went wrong. Please retry. Message: %@", message);
}

- (void)showNoInternetConnectionMessage {
	[[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
								message:@"The internet connection appears to be offline."
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

@end
