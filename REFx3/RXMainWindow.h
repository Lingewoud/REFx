//
//  RXMainWindow.h
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RXJobMngrWebGui;
@class RXLogView;

@interface RXMainWindow : NSWindowController<NSWindowDelegate> {
    RXJobMngrWebGui* jobMngrController;
    RXLogView* logController;
}

@property (assign) IBOutlet NSButton *startStopButtonScheduler;
@property (assign) IBOutlet NSButton *startStopButtonCommunicationServer;

@property (assign) IBOutlet NSTabViewItem* jobMgrView;
@property (assign) IBOutlet NSTabViewItem* logTabView;
@property (assign) IBOutlet NSWindow* theWindow;

- (IBAction)startStopActionScheduler:(id)sender;
- (IBAction)startStopActionCommunicationServer:(id)sender;
- (void)refreshJobmanagerView;
@end
