//
//  MyController.h
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//@class MyNSCell;
@class EngineTextCell;


@interface EngineListingController : NSObject {
	
	NSMutableArray * nsMutaryOfMyData;
	EngineTextCell * myImageAndTextCelObj;
	
	IBOutlet NSTableView * nsTableViewObj;
}
@property (assign) NSMutableArray * nsMutaryOfMyData;
@property (assign) EngineTextCell * myImageAndTextCelObj;
@property (assign) IBOutlet NSTableView * nsTableViewObj;

//- (IBAction)tableViewSelected:(id)sender;

- (IBAction)addAtSelectedRow:(id)pId;
- (IBAction)addToEndOfTable:(id)pId;
- (IBAction)removeCellAtSelectedRow:(id)sender;


@end
