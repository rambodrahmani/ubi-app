//
//  ImageViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 21/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ImageviewViewController.h"

@interface ImageviewViewController ()

@end

@implementation ImageviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	if (_selectedImage) {
		[_selectedImageImgView setImage:_selectedImage];
	}
	else {
		[_selectedImageImgView sd_setImageWithURL:_selectedImageURL
								 placeholderImage:[UIImage imageNamed:@""]];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (IBAction)closeImageviewView:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
