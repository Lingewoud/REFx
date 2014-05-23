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
@synthesize refxTimer,refxSafetyTimer;
@synthesize railsDbPath,railsEnvironment,railsRootDir;
@synthesize loopIsEnabled,running,openJobs,closedJobs,fastTimer;

- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env
{
    self = [super init];
    if (self) {
        NSLog(@"init jobpicker");
        self.openJobs = [NSMutableArray array];
        self.closedJobs = [NSMutableArray array];

        self.loopIsEnabled = NO;
        self.fastTimer = NO;
    
        self.railsDbPath = dbPath;
        //railsRootDir = dir;
        self.railsEnvironment = env;
        
        
        
        [self startListeningFileChanges];
        
        NSLog(@"start safety timer ...");
        [self executeJobIfEnabledAndOpenJobs];

        
        self.refxSafetyTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                                target: self
                                                              selector: @selector(safetyTimerRun)
                                                              userInfo: nil
                                                               repeats: YES];
        
         //[self setSlowTimer];

    }
    
    return self;
}

- (void)setFastTimer
{

        NSLog(@"set fast timer");
        if (self.refxTimer != nil) {
            
            [refxTimer invalidate];
            self.refxTimer = nil;
        }
        
        self.refxTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                target: self
                                                              selector: @selector(safetyTimerRun)
                                                              userInfo: nil
                                                               repeats: YES];
        self.fastTimer = YES;
        

    
}

-(void)setSlowTimer
{
        self.fastTimer = NO;
        
        NSLog(@"set slow timer");
        
        if (self.refxTimer != nil) {
            
            [refxTimer invalidate];
            self.refxTimer = nil;
        }
    return;
    
        self.refxTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                                target: self
                                                              selector: @selector(safetyTimerRun)
                                                              userInfo: nil
                                                               repeats: YES];


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
    NSLog(@"Database was update, so we update seek another job to run");
//    [self executeJobIfEnabledAndOpenJobs];
    
    [self setFastTimer];
}

-(void)safetyTimerRun
{
    //NSLog(@"Safety Timer: Checking if queue is still working if it should");
    [self executeJobIfEnabledAndOpenJobs];
}

-(void) executeJobIfEnabledAndOpenJobs
{
    if(self.loopIsEnabled)
    {
        if([self numberOpenJobs] > 0)
        {
            //[self setFastTimer];

            if(![self isRunning] || [self.openJobs count] > 0 || [self numberOpenJobs] > 0)
            {
                NSLog(@"loopSingleAction");
                [self loopSingleAction];
            }
        }
        else
        {
            [self setSlowTimer];
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
       //[self executeRubyRunner];

    }
}

- (void)executeRubyRunner
{
    //NSLog(@"Find new job");
    int jobid = [self selectJob];
    
    if(jobid != 0 && [self isRunning] == NO)
    {
        NSLog(@"DISPATCHING JOBID %i",jobid);
        //return;
        //NSLog(@"job running?: %i", [self isRunning]);
        self.running = YES;
        //NSLog(@"job running?: %i", [self isRunning]);
        
        
        NSString * jobLogFolder = [NSString stringWithFormat:@"%@/%i",[[NSApp delegate ] jobLogFilePath],jobid];
        NSLog(@"Creating JobsLogs: %@",jobLogFolder);
        
        if([[ NSFileManager defaultManager ] fileExistsAtPath:jobLogFolder]){
            [[ NSFileManager defaultManager ] removeItemAtPath:jobLogFolder error:nil];
        }
        
        [[ NSFileManager defaultManager ] createDirectoryAtPath: jobLogFolder withIntermediateDirectories: YES attributes: nil error: NULL ];
        
//        [self setJobId:jobid status:2];
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
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"dontWriteStdError"]) {
            NSLog(@"don't write to stdError");
        }
        else{
            [rubyJobProcess2 setStandardError:errorPipe];
        }
        
        @try {
            [rubyJobProcess2 launch];
            [rubyJobProcess2 waitUntilExit];
            //NSLog(@"nstask has stopped");
            
            if ([rubyJobProcess2 terminationStatus] != 0)
            {
               //[self setJobId:jobid status:70];
               [self removeJobFromCachedQueueWithStatus: 70 resultValue:@""];
                
                NSLog(@"something went wrong:error code %i",[rubyJobProcess2 terminationStatus]);
            }
            else
            {
                //check for returnFile and store in DB

                NSString *jobResultFile = [[[NSApp delegate] appSupportPath] stringByAppendingPathComponent: [NSString stringWithFormat:@"EngineRunner.%i.result",jobid]];

                if([[ NSFileManager defaultManager ] fileExistsAtPath:jobResultFile]){
                    NSString *resultValue = [NSString stringWithContentsOfFile: jobResultFile
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:NULL];
                    //[self setJobId:jobid status:10 result:resultValue];
                    [self removeJobFromCachedQueueWithStatus: 10 resultValue:resultValue];

                    [[ NSFileManager defaultManager ] removeItemAtPath:jobResultFile error:nil];
                }
                else
                {
                    [self removeJobFromCachedQueueWithStatus: 71 resultValue:@""];
                }
            }
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"dontWriteStdError"]) {
                NSLog(@"don't write to stdError");
            }
            else
            {
                NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
                NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
                NSString * jobStdErrorLogFile = [jobLogFolder stringByAppendingString:@"/error.log"];
                
                if([errorString length] > 0)
                {
                    [errorString writeToFile:jobStdErrorLogFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
                }
                
            }
        }
        
        @catch ( NSException *e ) {
            [self removeJobFromCachedQueueWithStatus: 67 resultValue:@""];
//            [self setJobId:jobid status:67];
        }
        
        NSLog(@"finished jobrun");
        
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
    
/*-(void)removeJobFromCachedQueueWithStatus: (int)status
{
    NSMutableDictionary *selectedJob = self.openJobs[0];
    [selectedJob setObject:[NSNumber numberWithInteger:status] forKey:@"status"];
    [self.openJobs removeObjectAtIndex:0];
    [self.closedJobs addObject:selectedJob];
}
*/
    
-(void)removeJobFromCachedQueueWithStatus: (int)status resultValue:(NSString*)resultValue
{
    if(self.loopIsEnabled)
    {
        if([self.openJobs count] > 0)
        {
            NSMutableDictionary *selectedJob = self.openJobs[0];
            [selectedJob setObject:[NSNumber numberWithInteger:status] forKey:@"status"];
            [selectedJob setObject:resultValue forKey:@"returnbody"];
            [self.openJobs removeObjectAtIndex:0];
            [self.closedJobs addObject:selectedJob];
        }
    }
}

    
-(void)writeClosedJobsToDb
{
    if(self.closedJobs)
    {
    
    NSLog(@"jobs write to db: %@",self.closedJobs);
    [self stopREFxLoop ];
    for (NSDictionary *job in self.closedJobs) {
        [self setJobId:[[job objectForKey:@"jobid"] integerValue] status:[[job objectForKey:@"status"] integerValue] result:[job objectForKey:@"returnbody"]];
    }
    [self.closedJobs removeAllObjects];
    [self startREFxLoop];
    }
}

-(long)selectJob
    {
        if(openJobs.count > 0)
        {
            //NSLog(@"openJobs %@", self.openJobs);
            NSMutableDictionary *selectedJob = self.openJobs[0];
            
            long attempt = [[selectedJob objectForKey:@"attempt"] integerValue];
            
            //check if we this job reached max attempts
            if([[NSUserDefaults standardUserDefaults] integerForKey:@"disableMaxAttempts"]==0)
            {
                if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] > 0 &&
                   [[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] <= [[selectedJob objectForKey:@"attempt"] integerValue])
                {
                    [self removeJobFromCachedQueueWithStatus:66 resultValue:@""];
                    return 0;
                }
            }

            [self.openJobs replaceObjectAtIndex:0 withObject:selectedJob];
            
            attempt = attempt + 1;
            [selectedJob setObject:[NSNumber numberWithInteger:attempt] forKey:@"attempt"];
            //NSLog(@"a: %@ b: %li", [selectedJob objectForKey:@"jobid"], [[selectedJob objectForKey:@"jobid"] integerValue]);
            return [[selectedJob objectForKey:@"jobid"] integerValue];
        }
        else if([self.closedJobs count] > 0)
        {
            [self setSlowTimer];
            [self writeClosedJobsToDb];
        }
        else
        {
            NSLog(@"start select");
            FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
            if (![db open]) {
                NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
                return 0;
            }
            
            int ret;
            ret = 0;
            int attempt;
            
            //db.traceExecution = YES;
            //db.logsErrors = YES;
            
            FMResultSet *rs = [db executeQuery:@"SELECT id, attempt FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1"];
            while ([rs next]) {
                
                ret = [rs intForColumn:@"id"];
                attempt = [rs intForColumn:@"attempt"];
                
                //[openJobs setObject:[NSNumber numberWithInteger:attempt] forKey: [NSString stringWithFormat:@"%i",ret]];
                
                NSMutableDictionary *jobInMem = [NSMutableDictionary dictionary];
                [jobInMem setObject:[NSNumber numberWithInteger:ret] forKey:@"jobid"];
                [jobInMem setObject:[NSNumber numberWithInteger:attempt] forKey:@"attempt"];

                NSLog(@"found open jobs %@", jobInMem);

                [self.openJobs addObject:jobInMem];
            }
            
            if(openJobs.count > 0)
            {
                [self setFastTimer];
            }
            
            
            
            [db close];
            
            NSLog(@"end select");
//            return 0;
        }
        return 0;
    }
    
-(int)selectJobOLD
{
    if(openJobs.count > 0)
    {
        NSLog(@"openJobs %@", self.openJobs);
    }
    
    NSLog(@"start select");
    FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
    if (![db open]) {
        NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
        return 0;
    }
    
    int ret;
    ret = 0;
    int attempt;
    
    //db.traceExecution = YES;
    //db.logsErrors = YES;
    
    FMResultSet *rs = [db executeQuery:@"SELECT id, attempt FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1"];
    while ([rs next]) {

        ret = [rs intForColumn:@"id"];
        attempt = [rs intForColumn:@"attempt"];
        
        //[openJobs setObject:[NSNumber numberWithInteger:attempt] forKey: [NSString stringWithFormat:@"%i",ret]];
        
        NSMutableDictionary *jobInMem = [NSMutableDictionary dictionary];
        [jobInMem setObject:[NSNumber numberWithInteger:attempt] forKey:@"attempt"];
        
        [openJobs addObject:jobInMem];
        
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
        NSLog(@"increasing %i",ret);
        [self increaseAttemts:ret];
    }

    
    NSLog(@"end select");
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
        
        int attempt = [db intForQuery:[NSString stringWithFormat:@"SELECT attempt FROM jobs WHERE id=%li",(long)jobid]];
        
        attempt = attempt +1;
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE jobs SET attempt = %i WHERE id=%li", attempt,  (long)jobid];
        NSLog(@"Exec: %@",  sql);
        
        if([db executeUpdate:sql])
        {
            NSLog(@"sql ok:%@",sql);
        }
        
        [db close];
    }
    
- (void)setJobId:(NSInteger)rowId status:(NSInteger)status result:(NSString*)result
    {
        FMDatabase *db = [FMDatabase databaseWithPath:railsDbPath];
        if (![db open]) {
            NSLog(@"FMDatabase Could not open db form path %@", railsDbPath);
            return;
        }
        
        //db.traceExecution = YES;
        //db.logsErrors = YES;
        
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE jobs SET status = %li, returnbody= '%@' WHERE id=%li", (long)status, result, (long)rowId];
        //NSLog(@"Exec: %@", sql);
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
    
    //db.traceExecution = YES;
    //db.logsErrors = YES;
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
    
    //NSLog(@"INSERT INTO jobs: %li", (long)rowId);
    
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
    
    //db.traceExecution = YES;
    //db.logsErrors = YES;
    
    //NSLog(@"INSERT TEST INTO jobs: %@", engine);
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'%@','%@',1,1,0,'');",engine,body];
    
    [db executeUpdate:sql];
    long newid = (long)[db lastInsertRowId];
    [db close];
    
    return newid;
}

@end
