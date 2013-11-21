//
//  RXJobPicker.m
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXJobPicker.h"
#import "RXRailsController.h"
#import "REFx3AppDelegate.h"
#import "RXEngineManager.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"


@implementation RXJobPicker

//@synthesize refxTimer;
@synthesize refxSafetyTimer;
@synthesize railsDbPath,railsEnvironment,railsRootDir;
@synthesize loopIsEnabled,running;

- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env
{
    self = [super init];
    if (self) {
        NSLog(@"init jobpicker");

        self.loopIsEnabled = NO;

    
        self.railsDbPath = dbPath;
        //railsRootDir = dir;
        self.railsEnvironment = env;
        
        self.refxSafetyTimer = [[NSTimer alloc] init];
        
        [self executeJobIfEnabledAndOpenJobs];
        [self startListeningFileChanges];
        
        NSLog(@"start safety timer ...");
        self.refxSafetyTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                          target: self
                                                        selector: @selector(safetyTimerRun)
                                                        userInfo: nil
                                                         repeats: YES];
    }
    
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
    //NSLog(@"Database was update, so we update the table view");
    [self executeJobIfEnabledAndOpenJobs];
}

-(void) safetyTimerRun
{
    NSLog(@"Safety Timer: Checking if queue is still working if it should");
    [self executeJobIfEnabledAndOpenJobs];
}

-(void) executeJobIfEnabledAndOpenJobs
{
    //NSLog(@"loop  %i", self.loopIsEnabled);
    if(self.loopIsEnabled)
    {
        if([self numberOpenJobs] > 0)
        {
            [self loopSingleAction];
        }
    }
}

- (void)startREFxLoop
{
    NSLog(@"set scheduler enabled");

    self.loopIsEnabled = YES;
    [self executeJobIfEnabledAndOpenJobs];
}

- (void)stopREFxLoop
{
    NSLog(@"set scheduler disabled");
    
    self.loopIsEnabled = NO;
}

- (void)loopSingleAction
{
    //NSLog(@"job running?: %i", [self isRunning]);

    if([self isRunning] == NO)
    {
        [self performSelectorInBackground:@selector(executeRubyRunner) withObject:nil];
    }
}

- (void)executeRubyRunner
{
    //NSLog(@"Find new job");
    int jobid = [self selectJob];
    
    if(jobid != 0 && [self isRunning] == NO)
    {
        NSLog(@"DISPATCHING JOBID %i",jobid);
        
        //NSLog(@"job running?: %i", [self isRunning]);
        self.running = YES;
        //NSLog(@"job running?: %i", [self isRunning]);
        
        
        NSString * jobLogFolder = [NSString stringWithFormat:@"%@/%i",[[NSApp delegate ] jobLogFilePath],jobid];
        NSLog(@"Creating JobsLogs: %@",jobLogFolder);
        
        if([[ NSFileManager defaultManager ] fileExistsAtPath:jobLogFolder]){
            [[ NSFileManager defaultManager ] removeItemAtPath:jobLogFolder error:nil];
        }
        
        [[ NSFileManager defaultManager ] createDirectoryAtPath: jobLogFolder withIntermediateDirectories: YES attributes: nil error: NULL ];
        
        [self setJobId:jobid status:2];
        NSString *jobidString = [NSString stringWithFormat:@"%i",jobid];
        
        NSString * engine = [self getJobEngine:jobid];
        
        RXEngineManager *sharedEngineManager = [RXEngineManager sharedEngineManager];
        
        NSString *engineDir = [sharedEngineManager pathToEngineResources:engine];
        NSString *enginePath = [NSString stringWithFormat:@"%@main.rb", [sharedEngineManager pathToEngineResources:engine]];

        NSString *runnerPath = [sharedEngineManager pathToEngineRunner];

        NSTask *rubyJobProcess2 = [[NSTask alloc] init];
        [rubyJobProcess2 setCurrentDirectoryPath:engineDir];
        [rubyJobProcess2 setLaunchPath: enginePath];
        
        [rubyJobProcess2 setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];
        
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
        
        [rubyJobProcess2 setArguments:args];
        //NSLog(@"workdir nstask: %@ ", engineDir);
        //NSLog(@"arguments nstask: %@ %@",enginePath, [args componentsJoinedByString:@" "] );

        
        NSPipe *errorPipe = [NSPipe pipe];
        
        [rubyJobProcess2 setStandardError:errorPipe];
        
        [rubyJobProcess2 launch];
        [rubyJobProcess2 waitUntilExit];
        //NSLog(@"nstask has stopped");
        
        if ([rubyJobProcess2 terminationStatus] != 0)
         {
            
             //[self setJobId:jobid status:70];
             NSLog(@"something went wrong:error code %i",[rubyJobProcess2 terminationStatus]);
         }
        

        
        NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
        NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSString * jobStdErrorLogFile = [jobLogFolder stringByAppendingString:@"/error.log"];
        
        if([errorString length] > 0)
        {
            [errorString writeToFile:jobStdErrorLogFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        
        self.running = NO;
    }
}

-(NSString *) getJobEngine:(int)jobId
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return nil;
    }
    
    
    NSString *sql = [NSString stringWithFormat: @"SELECT engine FROM jobs WHERE id = %i", jobId];

    NSString *engine = [db stringForQuery:sql];
    NSLog(@"select engine:%@",engine);

    [db close];
    return engine;
}

-(int)numberOpenJobs
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return 0;
    }
    
    int count = [db intForQuery:@"SELECT count(id) as numopenjobs FROM jobs WHERE status > 0 AND status < 10"];
    
    [db close];
    return count;
}

-(int)selectJob
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return 0;
    }
    
    int ret;
    ret = 0;
    int attempt;
    
    db.traceExecution = YES;
    db.logsErrors = YES;
    
    FMResultSet *rs = [db executeQuery:@"SELECT id, attempt FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1"];
    while ([rs next]) {
        
        ret = [rs intForColumn:@"id"];
        attempt = [rs intForColumn:@"attempt"];
    }
    
    [db close];
    
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"disableMaxAttempts"]==0)
    {
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] > 0 &&
           [[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] <= attempt)
        {
            [self setJobId:ret status:66];
            ret = 0;
        }
    }
    
    if(ret > 0)
    {
        [self increaseAttemts:ret];
    }

    
    return ret;
}

- (void)increaseAttemts:(NSInteger)jobid
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return;
    }
    
    db.traceExecution = YES;
    db.logsErrors = YES;
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE jobs SET attempt = attempt + 1 WHERE id=%li",  (long)jobid];
    NSLog(@"Exec: %@",  sql);

    if([db executeUpdate:sql])
    {
        NSLog(@"sql ok:%@",sql);
    }
    
    [db close];
}

- (void)setJobId:(NSInteger)rowId status:(NSInteger)status
{

    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return;
    }
    
    db.traceExecution = YES;
    db.logsErrors = YES;
    NSLog(@"Exec: UPDATE jobs SET status = %li WHERE id=%li", (long)status, (long)rowId);

    NSString *sql = [NSString stringWithFormat:@"UPDATE jobs SET status = %li WHERE id=%li", (long)status, (long)rowId];
    [db executeUpdate:sql];
    
    [db close];
}

- (void)flushAllJobs {
    
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return;
    }

    NSLog(@"Flush jobs");
   
    [db executeUpdate:@"DELETE FROM jobs"];
    
    [db close];
    return;
}

- (void) setJobsLastId:(NSInteger)rowId
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return;
    }
    
    NSLog(@"INSERT INTO jobs: %li", (long)rowId);
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO jobs (id,engine,body) values (%li,'MARKER','MARKER');", (long)rowId];
    [db executeUpdate:sql];
    
    [db close];
    
    return;
}

- (long) insertTestJobwithEngine:(NSString*)engine body:(NSString*)body
{
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return 0;
    }
    
    db.traceExecution = YES;
    db.logsErrors = YES;
    
    NSLog(@"INSERT TEST INTO jobs: %@", engine);
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'%@','%@',1,1,0,'');",engine,body];
    
    [db executeUpdate:sql];
    long newid = (long)[db lastInsertRowId];
    [db close];
    
    return newid;
}

@end
