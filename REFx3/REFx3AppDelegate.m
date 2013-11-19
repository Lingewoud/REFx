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

-(void)flushRailsLogs
{

}

-(void)flushEngineLogs
{
    NSString * empty = [NSString stringWithFormat:@""];
    [empty writeToFile:[self engineLogFilePath]
                 atomically:NO
                   encoding:NSStringEncodingConversionAllowLossy
                      error:nil];
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

    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"REFx4"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"REFx4" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"REFx4.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    //stop the RAILS Server when application stop
    [refxInstance.railsController stopComServer];
   
    
    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}



- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    
    [preferencesController release];
    [mainWindowController release];

    [super dealloc];
}

@end
