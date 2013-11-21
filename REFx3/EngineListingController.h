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



@interface EngineListingController : NSObject

@property (retain) NSMutableArray * nsMutaryOfMyData;
@property (retain) EngineTextCell * myImageAndTextCelObj;
@property (retain) IBOutlet NSTableView * nsTableViewObj;
@property (retain) EngineWindowController *engineWindow;


/*- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)addToEndOfTable:(id)pId;
- (IBAction)removeCellAtSelectedRow:(id)sender;
*/
- (IBAction)reloadEngines:(id)sender;
- (IBAction)runAllDefaultEngineTests:(id)sender;



@end
