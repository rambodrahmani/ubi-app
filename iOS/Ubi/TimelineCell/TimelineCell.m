//
//  timelineCell.m
//  Ubi
//
//  Created by Rambod Rahmani on 30/09/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "TimelineCell.h"

@implementation TimelineCell

- (void)initProfileImgView:(NSIndexPath *)indexPath :(NSURL *)imageURL {
	[_imgViewProfilo sd_setImageWithURL:imageURL
						   placeholderImage:[UIImage imageNamed:@""]];
	
    [_imgViewProfilo setContentMode:UIViewContentModeScaleToFill];
    _imgViewProfilo.layer.cornerRadius = (_imgViewProfilo.frame.size.width/2);
    _imgViewProfilo.clipsToBounds = YES;
    _imgViewProfilo.tag = indexPath.row;
}

- (void)initLblData:(NSString *)Data {
    NSArray * splitter = [Data componentsSeparatedByString:@"-"];
    int monthNumber = [[splitter objectAtIndex:1] intValue];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:(monthNumber-1)];
    NSString *shortMonthName = [monthName substringToIndex:3];
    _lblData.text = [NSString stringWithFormat:@"%d %@ %d", [[splitter objectAtIndex:2] intValue], shortMonthName, [[splitter objectAtIndex:0] intValue]];
}

- (void)initLblTags:(NSArray *)tags {
    if (tags.count > 0) {
        NSString * taggedPeopleColl = @"";
        for (UbiStatusTag * status_tag in tags) {
            taggedPeopleColl = [NSString stringWithFormat:@"%@%@%@ %@", taggedPeopleColl, (taggedPeopleColl.length > 0 ? @", " : @""), status_tag.user_name, status_tag.user_surname];
        }
        [_lblTags setText:taggedPeopleColl];
        [_lblTags setHidden:NO];
		[_lblWith setText:@"with"];
		_lblWidth_width.constant = 29;
		[_lblWith needsUpdateConstraints];
		[_lblTags needsUpdateConstraints];
		[_lblWith setHidden:NO];
    }
    else {
        [_lblTags setText:@"NO_TAGS"];
        [_lblTags setHidden:YES];
        [_lblWith setHidden:YES];
    }
}

- (void)initLblLoc:(UbiPlace *)status_place {
    if ([_lblTags.text isEqualToString:@"NO_TAGS"]) {
        if ( ([status_place.place_name length] > 0) && (![status_place.place_name isEqualToString:@"NO_LOC"]) ) {
            [_lblLoc setHidden:YES];
            [_lblAt setHidden:YES];
            [_lblTags setText:status_place.place_name];
            [_lblTags setHidden:NO];
            [_lblWith setText:@"at"];
			_lblWidth_width.constant = 14;
			[_lblWith needsUpdateConstraints];
			[_lblTags needsUpdateConstraints];
            [_lblWith setHidden:NO];
        }
        else {
            [_lblLoc setText:@"NO_LOC"];
            [_lblLoc setHidden:YES];
            [_lblAt setHidden:YES];
        }
        
    }
    else {
        if ( ([status_place.place_name length] > 0) && (![status_place.place_name isEqualToString:@"NO_LOC"]) ) {
            [_lblLoc setText:status_place.place_name];
            [_lblLoc setHidden:NO];
            [_lblAt setHidden:NO];
        }
        else {
            [_lblLoc setText:@"NO_LOC"];
            [_lblLoc setHidden:YES];
            [_lblAt setHidden:YES];
        }
    }
}

- (void)initTxtViewPost:(NSString *)StatusText {
    if ([StatusText length] > 0) {
        [_txtViewPost setHidden:NO];
        _txtViewPost.text = StatusText;
        //[_txtViewPost scrollRangeToVisible:NSMakeRange(0, 0)];
    }
    else {
        [_txtViewPost setHidden:YES];
    }
}

- (void)initImgViewMedia:(NSURL *)MediaURL {
    if ([MediaURL.absoluteString isEqualToString:@"NO_MEDIA"]) {
        [_imgViewMedia setHidden:YES];
    }
    else {
        [_imgViewMedia setHidden:NO];
        [_imgViewMedia sd_setImageWithURL:MediaURL
                             placeholderImage:[UIImage imageNamed:@""]];
    }
    
    [_imgViewMedia setContentMode:UIViewContentModeScaleAspectFill];
    _imgViewMedia.clipsToBounds = YES;
}

- (void)initLblLikesComm:(NSNumber *)likes_num :(NSNumber *)comments_num :(NSIndexPath *)indexPath {
    _lblLikesComm.text = [NSString stringWithFormat:@"%@ Likes   %@ Commenti", likes_num, comments_num];
    _lblLikesComm.tag = indexPath.row;
}

@end
