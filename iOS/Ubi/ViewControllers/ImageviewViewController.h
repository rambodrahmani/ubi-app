//
//  ImageViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 21/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface ImageviewViewController : UIViewController

@property (weak, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) NSURL *selectedImageURL;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageImgView;

- (IBAction)closeImageviewView:(id)sender;

@end
