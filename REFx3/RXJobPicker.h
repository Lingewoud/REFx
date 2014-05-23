//
//  RXJobPicker.h
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <sqlite3.h>
#import "VDKQueue.h"

@interface RXJobPicker : NSObject <VDKQueueDelegate> {

    NSTimer * refxTimer;

/*
    //    BOOL jobRunning;
    BOOL loopIsEnabled;
    NSString* railsRootDir;
    NSString* railsDbPath;
    NSString* railsEnvironment;
    //    NSTask *rubyJobProcess;

  */

}

//@property (retain) NSTimer *refxTimer;
@property (nonatomic,retain) NSTimer *refxSafetyTimer;
@property (nonatomic,retain) NSTimer *refxTimer;

//@property (nonatomic, assign) BOOL jobRunning;
@property (nonatomic, assign) BOOL loopIsEnabled;
@property (nonatomic, assign) BOOL fastTimer;

@property (nonatomic, retain) NSString* railsEnvironment;
@property (nonatomic, retain) NSString* railsRootDir;
@property (nonatomic, retain) NSString* railsDbPath;
@property (nonatomic, retain) NSMutableArray* openJobs;
@property (nonatomic, retain) NSMutableArray* closedJobs;

@property (nonatomic, getter=isRunning) BOOL running;
//@property (nonatomic) int currentJobId;


- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env;

- (void) loopSingleAction;
- (void) setJobId:(NSInteger)rowId status:(NSInteger)status;
- (long) selectJob;
- (void) flushAllJobs;
- (void) startREFxLoop;
- (void) stopREFxLoop;
//- (void) startREFxLoopAction;
//- (void) stopREFxLoopAction;
- (void) setJobsLastId:(NSInteger)rowId;
- (long) insertTestJobwithEngine:(NSString*)engine body:(NSString*)body;



@end
