//
//  AppDelegate.m
//  Ubi
//
//  Created by Rambod Rahmani on 06/08/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <GooglePlus/GooglePlus.h>
#import <TwitterKit/TwitterKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
	
	[Parse setApplicationId:@"jg9icAPs43KbltxpNfnLTPYxFechYpRcggZOoOfn" clientKey:@"RK6jCKwzzsZtcsdMPT0CCxaUiDeyWZ8dCYrTICRu"];
	
	UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
													UIUserNotificationTypeBadge |
													UIUserNotificationTypeSound);
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																			 categories:nil];
	[application registerUserNotificationSettings:settings];
	[application registerForRemoteNotifications];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"" forKey:@"dati_utenti_caricati"];
	[defaults setObject:@"" forKey:@"id_utenti_caricati"];
	
	NSString *accountAccesso = [defaults objectForKey:@"current_user_sign_in_account"];
	
    [FBLoginView class];
	
    [QBSettings setLogLevel:QBLogLevelNothing];
	[QBApplication sharedApplication].applicationId = 15143;
	[QBConnection registerServiceKey:@"pPmxurA2R9qF5aw"];
	[QBConnection registerServiceSecret:@"OcmZQxjyHShcYqH"];
	[QBSettings setAccountKey:@"fpoJccZMu37y1iP3F1Ck"];
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        NSLog(@"QuickBlox Start Success");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"QuickBlox Start Failed");
    }];
    
	[FTGooglePlacesAPIService provideAPIKey:@"AIzaSyDvVkUL9hae0vMfYRVbG0AZjnwuj2ZLIcI"];
	
    if ([accountAccesso  isEqual:@"facebook"] || [accountAccesso  isEqual:@"twitter"] || [accountAccesso  isEqual:@"googleplus"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        self.window.rootViewController = viewController;
		
        [self.window makeKeyAndVisible];
    }
	
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	currentInstallation.channels = @[ @"global" ];
	[currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	if (currentInstallation.badge != 0) {
		currentInstallation.badge = 0;
		[currentInstallation saveEventually];
	}
	
    [FBAppEvents activateApp];
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL accessoGPInCorso = [defaults boolForKey:@"accessoGPInCorso"];
	NSString *accountAccesso = [defaults objectForKey:@"current_user_sign_in_account"];
	
	if ( (accessoGPInCorso == YES) || [accountAccesso isEqual:@"googleplus"] ) {
		return [GPPURLHandler handleURL:url
					  sourceApplication:sourceApplication
							 annotation:annotation];
	}
	
	return [FBAppCall handleOpenURL:url
				  sourceApplication:sourceApplication
					fallbackHandler:^(FBAppCall *call) {
						
					}];
}

@end
