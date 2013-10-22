//
//  DemoView.m
//  Cocoa Sqlite Example
//
//  Created by Pim Snel on 01-10-12.
//  Copyright (c) 2012 Pim Snel. All rights reserved.
//

#import "JobsView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "REFx3AppDelegate.h"
#import "RXREFxIntance.h"


@implementation JobsView

@synthesize testBuffer;

- (id)init
{
     if (self = [super init])
     {
		// instantiate the following private property
         testBuffer = [NSMutableDictionary dictionaryWithCapacity:10];
         
         [testBuffer retain];

         dbPath = [[[NSApp delegate] refxInstance] getDbPath];
         [dbPath retain];
         //NSLog(@"dbpath:%@",dbPath);
         
         
         [self populateTableAndBuffer];
         [self startAutoUpdateTable];

    }
     return (self);
}

- (void)startAutoUpdateTable
{
    NSLog(@"start autoupdate table view");
    tableUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                 target: self
                                               selector: @selector(populateTableAndBuffer)
                                               userInfo: nil
                                                repeats: YES];
}

- (void)stopAutoUpdateTable
{
    NSLog(@"stop autoupdate table view");

    [tableUpdateTimer invalidate];
}

// -- Handle the awakeFromNib signal
- (void)awakeFromNib
{

}

- (IBAction)refreshTable:(id)sender{
        [self populateTableAndBuffer];
}

- (IBAction)viewBody:(id)sender
{
    if([[self testTable] selectedRow]==-1) return;
        
    NSDictionary *selectedRow =[self getData];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from jobs WHERE id=?",[selectedRow objectForKey:@"id"]];
    while ([rs next]) {
        
        
        if([rs stringForColumn:@"body"])
            [[[panelTextField textStorage] mutableString] setString: [rs stringForColumn:@"body"]];

        else
            [[[panelTextField textStorage] mutableString] setString: @""];
    }
    [db close];
    [testPanel setTitle:@"Body"];

    
    // display the edit panel
	[testPanel setFloatingPanel:YES];
	[testPanel makeKeyAndOrderFront:self];
}
- (IBAction)returnBody:(id)sender
{
    if([[self testTable] selectedRow]==-1) return;

    NSDictionary *selectedRow =[self getData];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    
    
    FMResultSet *rs = [db executeQuery:@"select * from jobs WHERE id=?",[selectedRow objectForKey:@"id"]];
    while ([rs next]) {
        
        
        if([rs stringForColumn:@"returnbody"])
            [[[panelTextField textStorage] mutableString] setString: [rs stringForColumn:@"returnbody"]];
        
        else
            [[[panelTextField textStorage] mutableString] setString: @""];
    }
    [db close];
    [testPanel setTitle:@"Return Body"];

    
    // display the edit panel
	[testPanel setFloatingPanel:YES];
	[testPanel makeKeyAndOrderFront:self];
}


- (IBAction)resetJob:(id)sender{
    
    if([[self testTable] selectedRow]==-1) return;

    NSDictionary *selectedRow =[self getData];
    NSLog(@"reset Record %@ at row %@",[selectedRow objectForKey:@"id"], [selectedRow objectForKey:@"row"]);

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    NSLog(@"UPDATE jobs SET status=1,attempt=0 WHERE id=%@",[selectedRow objectForKey:@"id"]);
    [db executeUpdate:@"UPDATE jobs SET status=1,attempt=0 WHERE id=?",[selectedRow objectForKey:@"id"]];
    [db close];
    [self populateTableAndBuffer];
}

- (IBAction)deleteJob:(id)sender{
    
    if([[self testTable] selectedRow]==-1) return;

    NSDictionary *selectedRow =[self getData];
    NSLog(@"delete Record %@ at row %@",[selectedRow objectForKey:@"id"], [selectedRow objectForKey:@"row"]);
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    [db executeUpdate:@"DELETE FROM jobs WHERE id=?",[selectedRow objectForKey:@"id"]];
    [db close];
    [self populateTableAndBuffer];
}


- (void) populateTableAndBuffer{
	NSMutableArray *loc_id;
    NSMutableArray *loc_priority;
    NSMutableArray *loc_engine;
    NSMutableArray *loc_status;
    NSMutableArray *loc_attempt;
    NSMutableArray *loc_body;
    NSMutableArray *loc_returnbody;
    NSMutableArray *loc_created_at;
    NSMutableArray *loc_updated_at;
    
	
	if (testBuffer != nil)
	{
		// FOR DEBUGGING ONLY
		
		// instantiate the following locals
		loc_id = [NSMutableArray array];
		loc_priority = [NSMutableArray array];
		loc_engine = [NSMutableArray array];
		loc_status = [NSMutableArray array];
		loc_attempt = [NSMutableArray array];
		loc_body = [NSMutableArray array];
        
        loc_returnbody = [NSMutableArray array];
		loc_created_at = [NSMutableArray array];
		loc_updated_at = [NSMutableArray array];
        NSInteger jobsAmount;
        
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"jobsAmount"]>0)
        {
             jobsAmount = [[NSUserDefaults standardUserDefaults] integerForKey:@"jobsAmount"];
        }
        else
        {
            jobsAmount = 50;
        }

        
        
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        
        if (![db open]) {
            NSLog(@"Could not open db.");
            return;
        }
        
        FMResultSet *rs = [db executeQuery:@"select * from jobs order by id DESC Limit ?", [NSString stringWithFormat:@"%li", jobsAmount]];
        
        while ([rs next]) {
            //NSLog(@"%@",[rs stringForColumn:@"engine"]);
			[loc_id addObject:[NSNumber numberWithInt:[rs intForColumn:@"id"]]];
			[loc_priority addObject:[NSNumber numberWithInt:[rs intForColumn:@"priority"]]];
			[loc_engine addObject:[rs stringForColumn:@"engine"]];
            [loc_attempt addObject:[NSNumber numberWithInt:[rs intForColumn:@"attempt"]]];

			if([rs stringForColumn:@"status"]) [loc_status addObject:[rs stringForColumn:@"status"]];
            else [loc_status addObject:@""];
            
            if([rs stringForColumn:@"body"]) [loc_body addObject:@"HAS DATA"];
            else [loc_body addObject:@""];
            
            if([rs stringForColumn:@"returnbody"]) [loc_returnbody addObject:@"HAS DATA"];
            else [loc_returnbody addObject:@""];
            
            if([rs dateForColumn:@"created_at"]) [loc_created_at addObject:[rs dateForColumn:@"created_at"]];
            else [loc_created_at addObject:@""];
            
            if([rs dateForColumn:@"updated_at"]) [loc_updated_at addObject:[rs stringForColumn:@"updated_at"]];
            else [loc_updated_at addObject:@""];
            
        }
        
		[testBuffer setObject: loc_id forKey:@"id"];
		[testBuffer setObject: loc_priority forKey:@"priority"];
		[testBuffer setObject: loc_engine forKey:@"engine"];
		[testBuffer setObject: loc_attempt forKey:@"attempts"];
		[testBuffer setObject: loc_status forKey:@"status"];
		[testBuffer setObject: loc_body forKey:@"body"];
		[testBuffer setObject: loc_returnbody forKey:@"returnbody"];
		[testBuffer setObject: loc_created_at forKey:@"created_at"];
		[testBuffer setObject: loc_updated_at forKey:@"updated_at"];
		
		// send a reload request
		[[self testTable] reloadData];
        [db close];
	}
}



//----- DELEGATE METHODS:DATA SOURCE

// ----- ACCESSOR METHODS
// -- Retrieve the currently selected data
- (NSDictionary *)getData
{
	NSMutableDictionary	*loc_dat;
	NSInteger loc_row;
	
	// retrieve the currently selected row
	loc_row = [[self testTable] selectedRow];
    loc_dat = nil;
	if (loc_row >= 0)
	{
		// instantiate the data dictionary
		loc_dat = [NSMutableDictionary dictionaryWithCapacity:2];
		if (loc_dat != nil)
		{
			// update the data dictionary
			[loc_dat setObject:	[[[self _testBuffer] objectForKey:@"id"] objectAtIndex:loc_row] forKey:@"id"];
			[loc_dat setObject: [NSNumber numberWithInt:loc_row] forKey:@"row"];
		}
	}
	// return the retrieval results
	return (loc_dat);
}


// -- Return the number of rows to be displayed
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTbl
{
    return ([[[self testBuffer] objectForKey:@"id"] count]);
}

// -- Return the cell data for the specified row/column
- (id)tableView:(NSTableView *)aTbl objectValueForTableColumn:(NSTableColumn *)aCol row:(NSInteger)aRow
{
	id loc_data, loc_uid;
	
	// determine which table column needs to be updated
	loc_uid = [aCol identifier];
    
	if ([loc_uid isKindOfClass:[NSString class]])
	{
		loc_data = [[self testBuffer] objectForKey:loc_uid];
       // NSLog(@"Table Column 1 %@, array index %@",loc_uid, loc_data);
		loc_data = [loc_data objectAtIndex:aRow];
        //NSLog(@"Table Column 2 %@, array index %@",loc_uid, loc_data);

	}
    else
    {
        loc_data = nil;
    }
    
	// return the row/column data

	return (loc_data);
}


// -- Access the table outlet property
- (NSTableView *)testTable
{
	return (testTable);
}

// -- Access the internal data buffer
- (NSDictionary *)_testBuffer
{
	return (testBuffer);
}


// ----- MODIFIER METHODS
// -- Update the data buffer
- (void)setData:(NSDictionary *)aDat
{
    NSLog(@"setdata %@", aDat);
	id	loc_dat;
	int	loc_row;
	
	// parametre check
	if ((aDat != nil) && ([aDat count] == 4))
	{
		// retrieve the row to be updated
		loc_row = [[aDat objectForKey:@"row"] intValue];
		
		// update the data buffer
		loc_dat = [aDat objectForKey:@"name"];
		[[testBuffer objectForKey:@"name"] 
			replaceObjectAtIndex:loc_row withObject:loc_dat];
		
		loc_dat = [aDat objectForKey:@"type"];
		[[testBuffer objectForKey:@"type"] 
			replaceObjectAtIndex:loc_row withObject:loc_dat];
		
		loc_dat = [aDat objectForKey:@"size"];
		[[testBuffer objectForKey:@"size"] 
			replaceObjectAtIndex:loc_row withObject:loc_dat];
		
		// submit a reload request
		[[self testTable] reloadData];
	}
}
@end
