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
//#import "YAML/YAMLSerialization.h"

@implementation RXJobPicker

- (id)initWithDbPath: dbPath railsRootDir: dir environment:(NSString*) env
{
    self = [super init];
    if (self) {
        NSLog(@"init jobpicker");

        railsDbPath = dbPath;
        [self openDatabase];
        railsRootDir = dir;
        railsEnvironment = env;
    }
    
    return self;
}



- (void)startREFxLoop
{
    NSLog(@"start scheduler...");
    refxTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                 target: self
                                               selector: @selector(loopSingleAction)
                                               userInfo: nil
                                                repeats: YES];
}

- (void)stopREFxLoop
{
    NSLog(@"stop scheduler...");
    [refxTimer invalidate];
}


- (void)loopSingleAction
{
    if([rubyJobProcess isRunning])
    {
        return;
    }
    
    int jobid = [self selectJob];
    
    if(jobid != 0 && jobRunning == NO)
    {
        jobRunning = YES;
        
        NSLog(@"DISPATCHING JOBID %i",jobid);
        
        NSString *jobidString = [NSString stringWithFormat:@"%i",jobid];
        
        //get engine name
        NSString * engine = [self getJobEngine:jobid];
        //get bundle location
        
        
        NSString *runnerPath = [NSString stringWithFormat:@"%@/Contents/Resources/RubyEngineRunner/RubyEngineRunner.rb", [[NSBundle mainBundle] bundlePath]];
        NSString *enginePath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/main.rb", [[NSApp delegate ]engineDirectoryPath ],engine];
        NSString *engineDir = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/", [[NSApp delegate ]engineDirectoryPath ],engine];

        NSLog(@"ENGINEPATH %@",enginePath);
        rubyJobProcess = [[NSTask alloc] init];
        
        [rubyJobProcess setCurrentDirectoryPath:engineDir];
        [rubyJobProcess setLaunchPath: enginePath];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
        {
            NSLog(@"REFx4: debugmode on");
            [rubyJobProcess setArguments: [NSArray arrayWithObjects:runnerPath,
                                           @"-j",jobidString,
                                           @"-d",
                                           @"--environment",railsEnvironment,
                                           nil]];
        }
        else{
            NSLog(@"REFx4: debugmode on");
            [rubyJobProcess setArguments: [NSArray arrayWithObjects:runnerPath,
                                           @"-j",jobidString,
                                           @"--environment",railsEnvironment,
                                           nil]];
        }
        [rubyJobProcess launch];
        
        NSLog(@"Return from JOBID %i",jobid);
        
        jobRunning = NO;
    }

}


- (void)loopSingleActionOLD
{
    
    if([rubyJobProcess isRunning])
    {
        return;
    }
    
    int jobid = [self selectJob];
    
    if(jobid != 0 && jobRunning == NO)
    {
        NSLog(@"loop single action: %@",[self getJobEngine:jobid]);

        jobRunning = YES;

        NSLog(@"DISPATCHING JOBID %i",jobid);
        
        NSString *jobidString = [NSString stringWithFormat:@"%i",jobid];
        NSString *railsCommand = [NSString stringWithFormat:@"%@/script/runner", railsRootDir];
        rubyJobProcess = [[NSTask alloc] init];    
        
        [rubyJobProcess setCurrentDirectoryPath:railsRootDir];
        [rubyJobProcess setLaunchPath: railsCommand];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
        {
            NSLog(@"REFx4: debugmode on");
            [rubyJobProcess setArguments: [NSArray arrayWithObjects:@"lib/refxJobWrapper.rb",
                                           @"-j",jobidString,
                                           @"-d",
                                           @"--environment",railsEnvironment,
                                           nil]];
        }
        else{
            [rubyJobProcess setArguments: [NSArray arrayWithObjects:@"lib/refxJobWrapper.rb",
                                           @"-j",jobidString,
                                           @"--environment",railsEnvironment,
                                           nil]];
        }
        [rubyJobProcess launch];
        
        NSLog(@"Return from JOBID %i",jobid);
         
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
    
    //NSLog(@"select new job");
    
    sqlite3_stmt    *statement;
    
    NSString *sql = [NSString stringWithFormat: @"SELECT engine FROM jobs WHERE id = %i", jobId];
    const char *query_stmt = [sql UTF8String];
    
    //NSString * ret;
    NSString *ret = nil;
    
    if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int result = sqlite3_step(statement);
        if(result == SQLITE_ROW)
        {
            ret = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 0)];

            //ret = sqlite3_column_value(statement, 0);

        }
/*        else
        {
            ret = @"";
        }
 */
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
    
    //NSLog(@"select new job");
    
    sqlite3_stmt    *statement;
    
    NSString *sql = @"SELECT id,priority,engine,body,status,max_attempt,attempt,returnbody FROM jobs WHERE status > 0 AND status < 10 ORDER BY jobs.priority DESC LIMIT 1";
    const char *query_stmt = [sql UTF8String];
    
    int ret;
    //ret = 0;    
    
    if (sqlite3_prepare_v2(db, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        int result = sqlite3_step(statement);
        if(result == SQLITE_ROW)
        {
            ret = sqlite3_column_int(statement, 0);
        }
        else
        {
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

- (void)setJobId:(NSInteger)rowId status:(NSInteger)status
{
    return;
    
    if(dbOpened)
    {
        NSLog(@"increase attempt");
        
        sqlite3_stmt *statement;
        
        NSString *sql = [NSString stringWithFormat: @"UPDATE jobs SET status = %i WHERE id=%i", status, rowId];
        
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
        
  
        
      //  NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (id,priority,engine,body,status,max_attempt,attempt,returnbody) value(%i,0,'MARKER','MARKER',10,1,1,'MARKER')", rowId];
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (id,engine,body) values (%i,'MARKER','MARKER');", rowId];  

        
     //   NSLog(@"SQL: @%", sql);
//        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (id) values (%i);", rowId];
        
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


- (void) insertTestJobwithEngine:(NSString*)engine body:(NSString*)body
{
    if(dbOpened)
    {
        sqlite3_stmt *statement;
                
//        NSString *jobBody = [NSString stringWithFormat: @"%@",body];
        
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
}

- (void) insertTestJobSayWhat
{
    
    if(dbOpened)
    {      
        sqlite3_stmt *statement;
        
        NSString * testJobPath = [[NSApp delegate] testFolderPath];
        
        NSString *jobBody = [NSString stringWithFormat: @"---\n"
                             "init_args: \n"
                             "  - \n"
                             "    value: %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Say What? PAS3 says hello.\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: fileadmin/pas3/guidedAssets\n"
                             "    type: string\n"
                             "method: say\n"
                             "method_args: \n"
                             "  - \n"
                             "    value: Say What? PAS3 says hello.\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Victoria\n"
                             "    type: string\n"
                             ,testJobPath];
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'P3Saywhat','%@',1,1,0,'');",jobBody];  
        
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
}



- (void) insertTestJobGenerateIndesignFranchise
{
    
    if(dbOpened)
    {      
        sqlite3_stmt *statement;
        
        NSString * testJobPath = [[NSApp delegate] testFolderPath];
        
        NSString *jobBody = [NSString stringWithFormat: @"---\n"
                             "init_args: \n"
                             "  - \n"
                             "    value: %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: >\n"
                             "      input/pas3visitekaartjeCS4.indd\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: uploads/tx_p3ga\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Adobe InDesign CS4\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: true\n"
                             "    type: bool\n"
                             "method: getFinalPreview\n"
                             "method_args: \n"
                             "  - \n"
                             "    value: >\n"
                             "      PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPGRvY3VtZW50IHNwcmVhZF9jb3VudD0iMSIgcGFnZV9jb3VudD0iMSIgaHRtbF9wcmV2PSJ1cGxvYWRzL3R4X3AzZ2EvNDIxL3BhZ2VfMV8xLnBuZyIgPgo8c3ByZWFkcyA+CjxzcHJlYWQyMTUgcGFnZV9jb3VudD0iMSIgaW5kZXg9IjEiIGlkPSIyMTUiID4KPHBhZ2VzID4KPHBhZ2UyMjIgc291cmNlSWQ9IjIyMiIgcHJldmlldz0idXBsb2Fkcy90eF9wM2dhLzQyMS9wYWdlXzFfMS5wbmciIGlkPSIyMjIiIHNpZGU9InNpbmdsZSIgaHRtbF9wcmV2PSJ1cGxvYWRzL3R4X3AzZ2EvNDIxL3BhZ2VfMV8xLnBuZyIgPgo8bGF5ZXJHcm91cHMgPgo8Z3JvdXAwMCA+CjxsYXllcjE2MyBwcmV2aWV3PSJ1cGxvYWRzL3R4X3AzZ2EvNDIxL3BhZ2VfMV8xX2xheWVyMTYzLnBuZyIgbGF5ZXJJRD0iMTYzIiBodG1sX3ByZXY9InVwbG9hZHMvdHhfcDNnYS80MjEvcGFnZV8xXzFfbGF5ZXIxNjMucG5nIiAvPgoKPC9ncm91cDAwPgo8Z3JvdXAwMSA+CjxsYXllcjIxMCBwcmV2aWV3PSJ1cGxvYWRzL3R4X3AzZ2EvNDIxL3BhZ2VfMV8xX2xheWVyMjEwLnBuZyIgbGF5ZXJJRD0iMjEwIiBodG1sX3ByZXY9InVwbG9hZHMvdHhfcDNnYS80MjEvcGFnZV8xXzFfbGF5ZXIyMTAucG5nIiAvPgoKPC9ncm91cDAxPgo8Z3JvdXAwMiA+CjxsYXllcjUzNiBsYXllcklEPSI1MzYiIC8+Cgo8L2dyb3VwMDI+Cgo8L2xheWVyR3JvdXBzPgoKPC9wYWdlMjIyPgoKPC9wYWdlcz4KCjwvc3ByZWFkMjE1PgoKPC9zcHJlYWRzPgoKPC9kb2N1bWVudD4K\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: NewspaperAds_1v4_IND4rini\n"
                             "    type: string\n",testJobPath];
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'P3Indesignfranchise','%@',1,1,0,'');",jobBody];  
        
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
}

- (void) insertTestJobIndexIndesignFranchiseOpenIndd
{
    
    int i; // Loop counter.
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    
    NSString* fileName;
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            fileName = [files objectAtIndex:i];
            
            // Do something with the filename.
        }
    }
    
    //NSLog(@"filename %@",fileName);
    
    
    
    if(dbOpened)
    {
        sqlite3_stmt *statement;
        
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString * testJobPath = [fileName stringByDeletingLastPathComponent];
        
        if(![fileManager fileExistsAtPath:[testJobPath stringByAppendingString:@"/REFx4Jobs"]]){
            
            [fileManager createDirectoryAtPath:[testJobPath stringByAppendingString:@"/REFx4Jobs"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [fileManager release];
                
        NSString *jobBody = [NSString stringWithFormat: @"---\n"
                             "init_args: \n"
                             "  - \n"
                             "    value: %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: >\n"
                             "      %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: REFx4Jobs\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Adobe InDesign CS4\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: false\n"
                             "    type: bool\n"
                             "method: getXML\n"
                             "method_args: \n",testJobPath,[fileName lastPathComponent]];
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'P3Indesignfranchise','%@',1,1,0,'');",jobBody];
        
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
}

- (void) insertTestJobIndexIndesignFranchiseOpenInddCS6
{
    
    int i; // Loop counter.
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    
    NSString* fileName;
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg filenames];
        
        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            fileName = [files objectAtIndex:i];
            
            // Do something with the filename.
        }
    }
                

    if(dbOpened)
    {      
        sqlite3_stmt *statement;
        

        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString * testJobPath = [fileName stringByDeletingLastPathComponent];

        if(![fileManager fileExistsAtPath:[testJobPath stringByAppendingString:@"/REFx4Jobs"]]){

            [fileManager createDirectoryAtPath:[testJobPath stringByAppendingString:@"/REFx4Jobs"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [fileManager release];
        
        NSString *jobBody = [NSString stringWithFormat: @"---\n"
                             "init_args: \n"
                             "  - \n"
                             "    value: %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: >\n"
                             "      %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: REFx4Jobs\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Adobe InDesign CS6\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: false\n"
                             "    type: bool\n"
                             "method: getXML\n"
                             "method_args: \n",testJobPath,[fileName lastPathComponent]];
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'P3Indesignfranchise','%@',1,1,0,'');",jobBody];  
        
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
}


- (void) insertTestJobIndexIndesignFranchise
{

    if(dbOpened)
    {      
        sqlite3_stmt *statement;
       
        NSString * testJobPath = [[NSApp delegate] testFolderPath];
        
        NSString *jobBody = [NSString stringWithFormat: @"---\n"
                             "init_args: \n"
                             "  - \n"
                             "    value: %@\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: >\n"
                             "      input/pas3visitekaartjeCS4.indd\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: uploads/tx_p3ga\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: Adobe InDesign CS4\n"
                             "    type: string\n"
                             "  - \n"
                             "    value: false\n"
                             "    type: bool\n"
                             "method: getXML\n"
                             "method_args: \n",testJobPath];
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO jobs (priority,engine,body,status,max_attempt,attempt,returnbody) values (1,'P3Indesignfranchise','%@',1,1,0,'');",jobBody];  
        
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
