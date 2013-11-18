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
#import "RXREFxIntance.h"
#import "RXJobPicker.h"

@implementation EngineListingController
@synthesize nsMutaryOfMyData;
@synthesize nsTableViewObj;
@synthesize myImageAndTextCelObj;
@synthesize engineWindow;

- (void) awakeFromNib {
    
    [self loadEngines];

    self.engineWindow = [[EngineWindowController alloc] initWithWindowNibName:@"EngineWindow"];
}

- (void) loadEngines
{
    self.nsMutaryOfMyData = [[NSMutableArray alloc] init];
    
    //NSLog(@"engine array %@",[[[NSApp delegate] sharedEngineManager] enginesEnabledArray]);
    
    for (NSString *eName in [[[NSApp delegate] sharedEngineManager] enginesEnabledArray]) {
        
        NSString *engineName = [[NSString alloc] initWithString: eName] ;
        
        [self.nsMutaryOfMyData addObject:[[EngineData alloc]
                                          initWithImagePathString: [[NSBundle mainBundle] pathForResource:@"engineicon" ofType:@"png"]
                                          text:engineName]];
    }
    
    
	
	self.myImageAndTextCelObj = [[EngineTextCell alloc] init];
	self.myImageAndTextCelObj.image = [[self.nsMutaryOfMyData objectAtIndex:0]nsImageObj];
	[self.myImageAndTextCelObj setEditable: NO];
    [self.nsTableViewObj setTarget: self];
    
    [self.nsTableViewObj setDoubleAction:@selector(doubleClickInTableView:)];
    
	NSTableColumn* zTableColumnObj = [[self.nsTableViewObj tableColumns] objectAtIndex:0];
	[zTableColumnObj setDataCell: self.myImageAndTextCelObj];
}

- (IBAction)runAllDefaultEngineTests:(id)sender
{
    [[[[NSApp delegate] refxInstance] jobPicker] stopREFxLoop];
    NSInteger testIndex = 0;

    for (NSString *eName in [[[NSApp delegate] sharedEngineManager] enginesEnabledArray])
    {
        if([[RXEngineManager sharedEngineManager] engineIsValid:eName])
        {

            testIndex = 0;
            for (NSDictionary *dict in [[RXEngineManager sharedEngineManager] engineInfoDict:eName objectForKey:@"testJobs"])
            {
                if([[dict objectForKey:@"runInSelfTest"] boolValue])
                {
                    NSLog(@"insert selftest for %@ with index %li",eName, testIndex);
                    NSString *yamlFile =[NSString stringWithFormat:@"%@/%@",[[RXEngineManager sharedEngineManager] pathToEngineResources:eName],[dict objectForKey:@"bodyYaml"]];
                    NSLog(@"YAMLFILE: %@",yamlFile);
                    if([[NSFileManager defaultManager] fileExistsAtPath:yamlFile])
                    {
                        NSString * yamlbody = [NSString stringWithContentsOfFile:yamlFile
                                                                   encoding:NSASCIIStringEncoding
                                                                      error:NULL];
                        
                        yamlbody = [yamlbody stringByReplacingOccurrencesOfString:@"<%=JOB_PATH%>"
                                                                    withString:@"TestJobs/"];
                        yamlbody = [yamlbody stringByReplacingOccurrencesOfString:@"<%=SOURCE_FILE_DIR%>"
                                                                       withString:[[NSApp delegate] appSupportPath]];
                        
                        long newid = [[[[NSApp delegate] refxInstance] jobPicker] insertTestJobwithEngine:eName body:yamlbody];
                        NSLog(@"NEWID: %li",newid);

                    }
       
                }
                testIndex ++;
            }
            
            //remember all id's
        }
    }
    
    [[[[NSApp delegate] refxInstance] jobPicker] startREFxLoop];
}

/*- (NSString*)stringWithPathRelativeTo:(NSString*)anchorPath {
    NSArray *pathComponents = [self pathComponents];
    NSArray *anchorComponents = [anchorPath pathComponents];
    
    NSInteger componentsInCommon = MIN([pathComponents count], [anchorComponents count]);
    for (NSInteger i = 0, n = componentsInCommon; i < n; i++) {
        if (![[pathComponents objectAtIndex:i] isEqualToString:[anchorComponents objectAtIndex:i]]) {
            componentsInCommon = i;
            break;
        }
    }
    
    NSUInteger numberOfParentComponents = [anchorComponents count] - componentsInCommon;
    NSUInteger numberOfPathComponents = [pathComponents count] - componentsInCommon;
    
    NSMutableArray *relativeComponents = [NSMutableArray arrayWithCapacity:
                                          numberOfParentComponents + numberOfPathComponents];
    for (NSInteger i = 0; i < numberOfParentComponents; i++) {
        [relativeComponents addObject:@".."];
    }
    [relativeComponents addObjectsFromArray:
     [pathComponents subarrayWithRange:NSMakeRange(componentsInCommon, numberOfPathComponents)]];
    return [NSString pathWithComponents:relativeComponents];
}
*/

- (IBAction)reloadEngines:(id)sender
{
    [self loadEngines];
    [self.nsTableViewObj reloadData];
}

-(void) doubleClickInTableView:(id)sender
{
    
    NSInteger row = [nsTableViewObj clickedRow];
    //NSInteger column = [nsTableViewObj clickedColumn];
    //NSLog(@"open engine panel %@",[self tableView:nsTableViewObj objectValueForTableColumn:column row:row]);

    //test if engine exist
    if([[RXEngineManager sharedEngineManager] engineIsValid:[self tableView:nsTableViewObj objectValueForTableColumn:[[nsTableViewObj tableColumns] objectAtIndex:0] row:(int)row]])
    {
        //close existing
        NSLog(@"open engine panel %@",[self tableView:nsTableViewObj objectValueForTableColumn:[[nsTableViewObj tableColumns] objectAtIndex:0] row:(int)row]);
 
        [self.engineWindow setWindowEngineName:[self tableView:nsTableViewObj objectValueForTableColumn:[[nsTableViewObj tableColumns] objectAtIndex:0] row:(int)row]];
        [self.engineWindow reinitWindow];
        [self.engineWindow showWindow:self];
    }
}

// these are called by the table(s)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)pTableView
{
	//NSLog(@"numberOfRowsInTableView ary count = %lu",[nsMutaryOfMyData count]);
	return [nsMutaryOfMyData count];
	
}

- (id)tableView:(NSTableView *)pTableView objectValueForTableColumn:(NSTableColumn *)pTableColumn row:(int)pRow {

	EngineData * zMyDataObj				= [self.nsMutaryOfMyData objectAtIndex:pRow];
	return zMyDataObj.nsStrText;
	// Note if the returned string is same as that typed into the cell then no update takes place
	// e.g. returned string="fred", cell = "hello world",
	// user selects the word "world" and types "fred": no change takes place.
	
}

// this is the delegate method that allows you to put data into your cell
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)pRow {
	//NSLog(@"willDisplayCell");
	EngineData * zMyDataObj				= [self.nsMutaryOfMyData objectAtIndex:pRow];
	EngineTextCell * zMyCell		= (EngineTextCell *)cell;
	zMyCell.nsImageObj				= zMyDataObj.nsImageObj;
	[zMyCell setTitle:zMyDataObj.nsStrText];
	
}


// this is the routine that returns cell data (an edited string) back after editing
- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)pRow {
	EngineData * zMyDataObj	= [self.nsMutaryOfMyData objectAtIndex:pRow];
	NSLog(@"setObjectValue string = %@",(NSString *)anObject);
	zMyDataObj.nsStrText	= (NSString *)anObject;
	
}


// if this is not here we crash - called whenever mouseOver
- (NSCell *)tableView:(NSTableView *)pTableView dataCellForTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRow {	
	//NSLog(@"dataCellForTableColumn");
	return self.myImageAndTextCelObj;
} 

- (void)addToEndOfTable:(id)pId{}
- (void)addAtSelectedRow:(id)pId{}
- (void)removeCellAtSelectedRow:(id)sender{}

@end
