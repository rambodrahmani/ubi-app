//
//  WebViewViewController.m
//  Ubi
//
//  Created by Rambod Rahmani on 28/11/14.
//  Copyright (c) 2014 Rambod Rahmani. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
    self.title = _webTitle;
    
    finished = FALSE;
    [_progressView setProgress:0.0];
    [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    
    NSURLRequest * newRequest = [[NSURLRequest alloc] initWithURL:_selectedURL];
    [_webView loadRequest:newRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerCallback
{
    if (finished) {
        if (_progressView.progress >= 1) {
            [_progressView setHidden:YES];
        }
        else {
            _progressView.progress += 0.1;
        }
    }
    else {
        _progressView.progress += 0.01;
        if (_progressView.progress >= 0.98) {
            _progressView.progress = 0.98;
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    finished = TRUE;
}

- (IBAction)closeWebviewView:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
