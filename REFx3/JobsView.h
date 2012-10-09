//
//  DemoView.h
//  Cocoa Sqlite Example
//
//  Created by Pim Snel on 01-10-12.
//  Copyright (c) 2012 Pim Snel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Define the following preprocessor macros
//#define LOG_RELOAD_ACTIVITY
//#define EXPERIMENTAL_STUFF

// Define the following class interface
@interface JobsView : NSObject
{
	// -- outlet properties
	IBOutlet NSTableView	*testTable;
    IBOutlet NSPanel        *testPanel;
    IBOutlet NSTextView    *panelTextField;
    
	// private properties
	@private
    NSString * dbPath;
    
}


@property (nonatomic,retain) NSMutableDictionary	*testBuffer;

//@property (assign) IBOutlet NSWindow *window;

// -- accessor methods
- (NSDictionary *)testBuffer;
- (NSTableView *)testTable;
- (NSDictionary *)getData;

// -- modifier methods
- (void)setData:(NSDictionary *)aDat;
- (IBAction)resetJob:(id)sender;
- (IBAction)refreshTable:(id)sender;
- (IBAction)deleteJob:(id)sender;
- (IBAction)viewBody:(id)sender;
- (IBAction)returnBody:(id)sender;





@end
