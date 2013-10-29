//
//  RXREFxIntance.h
//  REFx4
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
    NSString* AppSupportDir;
    NSString* railsMasterDir;
    NSString* dbPath;
    NSString* railsEnvironment;

    RXREFxIntance* refxInstance;
}

-(void) startComServer:(NSString*)port;
-(NSString*) getDbPath;
-(NSString*) getRailsEnvironment;
-(NSString *) railRootDir;
- (void) createDatabasesForceIfExist: (BOOL) force;


@property (retain) RXJobPicker* jobPicker;
@property (retain) RXRailsController* railsController;
@property (assign,nonatomic) NSString *railsPort;


@end
