//
//  UserCalloutMapAnnotation.h
//  Ubi
//
//  Created by Rambod Rahmani on 20/01/15.
//  Copyright (c) 2015 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"
#import "UbiUser.h"

@interface UserCalloutMapAnnotationView : MKAnnotationView
{
	MKAnnotationView *_parentAnnotationView;
	MKMapView *_mapView;
	CGRect _endFrame;
	UIView *_contentView;
	CGFloat _yShadowOffset;
	CGPoint _offsetFromParent;
	CGFloat _contentHeight;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic) CGPoint offsetFromParent;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) UIImageView * profilePicView;
@property (nonatomic, retain) UIImageView * SocialLogoView;
@property (nonatomic, retain) UIImageView * addFriendLogoView;
@property (nonatomic, retain) UIImageView * sendMessageLogoView;
@property (nonatomic, retain) UIImageView * buzzLogoView;

- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;

- (void)initProfilePicView:(UbiUser *)newUbiUser;
- (int)initLabels:(UbiUser *)newUbiUser :(CGSize)size;
- (void)initSocialLogo:(int)coordY :(NSString *)profileURL;
- (void)initAddFriend:(int)coordY;
- (void)initSendMessage:(int)coordY;
- (void)initBuzz:(int)coordY;
- (void)initLblDistance:(NSNumber *)distance :(CGSize)size;

@end
