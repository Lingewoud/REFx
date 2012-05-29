//
//  RXJobMngrWebGui.m
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXJobMngrWebGui.h"
#import "RXJobPicker.h"

@implementation RXJobMngrWebGui

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}


- (void)loadView {
    [super loadView];
    NSLog(@"Loading Job Manager Interface");
    [webView setFrameLoadDelegate:self];
    [self stopJobManagerInterface];
 
}

- (void) stopJobManagerInterface {
    WebFrame *mainFrame = [webView mainFrame];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noserver" 
                                                         ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [mainFrame loadRequest:request];    
}

- (IBAction)initQueueWebView:(id)sender{
    NSLog(@"init Job Manager Interface");
    [self setWebViewUrlWithPort:@"3030"];

}

- (IBAction)flushJobs:(id)sender{

    [[[[NSApp delegate] refxInstance] jobPicker] flushAllJobs];
    [self setWebViewUrlWithPort:@"3030"];
}


- (void)setWebViewUrlWithPort:(NSString*)port
{
   // [runningRailsPort release];
    //[runningRailsPort initWithString:port];
    //NSString* urlString;

    WebFrame *mainFrame = [webView mainFrame];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%@/Jobs",port]];

    //urlString = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [mainFrame loadRequest:request];  
}




#pragma mark -
#pragma mark webview delegates

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
        NSLog(@"finished loading");
}


@end
