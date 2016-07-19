//
//  CommentCell.m
//  Ubi
//
//  Created by Rambod Rahmani on 14/12/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)initProfileImgView:(NSIndexPath *)indexPath :(NSURL *)imageURL {
	[_imgViewProfilo sd_setImageWithURL:imageURL
					   placeholderImage:[UIImage imageNamed:@""]];
    [_imgViewProfilo setContentMode:UIViewContentModeScaleToFill];
    _imgViewProfilo.layer.cornerRadius = (_imgViewProfilo.frame.size.width/2);
    _imgViewProfilo.clipsToBounds = YES;
    _imgViewProfilo.tag = indexPath.row - 1;
}

@end
