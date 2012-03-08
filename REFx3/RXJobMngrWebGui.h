//
//  RXJobMngrWebGui.h
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>

@interface RXJobMngrWebGui : NSViewController {
    WebView *webView;
  //  NSString *runningRailsPort;
}

@property (assign) IBOutlet WebView *webView;
//@property (assign) NSString *runningRailsPort;

- (void) stopJobManagerInterface;
- (IBAction)initQueueWebView:(id)sender;
- (void)setWebViewUrlWithPort:(NSString*)port;




@end
