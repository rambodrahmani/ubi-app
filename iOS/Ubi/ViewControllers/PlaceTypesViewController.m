//
//  PlaceTypesViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 19/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import "PlaceTypesViewController.h"

@interface PlaceTypesViewController ()

@end

@implementation PlaceTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	googleApiPlaces = [[NSArray alloc] initWithObjects:@"Accounting", @"Airport", @"Amusement Park", @"Aquarium", @"Art Gallery", @"ATM", @"Bakery", @"Bank", @"Bar", @"Beauty Salon", @"Bicycle Store", @"Bbook Store", @"Bowling Alley", @"Bus Station", @"Cafe", @"Campground", @"Car Dealer", @"Car Rental", @"Car Repair", @"Car Wash", @"Casino", @"Cemetery", @"Church", @"City Hall", @"Clothing Store", @"Convenience Store", @"Courthouse", @"Dentist", @"Department Store", @"Doctor", @"Electrician", @"Electronics Store", @"Embassy", @"Establishment", @"Finance", @"Fire Station", @"Florist", @"Food", @"Funeral Home", @"Furniture Store", @"Gas Station", @"General Contractor", @"Grocery Or Supermarket", @"Gym", @"Hair Care", @"Hardware Store", @"Health", @"Hindu Temple", @"Home Goods Store", @"Hospital", @"Insurance Agency", @"Jewelry Store", @"Laundry", @"Lawyer", @"Library", @"Liquor Store", @"Local Government Office", @"Locksmith", @"Lodging", @"Meal Delivery", @"Meal Takeaway", @"Mosque", @"Movie Rental", @"Movie Theater", @"Moving Company", @"Museum", @"Night Club", @"Painter", @"Park", @"Parking", @"Pet Store", @"Pharmacy", @"Physiotherapist", @"Place Of Worship", @"Plumber", @"Police", @"Post Office", @"Real Estate Agency", @"Restaurant", @"Roofing Contractor", @"RV Park", @"School", @"Shoe Store", @"Shopping Mall", @"SPA", @"Stadium", @"Storage", @"Store", @"Subway Station", @"Synagogue", @"Taxi Stand", @"Train Station", @"Travel Agency", @"University", @"Veterinary Care", @"Zoo", nil];
	
	googleApiPlaces_types = [[NSArray alloc] initWithObjects:@"accounting", @"airport", @"amusement_park", @"aquarium", @"art_gallery", @"atm", @"bakery", @"bank", @"bar", @"beauty_salon", @"bicycle_store", @"book_store", @"bowling_alley", @"bus_station", @"cafe", @"campground", @"car_dealer", @"car_rental", @"car_repair", @"car_wash", @"casino", @"cemetery", @"church", @"city_hall", @"clothing_store", @"convenience_store", @"courthouse", @"dentist", @"department_store", @"doctor", @"electrician", @"electronics_store", @"embassy", @"establishment", @"finance", @"fire_station", @"florist", @"food", @"funeral_home", @"furniture_store", @"gas_station", @"general_contractor", @"grocery_or_supermarket", @"gym", @"hair_care", @"hardware_store", @"health", @"hindu_temple", @"home_goods_store", @"hospital", @"insurance_agency", @"jewelry_store", @"laundry", @"lawyer", @"library", @"liquor_store", @"local_government_office", @"locksmith", @"lodging", @"meal_delivery", @"meal_takeaway", @"mosque", @"movie_rental", @"movie_theater", @"moving_company", @"museum", @"night_club", @"painter", @"park", @"parking", @"pet_store", @"pharmacy", @"physiotherapist", @"place_of_worship", @"plumber", @"police", @"post_office", @"real_estate_agency", @"restaurant", @"roofing_contractor", @"rv_park", @"school", @"shoe_store", @"shopping_mall", @"spa", @"stadium", @"storage", @"store", @"subway_station", @"synagogue", @"taxi_stand", @"train_station", @"travel_agency", @"university", @"veterinary_care", @"zoo", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [googleApiPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PlaceTypesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceTypeCell"];
	
	cell.lblPlaceTitle.text = [googleApiPlaces objectAtIndex:indexPath.row];
	cell.place_type = [googleApiPlaces_types objectAtIndex:indexPath.row];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	googleApiPlaces_Actual_types = [defaults objectForKey:@"mapPlacesFilters"];
	if ([googleApiPlaces_Actual_types containsObject:cell.place_type]) {
		[cell.switchPlace setOn:YES animated:NO];
	}
	else {
		[cell.switchPlace setOn:NO animated:NO];
	}
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)closePlaceTypesView:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PlaceTypesViewControllerDismissed"
														object:nil
													  userInfo:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
