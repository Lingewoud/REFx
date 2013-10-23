//
//  RXTableDataSource.m
//  REFx4
//
//  Created by Pim Snel on 10-09-13.
//
//

#import "RXLogTableDataSource.h"
#import "REFx3AppDelegate.h"

@implementation RXLogTableDataSource


- (id)init
{
    self = [super init];
    if (self) {
        logFilePath = [[NSApp delegate] engineLogFilePath];
        [self readFile];
        [self startListeningFileChanges];
        [_linesFoundView setDataSource:self];

    }
    
    return self;
}

- (void)startListeningFileChanges
{
    NSLog(@"Starting listening for changes in %@",logFilePath);
    
    VDKQueue *queue = [VDKQueue new];
    [queue addPath: logFilePath notifyingAbout:VDKQueueNotifyAboutWrite];
    [queue setDelegate:self];
}

-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath
{
    
    NSLog(@"External application has changed the monitored file");
    [self readFile];
}

-(void) readFile
{
    linesFound = [[NSMutableArray alloc] init];
    
    NSFileHandle *logFileHandle = [NSFileHandle fileHandleForReadingAtPath:logFilePath];
    
    unsigned long previous = [logFileHandle offsetInFile];
    
    unsigned long fileSize = [logFileHandle  seekToEndOfFile];
   // NSLog(@"myFile Size =%ul" , fileSize) ;
    
    unsigned int buffersize = 4000;
    
    if (fileSize > buffersize)
    {
        [logFileHandle seekToFileOffset: fileSize-buffersize];
    }
    else
    {
        [logFileHandle seekToFileOffset: 0];
    }
    
    NSData *lineData;
    
    while ((lineData = [logFileHandle readLineWithDelimiter:@"\n"]))
    {
        NSString *lineString = [[NSString alloc] initWithData:lineData encoding:NSASCIIStringEncoding];
        
        [linesFound addObject:lineString];
    }
    
    [[self linesFoundView] reloadData];
    NSInteger numberOfRows = [[self linesFoundView] numberOfRows];
    
    if (numberOfRows > 0)
    {
        [[self linesFoundView] scrollRowToVisible:numberOfRows - 1];
    }
}

/**
 * NSTableViewDataSource Protocol Methods
 */

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [linesFound count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"Number"])
    {
        return [NSString stringWithFormat:@"%ld", row];
    }
    else if ([[tableColumn identifier] isEqualToString:@"LineText"])
    {
        return [linesFound objectAtIndex:row];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [linesFound insertObject:object atIndex:row];
}






@end
