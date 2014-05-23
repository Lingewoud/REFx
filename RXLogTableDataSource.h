//
//  RXTableDataSource.h
//  REFx
//
//  Created by Pim Snel on 10-09-13.
//
//

#import <Foundation/Foundation.h>
#import "VDKQueue.h"
#import "NSFileHandle+readLine.h"

@interface RXLogTableDataSource : NSTableView <VDKQueueDelegate,NSTableViewDataSource>
{
    
NSMutableArray *linesFound;
NSString *logFilePath;
VDKQueue *myqueue;

}

@property (assign) IBOutlet NSTableView *linesFoundView;
- (IBAction)flushLogFile:(id)sender;
-(void) readFile;

@end
