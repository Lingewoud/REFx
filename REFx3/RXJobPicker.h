//
//  RXJobPicker.h
//  REFx3
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@interface RXJobPicker : NSObject {

    NSTimer *refxTimer;
    BOOL jobRunning;
    NSString* railsRootDir;
    NSString* railsDbPath;
    NSString* railsEnvironment;
    BOOL dbOpened;
    sqlite3 *db;
    NSTask *rubyJobProcess;
    

}


- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env;

- (void) loopSingleAction;
- (void) setJobId:(NSInteger)rowId status:(NSInteger)status;
- (int)  selectJob;
- (void) startREFxLoop;
- (void) stopREFxLoop;
- (void) setJobsLastId:(NSInteger)rowId;
- (BOOL) openDatabase;
- (void) closeDatabase;
- (void) insertTestJobSayWhat;
- (void) insertTestJobIndexIndesignFranchiseOpenIndd;
- (void) insertTestJobGenerateIndesignFranchise;
- (void) insertTestJobIndexIndesignFranchise;



@end
