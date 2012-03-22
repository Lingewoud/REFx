//
//  RXREFxIntance.m
//  REFx3
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
    self = [super init];
    if (self) {
       
        BOOL useWorkingCopyRailsDir = NO;        

        if(useWorkingCopyRailsDir) {
            railsRootDir = @"/Users/pim/Sites/CornerstoneWorkingCopies/REFx3/REFx-rails-framework/";          
        }
        else {
            railsRootDir = [[[NSBundle mainBundle] 
                             bundlePath] 
                            stringByAppendingString:@"/Contents/Resources/REFx-rails-framework"];        
        }

        dbPath = [railsRootDir stringByAppendingString:@"/db/development.sqlite3"];

        NSLog(@"rails path %@",railsRootDir);
        
        //instanciating the JobPicker 
        jobPicker = [[RXJobPicker alloc] initWithDbPath: dbPath railsRootDir: railsRootDir ];

        //instanciating the RailsController 
        railsController = [[RXRailsController alloc] initWithRailsRootDir: railsRootDir];    

        [self checkAppScript];
    }
    
    return self;
}

- (void) startComServer:(NSString*)port {
    if(![port intValue]) {
        port = @"3030";
    }
    [railsController startComServer:port];
    
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

    return [[stringArray objectAtIndex: 0] intValue];
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
        
        NSLog(@"Authorization Start SnowLeopard/Lion");
        NSFileManager *fileManager = [[NSFileManager alloc] init];
//        NSString *mypath = [NSString stringWithFormat:@"/Library/Ruby/Site/1.8/universal-darwin%i.0/sqlite3",darwinVer];

        //NSLog(@"success%@",mypath);
        
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
     
/*    if(![fileManager fileExistsAtPath:@"/Library/Ruby/Site/1.8/universal-darwin11.0/ae.bundle"]){

        AuthorizationRef authorizationRef;
        OSStatus status;
        
        status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,kAuthorizationFlagDefaults, &authorizationRef);

        NSString* installAppScriptScriptTmp = [railsRootDir stringByAppendingString:@"/lib/refxPrerequisitesInstall.sh"];
        const char *installTool = [installAppScriptScriptTmp UTF8String];
        char *tool_args[] = {};
        //[installAppScriptScriptTmp release];
        
        status = AuthorizationExecuteWithPrivileges(authorizationRef, installTool,kAuthorizationFlagDefaults, tool_args, NULL);
        
        NSLog(@"Authorization Result Code: %d", status);
        // Check for status TODO
    }
 */
     
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
