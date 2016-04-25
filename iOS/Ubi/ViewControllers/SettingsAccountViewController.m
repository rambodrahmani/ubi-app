//
//  SettingsAccountViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 14/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "SettingsAccountViewController.h"

@interface SettingsAccountViewController ()

@end

@implementation SettingsAccountViewController

#define BASE_URL @"http://server.ubisocial.it"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    picFromCamera = FALSE;
    
    [_lblLastPost setNumberOfLines:2];
    [_lblBio setNumberOfLines:3];
    
	[self.navigationItem setTitle:@"Account"];
	
	currentUbiUser = [[UbiUser alloc] initFromCache];
    
	SDImageCache *imageCache = [SDImageCache sharedImageCache];
	[imageCache queryDiskCacheForKey:currentUbiUser.profile_pic.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
		if (image) {
			[_imgViewCoverPic setImage:[self applyBlurOnImage:image withRadius:0.5f]];
			[_imgViewProfilePic setImage:image];
		}
		else {
			[SDWebImageDownloader.sharedDownloader downloadImageWithURL:currentUbiUser.profile_pic
																options:0
															   progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
															  completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
																  if (image && finished) {
																	  [_imgViewCoverPic setImage:[self applyBlurOnImage:image withRadius:0.5f]];
																	  [_imgViewProfilePic setImage:image];
																	  [[SDImageCache sharedImageCache] storeImage:image forKey:currentUbiUser.profile_pic.absoluteString toDisk:YES];
																  }
															  }];
		}
	}];
	
    [_imgViewProfilePic setContentMode:UIViewContentModeScaleToFill];
    _imgViewProfilePic.layer.cornerRadius = (_imgViewProfilePic.frame.size.width/2);
    _imgViewProfilePic.clipsToBounds = YES;
	
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [_imgViewProfilePic setUserInteractionEnabled:YES];
    [_imgViewProfilePic addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTapSecond = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapDetected)];
    singleTapSecond.numberOfTapsRequired = 1;
    [_imgView setUserInteractionEnabled:YES];
    [_imgView addGestureRecognizer:singleTapSecond];
	
	[_lblEmail setText:currentUbiUser.email];
	[_lblSocialNetwork setText:[currentUbiUser.profile_url absoluteString]];
	[_lblNome setText:currentUbiUser.name];
	[_lblCognome setText:currentUbiUser.surname];
	[_lblDataDiNascita setText:currentUbiUser.birthday];
	[_lblSesso setText:currentUbiUser.gender];
	[_lblLastPost setText:currentUbiUser.last_status_text];
	[_lblBio setText:currentUbiUser.bio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)profileTapDetected {
    [[[UIActionSheet alloc] initWithTitle:@"Select from:"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

#pragma mark - imagePickerController methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        picFromCamera = FALSE;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1)
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Device has no camera."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
        }
        else
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            picFromCamera = TRUE;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = [info[UIImagePickerControllerEditedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [_imgViewProfilePic setImage:chosenImage];
    UIImage * newImage = [self applyBlurOnImage:_imgViewProfilePic.image withRadius:0.5f];
    [_imgViewCoverPic setImage:newImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSDateFormatter *formatter;
    NSString * fileName;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    fileName = [formatter stringFromDate:[NSDate date]];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    fileName = [NSString stringWithFormat:@"%@.png", fileName];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.5);
    NSString * mediaURL = [NSString stringWithFormat:@"%@/uploads/users/%@/%@", BASE_URL, currentUbiUser.db_id, fileName];
    
    NSDictionary *params = @{@"user_id": currentUbiUser.db_id,
                             @"media_url": mediaURL};
    
    [[manager POST:@"/php/1.1/upload_new_user_pic.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
      {
          if (_imgViewProfilePic.image) {
              [formData appendPartWithFileData:imageData name:@"uploadedfile" fileName:fileName mimeType:@"image/jpeg"];
          }
      } success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSRange range = [operation.responseString rangeOfString:@"ERROR"];
          if (range.length == 0)
          {
              if (_imgViewProfilePic.image) {
                  if (picFromCamera) {
                      UIImageWriteToSavedPhotosAlbum(_imgViewProfilePic.image,
                                                     nil,
                                                     nil,
                                                     nil);
                  }
              }
			  
			  currentUbiUser.profile_pic = [NSURL URLWithString:mediaURL];
			  [currentUbiUser saveCurrentUserToCache];
			  [currentUbiUser updateUserInfoToDB];
          }
		  else {
			  [[[UIAlertView alloc] initWithTitle:@"Something went wrong"
										  message:@"Please retry."
										 delegate:self
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil] show];
		  }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [[[UIAlertView alloc] initWithTitle:@"Errore"
                                      message:[NSString stringWithFormat:@"Si è verificato un errore durante il caricamento del media allegato al post. %@", error.description]
                                     delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil] show];
      }] start];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		SDImageCache *imageCache = [SDImageCache sharedImageCache];
		[imageCache clearMemory];
		[imageCache clearDisk];
	});
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur withRadius:(CGFloat)blurRadius
{
    UIImage *returnImage = nil;
    
    if ((blurRadius <= 0.0f) || (blurRadius > 1.0f)) {
        blurRadius = 0.5f;
    }
    int boxSize = (int)(blurRadius * 100);
    boxSize -= (boxSize % 2) + 1;
    CGImageRef rawImage = imageToBlur.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(imageToBlur.CGImage));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    returnImage = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
