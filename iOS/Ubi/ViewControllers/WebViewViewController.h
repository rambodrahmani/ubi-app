//
//  WebViewViewController.h
//  Ubi
//
//  Created by Rambod Rahmani on 28/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController <UIWebViewDelegate>
{
    BOOL finished;
}

@property (strong, nonatomic) NSURL * selectedURL;
@property (strong, nonatomic) NSString * webTitle;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)closeWebviewView:(id)sender;

@end
