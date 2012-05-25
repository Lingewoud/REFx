//
//  RXRailsController.h
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXRailsController : NSObject{
    NSTask *comServerProcess;
    BOOL comServerRunning;
    NSString* railsRootDirectory;
    NSString* runningRailsPort;
}

- (id)initWithRailsRootDir: (NSString *)dir;
- (void)startComServer:(NSString*)railsPort :(NSString*)environment;
- (void)stopComServer;

@property (assign) NSString *railsRootDirectory;
@property (assign) NSString *runningRailsPort;

@end
