//
//  RXREFxIntance.h
//  REFx3
//
//  Created by W.A. Snel on 17-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RXJobPicker;
@class RXRailsController;

@interface RXREFxIntance : NSObject{

    RXJobPicker* jobPicker;
    RXRailsController* railsController;
    NSString* railsRootDir;
    NSString* railsMasterDir;
    NSString* dbPath;
    RXREFxIntance* refxInstance;
    
}

- (NSString *) railRootDir;

- (void) checkAppScript;
- (void) startComServer:(NSString*)port;


@property (retain) RXJobPicker* jobPicker;
@property (retain) RXRailsController* railsController;
@property (assign,nonatomic) NSString *railsPort;


@end
