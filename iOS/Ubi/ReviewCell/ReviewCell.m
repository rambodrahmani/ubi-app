//
//  ReviewCell.m
//  Ubi
//
//  Created by Rambod Rahmani on 29/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell

- (void)initProfileImgView:(NSIndexPath *)indexPath :(NSURL *)imageURL {
	[_imgViewProfilo sd_setImageWithURL:imageURL
					   placeholderImage:[UIImage imageNamed:@""]];
	_imgViewProfilo.layer.cornerRadius = (_imgViewProfilo.frame.size.width/2);
	_imgViewProfilo.clipsToBounds = YES;
	_imgViewProfilo.tag = indexPath.row;
}

@end
