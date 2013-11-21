//
//  REFxAppDelegate.h
//  REFx
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"
#import "RXLogWindowController.h"
#import "RXEngineManager.h"

@class RXMainWindow;
@class RXREFxIntance;
@class RXEngineManager;

@interface REFx3AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *mainWindow;
@property (retain) RXMainWindow* mainWindowController;
@property (retain) PreferencesController *preferencesController;
@property (retain) RXLogWindowController *LogWindowController;

@property (retain) RXEngineManager *sharedEngineManager;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (retain) RXREFxIntance* refxInstance;

- (IBAction)showLogWindow:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (void)flushRailsLogs;
- (void)flushEngineLogs;

- (NSString *)appSupportPath;
- (NSString *)sqlLitePath;

- (NSString *)testFolderPath;
- (NSString *)jobLogFilePath;
- (NSString *)jobImportedJobsPath;
- (NSURL *)applicationFilesDirectory;
- (NSString *) engineLogFilePath;
- (void)reinstallDatabase;



@end
