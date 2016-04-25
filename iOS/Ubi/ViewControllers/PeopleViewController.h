//
//  LikesViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 10/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUSer.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UserDetailsViewController.h"

@interface PeopleViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CLLocationManager * locationManager;
    
    NSMutableArray * dati_utenti_caricati;
}

@property (weak, nonatomic) IBOutlet UITableView *likesTableView;

@property (nonatomic, copy) NSArray * peopleEmails;
@property (nonatomic, copy) NSString * viewTitle;

@end
