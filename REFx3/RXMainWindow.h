//
//  RXMainWindow.h
//  REFx4
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EngineListingController.h"

@class RXJobMngrWebGui;
@class EngineListingController;

@interface RXMainWindow : NSWindowController<NSWindowDelegate> {
    RXJobMngrWebGui* jobMngrController;
}

@property (assign) IBOutlet NSButton *startStopButtonScheduler;
@property (assign) IBOutlet NSButton *startStopButtonCommunicationServer;
@property (assign) IBOutlet EngineListingController *theEngineListingController;
@property (assign) IBOutlet NSTextField *lastJobid;

@property (assign) IBOutlet NSTabViewItem* jobMgrView;
@property (assign) IBOutlet NSWindow* theWindow;

@property (assign) IBOutlet NSTextField *insJobEngine;
@property (assign) IBOutlet NSTextField *insJobBody;
@property (assign) IBOutlet NSTextField *Appversion;
@property (assign) IBOutlet NSPanel *insJobPanel;

- (IBAction)startStopActionScheduler:(id)sender;
- (IBAction)startStopActionCommunicationServer:(id)sender;
- (IBAction)insertJob:(id)sender;

- (IBAction)openLogWindow:(id)sender;
- (IBAction)openEngineFolder:(id)sender;
- (IBAction)openTestJobsFolder:(id)sender;
- (IBAction)flushRailsLog:(id)sender;
- (IBAction)flushEngineLog:(id)sender;
- (IBAction)flushJobs:(id)sender;
- (IBAction)reinstallDatabase:(id)sender;
- (IBAction)openWebInterface:(id)sender;
- (IBAction)setLastJobId:(id)sender;


//- (void)refreshJobmanagerView;
@end
