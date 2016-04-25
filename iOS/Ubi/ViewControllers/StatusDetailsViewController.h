//
//  StatusDetailsViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 12/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "UbiUser.h"
#import "UbiStatus.h"
#import "CommentCell.h"
#import <UIKit/UIKit.h>
#import "TimelineCell.h"
#import "PeopleViewController.h"
#import "ImageviewViewController.h"
#import "UserDetailsViewController.h"
#import "PlaceDetailsViewController.h"
#import "UbiStatusComment.h"
#import "UbiStatusLike.h"

@interface StatusDetailsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    NSMutableDictionary * dati_utenti_caricati;
	NSMutableArray * commentiCaricati;
	
    UbiUser * currentUbiUser;
}

@property (weak, nonatomic) IBOutlet UICollectionView *commentsCollView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIView *txtFieldBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;

@property (nonatomic, retain) UbiStatus * selectedStatus;
@property (nonatomic, retain) UbiUser * selectedUser;

- (IBAction)postComment:(id)sender;

@end
