//
//  REFxAppDelegate.m
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "REFx3AppDelegate.h"
#import "RXMainWindow.h"
#import "RXREFxIntance.h"
#import "RXJobPicker.h"
#import "RXRailsController.h"
#import "RXEngineManager.h"

#import "HTTPServer.h"
#import "RXHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation REFx3AppDelegate

@synthesize mainWindow;
@synthesize mainWindowController;
@synthesize preferencesController;
@synthesize refxInstance;
@synthesize LogWindowController;
@synthesize sharedEngineManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    sharedEngineManager = [[RXEngineManager alloc] init];
    [sharedEngineManager initEngineDirectory];
    
    NSLog(@"Starting Application with DBPATH: %@",[self sqlLitePath]);
    
    if (![refxInstance isKindOfClass:[RXREFxIntance class]]) {
        refxInstance = [[RXREFxIntance alloc] init];
    }
    
    self.mainWindowController = [[RXMainWindow alloc] initWithWindowNibName:@"RXMainWindow"];
    [self openMainWindow];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"startComServerAtStart"])
    {
        [refxInstance startComServer:[[NSUserDefaults standardUserDefaults] stringForKey:@"listenPort"]];
        [[mainWindowController startStopButtonCommunicationServer] setState:1];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxJobAttempts"] < 1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"maxJobAttempts"];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"startJobSchedulerAtStart"])
    {
        [refxInstance.jobPicker startREFxLoop];
        [[mainWindowController startStopButtonScheduler] setState:1];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"listenPort"] < 1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:3030 forKey:@"listenPort"];
    }
    NSLog(@"Test path is set: %@",[self testFolderPath]);
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNewWebserver"]) {
        [self startHTTPServer];
    }
}

- (void)startHTTPServer
{
	// Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	//[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
   	[httpServer setPort:[[NSUserDefaults standardUserDefaults] integerForKey:@"listenPort"]];
	
	// We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
	// This allows us to do all kinds of customizations.
	[httpServer setConnectionClass:[RXHTTPConnection class]];
	
	// Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
	
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}


- (void)openMainWindow {
    [self.mainWindowController showWindow:self];
}

-(IBAction)openMainWindowAction:(id)sender{
    [self openMainWindow];
}

-(IBAction)showPreferences:(id)sender{
    if(!self.preferencesController)
        self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
   
    [self.preferencesController showWindow:self];
}

-(IBAction)showLogWindow:(id)sender{
    if(!self.LogWindowController)
        self.LogWindowController = [[RXLogWindowController alloc] initWithWindowNibName:@"RXLogWindow"];
    
    [self.LogWindowController showWindow:self];
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{	
    if (flag) {
        return NO;
    } else {
        [self openMainWindow];
        return YES;
    }	
}



-(void)reinstallDatabase
{
    [refxInstance createDatabasesForceIfExist:YES];
}

- (NSString *)appSupportPath
{
    
    NSString * path = [NSString stringWithFormat: @"%@/Library/REFx4",NSHomeDirectory()];
    
    if(![[ NSFileManager defaultManager ] fileExistsAtPath:path]){
        [[ NSFileManager defaultManager ] createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error: NULL ];
    }
    return path;
}

- (NSString *)sqlLitePath
{
    NSString * path = [NSString stringWithFormat: @"%@/Database",[self appSupportPath]];
    NSLog(@"is this dbPath: %@",path);

    if(![[ NSFileManager defaultManager ] fileExistsAtPath:path]){
        NSLog(@"Creating dbPath: %@",path);
        [[ NSFileManager defaultManager ] createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error: NULL ];
    }
    return path;
}

- (NSString*) engineLogFilePath
{
    return [NSString stringWithFormat: @"%@/Library/Logs/REFx4/Engines.log",NSHomeDirectory()];
}

- (NSString *)jobLogFilePath
{
    
    NSString *fullPathString = [[[self applicationFilesDirectory] path] stringByAppendingPathComponent:@"JobsLogs"];
    
    if(![[ NSFileManager defaultManager ] fileExistsAtPath:fullPathString]){
        NSLog(@"Creating JobsLogs: %@",fullPathString);
        [[ NSFileManager defaultManager ] createDirectoryAtPath: fullPathString withIntermediateDirectories: YES attributes: nil error: NULL ];
    }
    
    return fullPathString;
}

- (NSString *)jobImportedJobsPath
{
    
    NSString *fullPathString = [[[self applicationFilesDirectory] path] stringByAppendingPathComponent:@"Import"];
    
    if(![[ NSFileManager defaultManager ] fileExistsAtPath:fullPathString]){
        NSLog(@"Creating ImportJobs: %@",fullPathString);
        [[ NSFileManager defaultManager ] createDirectoryAtPath: fullPathString withIntermediateDirectories: YES attributes: nil error: NULL ];
    }
    
    return fullPathString;
}

- (NSString *)testFolderPath
{
    
    NSString *fullPathString = [[[self applicationFilesDirectory] path] stringByAppendingPathComponent:@"TestJobs"];

    if(![[ NSFileManager defaultManager ] fileExistsAtPath:fullPathString]){
        NSLog(@"Creating testFolderPath: %@",fullPathString);
        [[ NSFileManager defaultManager ] createDirectoryAtPath: fullPathString withIntermediateDirectories: YES attributes: nil error: NULL ];
    }
    
    return fullPathString;
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "REFx4" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"REFx4"];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    [refxInstance.railsController stopComServer];
   
    return NSTerminateNow;
}

@end
