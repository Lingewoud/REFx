//
//  RXLogView.h
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RXLogView : NSViewController {
    NSTextView* pas3LogTextView;
    NSTimer* logTimer;
    NSString* railsRootDir;
}

- (void)pas3LogTimer;
- (void)readLastLinesOfLog;
- (void) setRailsRootDir: dir;

@property (assign) IBOutlet NSTextView *pas3LogTextView;



@end
