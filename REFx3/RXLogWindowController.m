//
//  RXLogWindowWindowController.m
//  REFx
//
//  Created by Pim Snel on 10-09-13.
//
//

#import "RXLogWindowController.h"
#import "REFx3AppDelegate.h"

//@interface RXLogWindowController ()

//@end

@implementation RXLogWindowController


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {

    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (IBAction)openLogInConsoleApp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:[[NSApp delegate] engineLogFilePath] withApplication:@"Console"];
}




@end
