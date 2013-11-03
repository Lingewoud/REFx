//
//  RXTableDataSource.h
//  REFx4
//
//  Created by Pim Snel on 10-09-13.
//
//

#import <Foundation/Foundation.h>
#import "VDKQueue.h"
#import "NSFileHandle+readLine.h"

@interface RXLogTableDataSource : NSObject <VDKQueueDelegate,NSTableViewDataSource>
{
    
NSMutableArray *linesFound;
NSString *logFilePath;
}

@property (assign) IBOutlet NSTableView *linesFoundView;

@end
