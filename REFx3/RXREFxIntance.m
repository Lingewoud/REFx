//
//  RXREFxIntance.m
//  REFx4
//
//  Created by W.A. Snel on 17-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXREFxIntance.h"
#import "RXJobPicker.h"
#import "RXRailsController.h"



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
    
    //TODO
    //Show loading screen and hide when finished
    
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

        AppSupportDir = @"/Library/Application Support/REFx4";
       
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useDevelopmentEnvironment"]) {
            railsEnvironment=@"development";
            dbPath = [AppSupportDir stringByAppendingString:@"/Database/refx4development.sqlite3"];
        } 
        else {
            railsEnvironment=@"production";
            dbPath = [AppSupportDir stringByAppendingString:@"/Database/refx4production.sqlite3"];
        }
    
        [self checkAppScript];
        [self checkAppSupportDir];
        NSLog(@"rails path %@",railsRootDir);
        
        
        //instanciating the JobPicker 
        jobPicker = [[RXJobPicker alloc] initWithDbPath: dbPath railsRootDir: railsRootDir environment:railsEnvironment];

        //instanciating the RailsController 
        railsController = [[RXRailsController alloc] initWithRailsRootDir: railsRootDir];    


    }
    
    return self;
}

-(NSString*) getDbPath{
    return dbPath;
}

- (void) startComServer:(NSString*)port {
    if(![port intValue]) {
        NSLog(@"ERROR: No port set");
    }
    
    [railsController startComServer:port :railsEnvironment];
    
}

- (int) darwinVersion
{
    int mib[2];
    size_t len;
    char *kernelVersion;
    
    // Get the kernel's version as a string called "kernelVersion":
    mib[0] = CTL_KERN;
    mib[1] = KERN_OSRELEASE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    kernelVersion = malloc(len * sizeof(char));
    sysctl(mib, 2, kernelVersion, &len, NULL, 0);
    
    NSString *myString = [NSString stringWithUTF8String: kernelVersion];    
    NSArray *stringArray = [myString componentsSeparatedByString:@"."];
    
    free(kernelVersion);

    return [[stringArray objectAtIndex: 0] intValue];
}

- (void) checkAppSupportDir
{
    NSLog(@"Authorization Start for Application Support Dir");
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(![fileManager fileExistsAtPath:AppSupportDir]){
        
        NSDictionary *error = [NSDictionary new]; 
        
        NSString *installScriptTmp = [railsRootDir stringByAppendingString:@"/lib/refxAppSupportDirectory.sh"];
        NSString *script = [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", installScriptTmp];  
        
        NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script]; 
        if ([appleScript executeAndReturnError:&error]) {
            NSLog(@"success!"); 
        } else {
            NSLog(@"failure!"); 
        }
    }
    [fileManager release];
    
    //now create the databases
    [self createDatabases];
}

//create development and production database
- (void) createDatabases
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
        
    if(![fileManager fileExistsAtPath:[AppSupportDir stringByAppendingString:@"/Database/refx4production.sqlite3"]]){

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
    
    if(![fileManager fileExistsAtPath:[AppSupportDir stringByAppendingString:@"/Database/refx4development.sqlite3"]]){
        
        NSTask *ps = [[NSTask alloc] init];
        [ps setLaunchPath:@"/bin/sh"];
        
        NSString *cmd = [NSString stringWithFormat:@"cd %@ && rake db:migrate RAILS_ENV=\"development\" 2>&1", railsRootDir];
        
        NSMutableArray *args = [[NSMutableArray alloc] init];
        [args addObject:@"-c"];
        [args addObject:cmd];
        
        [ps setArguments:args];
        [ps waitUntilExit];
        [ps launch];
        
        [ps release];
    }
    
    [fileManager release];

}


-(void)flushLogs{
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

// checkAppScript checks if the appscript binary are installed. If not it tries to install
- (void) checkAppScript
{
    
    int darwinVer = [self darwinVersion];
    
    if(darwinVer < 10)
    {
        NSLog(@"Authorization Start Leopard");
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if(![fileManager fileExistsAtPath:[railsRootDir stringByAppendingString:@"/vendor/gems/rb-appscript-0.5.1"]]){

            NSDictionary *error = [NSDictionary new]; 
            
            NSString *installAppScriptScriptTmp = [railsRootDir stringByAppendingString:@"/lib/refxPrerequisitesInstallLeopard.sh"];
            NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", installAppScriptScriptTmp];  
            
            NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script]; 
            if ([appleScript executeAndReturnError:&error]) {
                NSLog(@"success!"); 
            } else {
                NSLog(@"failure!"); 
            }
        }
        [fileManager release];

    } else {
        
        NSLog(@"Authorization Start SnowLeopard/Lion/MountainLion");
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *mypath = [NSString stringWithFormat:@"/Library/Ruby/Site/1.8/universal-darwin%i.0/sqlite3",darwinVer];

        NSLog(@"success%@",mypath);
        
        if(![fileManager fileExistsAtPath: [NSString stringWithFormat:@"/Library/Ruby/Site/1.8/universal-darwin%i.0/ae.bundle",darwinVer]] ||
           ![fileManager fileExistsAtPath: [NSString stringWithFormat:@"/Library/Ruby/Site/1.8/universal-darwin%i.0/sqlite3",darwinVer]]){
            
            NSDictionary *error = [NSDictionary new]; 
            
            NSString *installAppScriptScriptTmp = [railsRootDir stringByAppendingString:@"/lib/refxPrerequisitesInstall.sh"];
            NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", installAppScriptScriptTmp];  
            
            NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script]; 
            if ([appleScript executeAndReturnError:&error]) {
                NSLog(@"success!"); 
            } else {
                NSLog(@"failure!"); 
            }
        }
        [fileManager release];
    }
}

-(NSString*) railRootDir {
    return railsRootDir;
}

- (void) dealloc {
    railsRootDir = nil;
    dbPath = nil;
    
    jobPicker = nil;
    railsController = nil;
    [super dealloc];
}

@end
