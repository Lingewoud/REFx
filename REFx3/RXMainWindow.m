//
//  RXMainWindow.m
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//
#import "REFx3AppDelegate.h"
#import "RXMainWindow.h"
#import "RXREFxIntance.h"
#import "RXJobMngrWebGui.h"
#import "RXLogView.h"
#import "RXJobPicker.h"
#import "RXRailsController.h"




@implementation RXMainWindow

@synthesize startStopButtonCommunicationServer;
@synthesize startStopButtonScheduler;
@synthesize jobMgrView;
@synthesize logTabView;
@synthesize theWindow;

- (id) initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {

    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [theWindow setDelegate:self];

    [startStopButtonScheduler setState:0];   
    [startStopButtonCommunicationServer setState:0];
    
    [self instanciateJobController];
    [self instanciateLogController];
}

- (void)instanciateJobController {
    
    jobMngrController = [[RXJobMngrWebGui alloc] initWithNibName:@"RXJobMngrWebGui" bundle:nil];
    [jobMgrView setView:jobMngrController.view];
}

- (void)instanciateLogController {
    logController = [[RXLogView alloc] initWithNibName:@"RXLogView" bundle:nil];
    NSString * rootdirectory = [[[NSApp delegate] refxInstance ] railRootDir ];
    NSLog(@"rootdir: %@",rootdirectory);
    [logController setRailsRootDir: rootdirectory];
    
    [logTabView setView:logController.view];
    [logController pas3LogTimer];
}


- (void)startStopActionScheduler:(id)sender
{
    if([startStopButtonScheduler state]==1)
    {
        [[[[NSApp delegate] refxInstance] jobPicker] startREFxLoop];        

    }
    else
    {
        [[[[NSApp delegate] refxInstance] jobPicker] stopREFxLoop];        
    }
}

- (void)startStopActionCommunicationServer:(id)sender
{   
    if([startStopButtonCommunicationServer state]==1) {

        [[[NSApp delegate] refxInstance ] startComServer:@"3030"];        
     
        [NSThread sleepForTimeInterval:3];

        [jobMngrController setWebViewUrlWithPort:@"3030"];
    }
    else
    {
        [[[[NSApp delegate] refxInstance ] railsController] stopComServer];
        [jobMngrController stopJobManagerInterface];
    
    }
}



@end
