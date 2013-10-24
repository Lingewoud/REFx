//
//  MyController.m
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import "EngineListingController.h"
#import "EngineData.h"
#import "EngineTextCell.h"
#import "REFx3AppDelegate.h"
#import "EngineWindowController.h"

@implementation EngineListingController
@synthesize nsMutaryOfMyData;
@synthesize nsTableViewObj;
@synthesize myImageAndTextCelObj;

- (void) awakeFromNib {
    
    [self loadEngines];
}

- (void) loadEngines
{
    self.nsMutaryOfMyData = [[NSMutableArray alloc] init];
    
    for (NSString *eName in [[[NSApp delegate] sharedEngineManager] enginesEnabledArray]) {
        
        NSString *engineName = [[NSString alloc] initWithString: eName];
        
        [self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString: [[NSBundle mainBundle] pathForResource:@"engineicon" ofType:@"png"]                                                                              text:engineName]];
    }
	
	self.myImageAndTextCelObj = [[EngineTextCell alloc] init];
	self.myImageAndTextCelObj.image = [[self.nsMutaryOfMyData objectAtIndex:0]nsImageObj];
	[self.myImageAndTextCelObj setEditable: NO];
    [self.nsTableViewObj setTarget: self];
    
    [self.nsTableViewObj setDoubleAction:@selector(doubleClickInTableView:)];
    
	NSTableColumn* zTableColumnObj = [[self.nsTableViewObj tableColumns] objectAtIndex:0];
	[zTableColumnObj setDataCell: self.myImageAndTextCelObj];

}

- (IBAction)reloadEngines:(id)sender
{
    [self loadEngines];
    [self.nsTableViewObj reloadData];
}

-(void) doubleClickInTableView:(id)sender
{
    NSInteger row = [nsTableViewObj clickedRow];
    NSInteger column = [nsTableViewObj clickedColumn];
    //NSLog(@"open engine panel %@",[self tableView:nsTableViewObj objectValueForTableColumn:column row:row]);
    
    EngineWindowController *engineWindow = [[EngineWindowController alloc] initWithWindowNibName:@"EngineWindow"];

    [engineWindow setWindowEngineName:[self tableView:nsTableViewObj objectValueForTableColumn:column row:row]];
    [engineWindow showWindow:self];
}

// these are called by the table(s)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)pTableView
{
	NSLog(@"numberOfRowsInTableView ary count = %lu",[nsMutaryOfMyData count]);
	return [nsMutaryOfMyData count];
	
} // end numberOfRowsInTableView


- (id)tableView:(NSTableView *)pTableView objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRow {

	EngineData * zMyDataObj				= [self.nsMutaryOfMyData objectAtIndex:pRow];
	return zMyDataObj.nsStrText;
	// Note if the returned string is same as that typed into the cell then no update takes place
	// e.g. returned string="fred", cell = "hello world",
	// user selects the word "world" and types "fred": no change takes place.
	
} // end tableView:objectValueForTableColumn:tableColumn


// this is the delegate method that allows you to put data into your cell
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)pRow {
	//NSLog(@"willDisplayCell");
	EngineData * zMyDataObj				= [self.nsMutaryOfMyData objectAtIndex:pRow];
	EngineTextCell * zMyCell		= (EngineTextCell *)cell;
	zMyCell.nsImageObj				= zMyDataObj.nsImageObj;
	[zMyCell setTitle:zMyDataObj.nsStrText];
	
} // end tableView:willDisplayCell:forTableColumn:row:


// this is the routine that returns cell data (an edited string) back after editing
- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)pRow {
	EngineData * zMyDataObj	= [self.nsMutaryOfMyData objectAtIndex:pRow];
	NSLog(@"setObjectValue string = %@",(NSString *)anObject);
	zMyDataObj.nsStrText	= (NSString *)anObject;
	
} // end tableView:setObjectValue:forTableColumn:row:


// if this is not here we crash - called whenever mouseOver
- (NSCell *)tableView:(NSTableView *)pTableView dataCellForTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRow {	
	//NSLog(@"dataCellForTableColumn");
	return self.myImageAndTextCelObj;
} 

- (void)addToEndOfTable:(id)pId{}
- (void)addAtSelectedRow:(id)pId{}
- (void)removeCellAtSelectedRow:(id)sender{}

@end
