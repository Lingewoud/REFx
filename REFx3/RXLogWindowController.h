//
//  RXLogWindowWindowController.h
//  REFx
//
//  Created by Pim Snel on 10-09-13.
//
//

#import <Cocoa/Cocoa.h>
#import "RXLogTableDataSource.h"

@interface RXLogWindowController : NSWindowController<NSWindowDelegate>
{

}
@property (retain) IBOutlet NSTableView *logTableView;

- (IBAction)openLogInConsoleApp:(id)sender;

@end
