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


@implementation EngineListingController
@synthesize nsMutaryOfMyData;
@synthesize nsTableViewObj;
@synthesize myImageAndTextCelObj;
//@synthesize nsIntSelectedRow;

// first step
// cashe the images in MyData

// second step : get the add abd delete going

- (void) awakeFromNib {
//	self.nsIntSelectedRow	= -1;
	
	self.nsMutaryOfMyData = [[NSMutableArray alloc]init];
	
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
																 text:@"Indesign Toolbox"]];
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
                                                                            text:@"Indesign Toolbox"]];
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
                                                                            text:@"Indesign Toolbox"]];
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
                                                                            text:@"Indesign Toolbox"]];
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
                                                                            text:@"Indesign Toolbox"]];
	[self.nsMutaryOfMyData addObject:[[EngineData alloc] initWithImagePathString:@"/Users/pim/Downloads/070-NSTableView-ImageAndTextCell/Naamloos.png"
                                                                            text:@"Indesign Toolbox"]];

	
	
	self.myImageAndTextCelObj = [[EngineTextCell alloc] init];
	self.myImageAndTextCelObj.image = [[self.nsMutaryOfMyData objectAtIndex:0]nsImageObj];
	[self.myImageAndTextCelObj setEditable: YES];
	NSTableColumn* zTableColumnObj = [[self.nsTableViewObj tableColumns] objectAtIndex:0];
	[zTableColumnObj setDataCell: self.myImageAndTextCelObj];
		
} // end awakeFromNib


// these are called by the table(s)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)pTableView
{
	NSLog(@"numberOfRowsInTableView ary count = %d",[nsMutaryOfMyData count]);
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
} // end tableView:dataCellForTableColumn:row:


//- (IBAction)tableViewSelected:(id)sender {
//    NSLog(@"the user just clicked on row %d", [self.nsTableViewObj selectedRow]);
//} // end tableViewSelected



- (IBAction)addAtSelectedRow:(id)pId {
	
	// this has effect of ending the editing if an edit was begun
	// just before the addAtSelectedRow button was clicked.
	[[self.nsTableViewObj window] makeFirstResponder:[self.nsTableViewObj window]];
	
	//NSLog(@"addAtSelectedRow");
	
	NSInteger zSelectedRow	= [self.nsTableViewObj selectedRow];
	//NSLog(@"addAtSelectedRow row=%d array count = %d",zSelectedRow,[self.nsMutaryOfMyData count]);
	if ( zSelectedRow < 0) {
		return;
	} // end if
	
	NSParameterAssert(zSelectedRow < [self.nsMutaryOfMyData count]); // crash out if out of bounds
	
	[nsMutaryOfMyData insertObject:[[EngineData alloc]initWithImagePathString:@"../../../anghiari.tif"
														   text:@"Copy after Ruben's copy after Leonardo: The Battle of Anghiari.. And here is some extra text to see how we get on with very lengthy things"]
						   atIndex:zSelectedRow];
	
	[self.nsTableViewObj noteNumberOfRowsChanged];
	[self.nsTableViewObj reloadData];
	
} // end addAtSelectedRow



- (IBAction)addToEndOfTable:(id)pId {
	NSLog(@"addToEndOfTable");
//	[nsMutaryOfMyData addObject:[[MyData alloc]initWithImagePathString:@"/Users/julius/0AnimatedPaintMP/TestPaintAspects/010_tableView/TableViewExample08/BellaElephants.tif"
//														   text:@"Bella's Dream (detail): Bella and Elephants" 
//														 secondaryText:@"Watercolour with body colour"]];
	[nsMutaryOfMyData addObject:[[EngineData alloc]initWithImagePathString:@"../../../BellaElephants.tif"
														   text:@"Bella's Dream (detail): Bella and Elephants"]];
	
	[self.nsTableViewObj noteNumberOfRowsChanged];
	[self.nsTableViewObj reloadData];
	
} // end addToEndOfTable


- (IBAction)removeCellAtSelectedRow:(id)sender {
	NSLog(@"addToTable [self.nsTableViewObj selectedRow] = %d",[self.nsTableViewObj selectedRow] );
	if ([self.nsTableViewObj selectedRow] < 0 || [self.nsTableViewObj selectedRow] >= [nsMutaryOfMyData count]) {
		return;
	} // end if
	[nsMutaryOfMyData removeObjectAtIndex:[self.nsTableViewObj selectedRow]];
	[self.nsTableViewObj noteNumberOfRowsChanged];
	[self.nsTableViewObj reloadData];
	
} // end removeCellAtSelectedRow



@end
