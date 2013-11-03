//
//  MyController.h
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EngineWindowController.h"

@class EngineTextCell;
//@class EngineWindowController;



@interface EngineListingController : NSObject {
	
	NSMutableArray * nsMutaryOfMyData;
	EngineTextCell * myImageAndTextCelObj;
	
	IBOutlet NSTableView * nsTableViewObj;
}
@property (assign) NSMutableArray * nsMutaryOfMyData;
@property (assign) EngineTextCell * myImageAndTextCelObj;
@property (assign) IBOutlet NSTableView * nsTableViewObj;
@property (retain) EngineWindowController *engineWindow;


//- (IBAction)tableViewSelected:(id)sender;

- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)addToEndOfTable:(id)pId;
- (IBAction)removeCellAtSelectedRow:(id)sender;
- (IBAction)reloadEngines:(id)sender;
- (IBAction)runAllDefaultEngineTests:(id)sender;



@end
