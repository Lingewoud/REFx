//
//  RXMainWindow.m
//  REFx4
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//
#import "REFx3AppDelegate.h"
#import "RXMainWindow.h"
#import "RXREFxIntance.h"
#import "RXJobPicker.h"
#import "RXRailsController.h"




@implementation RXMainWindow

@synthesize startStopButtonCommunicationServer;
@synthesize startStopButtonScheduler;
@synthesize jobMgrView;
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
    
    [self instanciateLogController];
}

- (void)instanciateJobController {
    
}

- (void)instanciateLogController {

    NSString * rootdirectory = [[[NSApp delegate] refxInstance ] railRootDir ];
    NSLog(@"rootdir: %@",rootdirectory);
    //[logController setRailsRootDir: rootdirectory];
}


- (IBAction)insertJob:(id)sender
{
    NSString * engine = [_insJobEngine stringValue];
    NSString * body = [_insJobBody stringValue];
    [_insJobPanel orderOut:sender];
    NSLog(@"%@ %@",engine,body);

    [[[[NSApp delegate] refxInstance] jobPicker] insertTestJobwithEngine:engine body:body];
    
    [self refreshJobmanagerView];
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
        
        [[[NSApp delegate] refxInstance ] startComServer:@"3031"];        
        
        [NSThread sleepForTimeInterval:3];        
    }
    else
    {
        [[[[NSApp delegate] refxInstance ] railsController] stopComServer];        
    }
}

- (void)refreshJobmanagerView {   
}


@end
