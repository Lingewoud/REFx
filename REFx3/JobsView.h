//
//
//  Created by Pim Snel on 01-10-12.
//  Copyright (c) 2012 Pim Snel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VDKQueue.h"

// Define the following preprocessor macros
//#define LOG_RELOAD_ACTIVITY
//#define EXPERIMENTAL_STUFF

// Define the following class interface
@interface JobsView : NSObject <VDKQueueDelegate,NSTableViewDataSource>
{
	// -- outlet properties
	IBOutlet NSTableView	*testTable;
    IBOutlet NSPanel        *testPanel;
    IBOutlet NSTextView     *panelTextField;
    
    IBOutlet NSTextField    *jobsNumTotal;
    IBOutlet NSTextField    *jobsNumError;
    IBOutlet NSTextField    *jobsNumPauzed;
    IBOutlet NSTextField    *jobsNumNew;
    
    
    
    
    IBOutlet NSWindow       *JobRecordWindow;
    IBOutlet NSTextField    *JobRecordTextFieldId;
    IBOutlet NSTextField    *JobRecordTextFieldEngineName;
    IBOutlet NSTextField    *JobRecordTextFieldMethod;
    IBOutlet NSTextField    *JobRecordTextFieldPriority;
    IBOutlet NSTextField    *JobRecordTextFieldStatus;
    IBOutlet NSTextField    *JobRecordTextFieldLastUpdate;
    IBOutlet NSTextField    *JobRecordTextFieldAttempts;
    IBOutlet NSTextView     *JobRecordTextViewInputParam;
    IBOutlet NSTextView     *JobRecordTextViewResult;
    IBOutlet NSTextView     *JobRecordTextViewLogEngine;
    //IBOutlet NSTextView     *JobRecordTextViewLogOutput;
    IBOutlet NSTextView     *JobRecordTextViewLogError;
    IBOutlet NSButton       *OpenDestinationFolder;
    //NSString                *absoluteDestinationPath;
    
	// private properties
	@private
    NSString * dbPath;
    NSTimer * tableUpdateTimer;
    
}

@property (nonatomic,retain) NSMutableDictionary	*testBuffer;
@property (nonatomic,retain) NSString	*absoluteDestinationPath;

// -- accessor methods
- (NSDictionary *)testBuffer;
- (NSTableView *)testTable;
- (NSDictionary *)getData;

// -- modifier methods
- (void)setData:(NSDictionary *)aDat;
- (IBAction)resetJob:(id)sender;
- (IBAction)refreshTable:(id)sender;
- (IBAction)pauzeJob:(id)sender;
- (IBAction)deleteJob:(id)sender;
- (IBAction)viewBody:(id)sender;
- (IBAction)openDestinationFolderAction:(id)sender;






@end
