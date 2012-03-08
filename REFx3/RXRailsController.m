//
//  RXRailsController.m
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXRailsController.h"



@implementation RXRailsController

@synthesize railsRootDirectory;
@synthesize runningRailsPort;


- (id)initWithRailsRootDir: (NSString*)dir {
    self = [super init];
    
    if (self) {
        railsRootDirectory = [dir copy];
        NSLog(@"init railscontroller with dir %@", railsRootDirectory);
    }
    
    return self;
}

- (void) dealloc {
    [self stopComServer];
    [super dealloc];
}


// startComServer starts a RAILS instance at a specific port
- (void)startComServer:(NSString*)railsPort
{
    NSLog(@"start communication server ...");
   
    if(comServerRunning == NO)
    {        
        NSLog(@"start communication server %@",railsRootDirectory);

        NSString *railsCommand = [NSString stringWithFormat:@"%@/script/server", railsRootDirectory];
        
        if(![railsPort intValue]) {
            railsPort = @"3030";
        }
        [self setRunningRailsPort:railsPort];

        comServerProcess = [[NSTask alloc] init];    
        
        [comServerProcess setCurrentDirectoryPath:railsRootDirectory];
        [comServerProcess setLaunchPath: railsCommand];
        [comServerProcess setArguments: [NSArray arrayWithObjects: @"--port", railsPort,nil]];    
//        [comServerProcess setArguments: [NSArray arrayWithObjects:@"webrick", @"--port", railsPort,nil]];    
        
        comServerRunning = YES;
        [comServerProcess launch];
        [comServerProcess release];
    }
}


// startComServer stops a RAILS instance at a specific port by calling the terminator script
- (void)stopComServer
{
    NSLog(@"Stopping Rails at port: %@ ...", [self runningRailsPort]);
    
    NSString *terminatePath = [NSString stringWithFormat:@"%@/Contents/Resources/",[[NSBundle mainBundle] bundlePath]];
    NSLog(@"term path: %@",terminatePath);
    
    NSString *terminateCommand = [NSString stringWithFormat:@"%@railsTerminator.rb", terminatePath];
    
    NSLog(@"term cmd: %@",terminateCommand);
    
    NSTask *terminatebProcess = [[NSTask alloc] init];    
    [terminatebProcess setCurrentDirectoryPath:terminatePath];
    [terminatebProcess setLaunchPath: terminateCommand];
    [terminatebProcess setArguments: [NSArray arrayWithObjects:@"-p",[self runningRailsPort],nil]];    
    [terminatebProcess launch];        
    
    [terminatebProcess waitUntilExit];
    int status = [terminatebProcess terminationStatus];
    
    if (status == 0){
        NSLog(@"Task succeeded.");
        comServerRunning = NO;
        
        // TODO STOP MANAGER INTERFACE
    }
    else NSLog(@"Task failed.");
    
    [terminatebProcess release];
}




@end
