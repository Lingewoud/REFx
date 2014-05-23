#import <Cocoa/Cocoa.h>
#import "HTTPConnection.h"


@interface RXHTTPConnection : HTTPConnection

    @property (retain) NSTimer *stopLoopTimer;

@end