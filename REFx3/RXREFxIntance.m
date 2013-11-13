//
//  RXREFxIntance.m
//  REFx
//
//  Created by W.A. Snel on 17-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXREFxIntance.h"
#import "RXJobPicker.h"
#import "RXRailsController.h"

#import "REFx3AppDelegate.h"

#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/param.h>

#include <sys/sysctl.h>
#include <string.h>
#include <stdlib.h>

@implementation RXREFxIntance

@synthesize jobPicker;
@synthesize railsController;
@synthesize railsPort;


// init instanciated the JobPicker and the RailsController
- (id)init
{
    self = [super init];
    if (self) {
       
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useWorkingCopy"]) {
            
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            
            NSString *altDir = [[ NSUserDefaults standardUserDefaults] stringForKey:@"altRailsRootDir"];
            if([fileManager fileExistsAtPath:altDir]){            
                railsRootDir = altDir;
            }
            else {
                NSLog(@"rails path does not exist %@. Check alternative rails path in development preferences",altDir);            
            }
            
            [fileManager release];
        } 
        else {
            railsRootDir = [[[NSBundle mainBundle] 
                             bundlePath] 
                            stringByAppendingString:@"/Contents/Resources/REFx-rails-framework"];      
        }

        AppSupportDir = [[NSApp delegate] appSupportPath];
        NSLog(@"App Support Dir %@", AppSupportDir);
       
        railsEnvironment=@"production";
        
        //FIXME REMOVE AND USE DB
        dbPath = [AppSupportDir stringByAppendingString:@"/Database/refx4production.sqlite3"];

        [self writeDbRailsConfig];
        [self createDatabasesForceIfExist:NO];

        NSLog(@"rails path %@",railsRootDir);
        
        //instanciating the JobPicker 
        jobPicker = [[RXJobPicker alloc] initWithDbPath: dbPath railsRootDir: railsRootDir environment:railsEnvironment];

        //instanciating the RailsController 
        railsController = [[RXRailsController alloc] initWithRailsRootDir: railsRootDir];    


    }
    
    return self;
}

- (void) writeDbRailsConfig
{
    NSString *dbConfFile = [NSString stringWithFormat: @"production:\n   adapter: sqlite3\n   database: %@\n   pool: 5\n   timeout: 5000", dbPath];
    NSString *fileName = [NSString stringWithFormat:@"%@/config/database.yml",railsRootDir];

    [dbConfFile writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
}

- (NSString*) getRailsEnvironment
{
    return railsEnvironment;
}

-(NSString*) getDbPath{
    return dbPath;
}

-(NSString*) railRootDir {
    return railsRootDir;
}

- (void) startComServer:(NSString*)port {
    if(![port intValue]) {
        NSLog(@"ERROR: No port set");
    }
    
    [railsController startComServer:port :railsEnvironment];
}

//create production database
- (void) createDatabasesForceIfExist: (BOOL)force
{
    //NSFileManager *fileManager = [[NSFileManager alloc] init];
        
/*    if(force)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
        {
            NSError * error;
            [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
            if (error.code != NSFileNoSuchFileError) {
                NSLog(@"%@", error);
            }
        }
    }
  */  
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){

        NSLog(@"creating database at:%@", dbPath);

        NSTask *ps = [[NSTask alloc] init];
        [ps setLaunchPath:@"/bin/sh"];
        
        NSString *cmd = [NSString stringWithFormat:@"cd %@ && rake db:migrate RAILS_ENV=\"production\" 2>&1", railsRootDir];
        
        NSMutableArray *args = [[NSMutableArray alloc] init];
        [args addObject:@"-c"];
        [args addObject:cmd];
        
        [ps setArguments:args];
        [ps waitUntilExit];
        [ps launch];
        
        [ps release];
        
    }
}


-(void)flushRailsLogs{
    //return;
    
    NSTask *ps = [[NSTask alloc] init];
    [ps setLaunchPath:@"/bin/sh"];
    
    NSString *cmd = [NSString stringWithFormat:@"cd %@ && rake log:clear RAILS_ENV=\"production\"", railsRootDir];
    
    NSMutableArray *args = [[NSMutableArray alloc] init];
    [args addObject:@"-c"];
    [args addObject:cmd];
    
    [ps setArguments:args];
    //[ps waitUntilExit];
    [ps launch];
    
    [ps release];
}



- (void) dealloc {
    railsRootDir = nil;
    dbPath = nil;
    
    jobPicker = nil;
    railsController = nil;
    [super dealloc];
}

@end
