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
@synthesize refxTimer;
@synthesize refxSafetyTimer;

- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env
{
    self = [super init];
    if (self) {
        NSLog(@"init jobpicker");

        loopIsEnabled = NO;
        railsDbPath = dbPath;
        railsRootDir = dir;
        railsEnvironment = env;
        
        self.refxTimer = [[NSTimer alloc] init];
        self.refxSafetyTimer = [[NSTimer alloc] init];
        
        [self startLoopIfEnabledAndOpenJobs];
        [self startListeningFileChanges];
        
        NSLog(@"start safety timer ...");
        self.refxSafetyTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0
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
    NSLog(@"Database was update, so we update the table view");
    [self startLoopIfEnabledAndOpenJobs];
}

-(void) safetyTimerRun
{
    NSLog(@"Safety Timer: Checking if queue is still working if it should");
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

        NSLog(@"DISPATCHING JOBID %i",jobid);
        
        jobRunning = YES;

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


        NSPipe *errorPipe = [NSPipe pipe];
        NSPipe *outputPipe = [NSPipe pipe];

        [rubyJobProcess setStandardInput:[NSPipe pipe]];
        [rubyJobProcess setStandardError:errorPipe];
        [rubyJobProcess setStandardOutput:outputPipe];
        
        @try {
            [rubyJobProcess launch];

            NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
            NSString *outputString = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];

            NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
            NSString *errorString = [[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] autorelease];
    
            NSString * jobStdErrorLogFile = [jobLogFolder stringByAppendingString:@"/error.log"];
            NSString * jobStdOutputLogFile = [jobLogFolder stringByAppendingString:@"/output.log"];
            
            //NSLog(@"proc output:%@",outputString);
            //NSLog(@"proc error:%@",errorString);
            
            if([outputString length] > 0)
            {
                [outputString writeToFile:jobStdOutputLogFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }
            if([errorString length] > 0)
            {
                [errorString writeToFile:jobStdErrorLogFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }
        }
        @catch (NSException *exception) {
            //increase attempt
            [self setJobId:jobid status:67];
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
                
        jobRunning = NO;
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
    
    NSLog(@"Counting open jobs");

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
    
    FMResultSet *rs = [db executeQuery:@"SELECT id, attempt FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1"];
    while ([rs next]) {
        
        ret = [rs intForColumn:@"id"];
        attempt = [rs intForColumn:@"attempt"];
    }
    
    [db close];
    
    if(ret > 0)
    {
        [self increaseAttemts:ret];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"disableMaxAttempts"]==0)
    {
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] > 0 &&
           [[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] < attempt)
        {
            [self setJobId:ret status:66];
            ret = 0;
        }
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
    
//    db.traceExecution = YES;
//    db.logsErrors = YES;
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE jobs SET attempt = attempt + 1 WHERE id=%li",  (long)jobid];
    NSLog(@"Exec: %@",  sql);

    [db executeUpdate:sql];
    
    [db close];
}

- (void)setJobId:(NSInteger)rowId status:(NSInteger)status
{

    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return;
    }
    
   // db.traceExecution = YES;
   // db.logsErrors = YES;
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
    
    NSLog(@"INSERT TEST INTO jobs: %@", engine);
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'%@','%@',1,1,0,'');",engine,body];
    
    [db executeUpdate:sql];
    long newid = (long)[db lastInsertRowId];
    [db close];
    
    return newid;
}


- (void) dealloc {
    [self stopREFxLoop];
    railsRootDir = nil;
    refxTimer = nil;
    [super dealloc];
}


@end
