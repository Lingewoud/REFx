//
//  RXJobPicker.m
//  REFx4
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXJobPicker.h"
#import "RXRailsController.h"
#import "REFx3AppDelegate.h"
#import "RXEngineManager.h"


@implementation RXJobPicker
@synthesize refxTimer;
@synthesize refxSafetyTimer;

- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env
{
    self = [super init];
    if (self) {
        NSLog(@"init jobpicker");

        loopIsEnabled = NO;
        railsDbPath = dbPath;
        [self openDatabase];
        railsRootDir = dir;
        railsEnvironment = env;
        [self startLoopIfEnabledAndOpenJobs];
        [self startListeningFileChanges];
    }
    
    self.refxTimer = [[NSTimer alloc] init];
    
    self.refxSafetyTimer = [[NSTimer alloc] init];
    [self startREFxSafetyTimer];


    return self;
}

- (void)startListeningFileChanges
{
    NSLog(@"Starting listening for changes in %@",railsDbPath);
    
    VDKQueue *queue = [VDKQueue new];
    [queue addPath: railsDbPath notifyingAbout:VDKQueueNotifyAboutWrite];
    [queue setDelegate:self];
}

-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath
{
    NSLog(@"Database was update, so we update the table view");
    [self startLoopIfEnabledAndOpenJobs];
}

-(void) startLoopIfEnabledAndOpenJobs
{
    //if the scheduler is enabled and the their are open jobs then rjun the loop
    if(loopIsEnabled){
        NSLog(@"Loop is enabled");
        if([self numberOpenJobs] > 0)
        {
            if(![self.refxTimer isValid])
           {
               NSLog(@"There are open jobs, we start the loop");
               [self startREFxLoopAction];
           
           }
           else{
               //NSLog(@"A timer is already running, we stop the loop");

               //[self stopREFxLoopAction];
           
           }
        }
        else
        {
               NSLog(@"There are no open jobs, we stop the loop");
            [self stopREFxLoopAction];
        }
    }
    else
    {
        [self stopREFxLoopAction];
    }
    //else we stop the loop
}


- (void)startREFxLoop
{
    NSLog(@"set scheduler enabled");

    loopIsEnabled = YES;
    [self startLoopIfEnabledAndOpenJobs];
}

- (void)stopREFxLoop
{
    NSLog(@"set scheduler disabled");
    
    loopIsEnabled = NO;
    [self startLoopIfEnabledAndOpenJobs];

}

- (void)startREFxSafetyTimer
{
    NSLog(@"start safety time...");
    self.refxSafetyTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0
                                                      target: self
                                                    selector: @selector(startLoopIfEnabledAndOpenJobs)
                                                    userInfo: nil
                                                     repeats: YES];
}

- (void)startREFxLoopAction
{
    NSLog(@"start scheduler...");
    self.refxTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                 target: self
                                               selector: @selector(loopSingleAction)
                                               userInfo: nil
                                                repeats: YES];
}

- (void)stopREFxLoopAction
{
    NSLog(@"stop scheduler... ");
    if([self.refxTimer isValid])
    {
        [self.refxTimer invalidate];
        self.refxTimer = nil;
    }
}

- (void)loopSingleAction
{
    NSLog(@"Find new job");
    if([rubyJobProcess isRunning])
    {
        return;
    }
    
    int jobid = [self selectJob];
    
    if(jobid != 0 && jobRunning == NO)
    {
        jobRunning = YES;
        
        NSLog(@"DISPATCHING JOBID %i",jobid);
        [self setJobId:jobid status:2];
        NSString *jobidString = [NSString stringWithFormat:@"%i",jobid];
        
        NSString * engine = [self getJobEngine:jobid];
        
        RXEngineManager *sharedEngineManager = [RXEngineManager sharedEngineManager];

        NSString *engineDir = [sharedEngineManager pathToEngineResources:engine];
        NSString *enginePath = [NSString stringWithFormat:@"%@main.rb", [sharedEngineManager pathToEngineResources:engine]];
        NSString *runnerPath = [sharedEngineManager pathToEngineRunner];

        rubyJobProcess = [[NSTask alloc] init];
        
        [rubyJobProcess setCurrentDirectoryPath:engineDir];
        [rubyJobProcess setLaunchPath: enginePath];
        
        [rubyJobProcess setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];

        NSMutableArray * args = [NSMutableArray arrayWithObjects:
                          runnerPath,
                          @"-j",jobidString,
                          @"--environment",railsEnvironment,
                          nil];
        

        if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
        {
            [args addObject:@"-d"];
        }
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] > 0 && [[NSUserDefaults standardUserDefaults] integerForKey:@"disableMaxAttempts"]==0){
            [args addObject:@"-m"];
            [args addObject:[NSString stringWithFormat:@"%li", [[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] ]];
        }
        
        [rubyJobProcess setArguments:args];
        
        @try {
            [rubyJobProcess launch];
        }
        @catch (NSException *exception) {
            //increase attempt
            [self setJobId:jobid status:67];
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        
        
        jobRunning = NO;
    }
}

-(BOOL)openDatabase
{
    NSLog(@"open Database");

    NSFileManager *fileManager = [NSFileManager defaultManager];

    //check if file is already there
    if([fileManager fileExistsAtPath:railsDbPath])
    {
        if(sqlite3_open([railsDbPath UTF8String], &db) == SQLITE_OK)
        {
            NSLog(@"Database was opened at %@", railsDbPath);
            dbOpened = YES;
            return YES;
        }
    }
    
    NSLog(@"Database not found at location %@", railsDbPath);
    return NO;
}

-(void)closeDatabase
{
    sqlite3_close(db);
    dbOpened = NO;
}

-(NSString *) getJobEngine:(int)jobId
{
    if(!dbOpened)
    {
        NSLog(@"Database connection is lost. Trying to re-open");
        
        [self openDatabase];
        return NO;
    }
    
    sqlite3_stmt    *statement;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT engine FROM jobs WHERE id = %i", jobId];
    const char *query_stmt = [sql UTF8String];
    
    NSString *ret = nil;
    
    if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int result = sqlite3_step(statement);
        if(result == SQLITE_ROW)
        {
            ret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        }

    }
    else
    {
        NSLog(@"sqlite problem: %@", sql);
    }
    
    sqlite3_finalize(statement);
    
    return ret;

}

-(int)numberOpenJobs
{
    if(!dbOpened)
    {
        NSLog(@"Database connection is lost. Trying to re-open");
        
        [self openDatabase];
        return NO;
    }
    
    sqlite3_stmt    *statement;
    
    NSString *sql = @"SELECT count(id) as numopenjobs FROM jobs WHERE status > 0 AND status < 10";
    const char *query_stmt = [sql UTF8String];
    
    int ret;
    ret = 0;
    
    if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int result = sqlite3_step(statement);
        if(result == SQLITE_ROW)
        {
            NSLog(@"find open jobs");

            ret = sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog(@"Could not find open jobs, but there could be some");

            ret = 0;
        }
    }
    else
    {
        NSLog(@"sqlite problem: %@", sql);
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}

-(int)selectJob
{
    if(!dbOpened)
    {
        NSLog(@"Database connection is lost. Trying to re-open");

        [self openDatabase];
        return NO;   
    }
    
    sqlite3_stmt    *statement;
    NSLog(@"Find open jobs");

    NSString *sql = @"SELECT id, attempt FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1";
    const char *query_stmt = [sql UTF8String];
    
    int ret;
    ret = 0;
    int attempt;
    if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int result = sqlite3_step(statement);
        if(result == SQLITE_ROW)
        {
            NSLog(@"I guest I found open jobs");

            ret = sqlite3_column_int(statement, 0);
            attempt = sqlite3_column_int(statement,1);
            
            if([[NSUserDefaults standardUserDefaults] integerForKey:@"disableMaxAttempts"]==0)
            {
                if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] > 0 && [[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] < attempt)
                {
                    sqlite3_finalize(statement);
                    [self setJobId:ret status:67];
                    return 0;
                }
            }
            else
            {
                sqlite3_finalize(statement);

                return ret;
            }
        }
    }
    else
    {
        NSLog(@"sqlite problem: %@", sql);
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}

- (void)setJobId:(NSInteger)rowId status:(NSInteger)status
{
    
    if(dbOpened)
    {
        NSLog(@"increase attempt");
        
        sqlite3_stmt *statement;
        
        NSString *sql = [NSString stringWithFormat: @"UPDATE jobs SET status = %li WHERE id=%li", (long)status, (long)rowId];
        
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int result = sqlite3_step(statement);
            NSLog(@"update result %i",result);
        }
        else
        {
            NSLog(@"sqlite problem: %@", sql);
        }
        
        sqlite3_finalize(statement);
    }    
}

- (void)flushAllJobs {
    if(dbOpened)
    {
        NSLog(@"Flush jobs");
        
        sqlite3_stmt *statement;
        
        NSString *sql = [NSString stringWithFormat: @"DELETE FROM jobs"];
        
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int result = sqlite3_step(statement);
            NSLog(@"Flushed Jobs table %i",result);
        }
        else
        {
            NSLog(@"sqlite problem: %@", sql);
        }
        
        sqlite3_finalize(statement);
    }    
}

- (void) setJobsLastId:(NSInteger)rowId
{
    if(dbOpened)
    {      
        sqlite3_stmt *statement;
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (id,engine,body) values (%li,'MARKER','MARKER');", (long)rowId];

        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int result = sqlite3_step(statement);
            NSLog(@"update result %i",result);
        }
        else
        {
            NSLog(@"sqlite problem: %@", sql);
        }
        
        sqlite3_finalize(statement);
        
        //lastInsertRowId
    }    

}


- (int) insertTestJobwithEngine:(NSString*)engine body:(NSString*)body
{
    if(dbOpened)
    {
        sqlite3_stmt *statement;
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'%@','%@',1,1,0,'');",engine,body];
        
        const char *query_stmt = [sql UTF8String];
        
        if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int result = sqlite3_step(statement);
            NSLog(@"insert result %i",result);
        }
        else
        {
            NSLog(@"sqlite problem: %@", sql);
        }
        
        sqlite3_finalize(statement);
    }
    return sqlite3_last_insert_rowid(db);

}

- (void) dealloc {
    [self closeDatabase];
    db = nil;
    [self stopREFxLoop];
    railsRootDir = nil;
    refxTimer = nil;
    [super dealloc];
}


@end
