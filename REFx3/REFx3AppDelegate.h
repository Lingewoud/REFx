//
//  REFx4AppDelegate.h
//  REFx4
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
@property (assign) IBOutlet NSTextField *lastJobid;
@property (retain) RXMainWindow* mainWindowController;
@property (retain) PreferencesController *preferencesController;
@property (retain) RXLogWindowController *LogWindowController;

@property (retain) RXEngineManager *sharedEngineManager;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (assign) RXREFxIntance* refxInstance;

-(IBAction)showLogWindow:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)setLastJobId:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)openTestJobsFolder:(id)sender;
- (IBAction)insertTestJobIndexIndesignFranchise:(id)sender;
- (IBAction)insertTestJobGenerateIndesignFranchise:(id)sender;
- (IBAction)insertTestJobIndexIndesignFranchiseOpenIndd:(id)sender;
- (IBAction)insertTestJobIndexIndesignFranchiseOpenInddCS6:(id)sender;

- (void)flushLogs;
- (void)refreshJobMgr;

- (NSString *)appSupportPath;
- (NSString *)testFolderPath;
- (NSURL *)applicationFilesDirectory;
- (NSString *) engineLogFilePath;


@end
