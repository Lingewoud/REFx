//
//  RXLogView.m
//  REFx4
//
//  Created by W.A. Snel on 14-10-11.
//  Copyright 2011 Lingewoud b.v. All rights reserved.
//

#import "RXLogView.h"

@implementation RXLogView

@synthesize pas3LogTextView,autoUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Init Log View");        
    }
    
    return self;
}

- (void) setRailsRootDir: dir {
    [railsRootDir release];
    railsRootDir = [dir copy];
}

- (IBAction)flushLogs:(id)sender{
    NSLog(@"Flushhhhhsss");

    //[[NSApp delegate] flushLogs];
}


- (void)loadView {
    [super loadView];
    NSLog(@"Loading Log View");
    [pas3LogTextView setEditable:NO];
    [pas3LogTextView setRichText:NO];
    [pas3LogTextView setContinuousSpellCheckingEnabled:NO];
    //[self pas3LogTimer];
}

- (void)pas3LogTimer
{   
    
    logTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                 target: self
                                               selector: @selector(readLastLinesOfLog)
                                               userInfo: nil
                                                repeats: YES];
}




- (void)readLastLinesOfLog
{
    if ([autoUpdate state] == 1) {
        NSString *logFile = [railsRootDir stringByAppendingString:@"/log/pas3.log"];
        NSString *logCommand = [NSString stringWithFormat:@"/usr/bin/tail"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:logFile])
        {
            [fileManager createFileAtPath:logFile contents:nil attributes:nil];
        }
        
        NSTask *logProcess = [[NSTask alloc] init];    
        
        [logProcess setCurrentDirectoryPath:railsRootDir];
        [logProcess setLaunchPath: logCommand];
        [logProcess setArguments: [NSArray arrayWithObjects:@"-n",@"300", logFile,nil]];    
        
        NSPipe *pipe = [NSPipe pipe];
        [logProcess setStandardOutput:pipe];
        NSFileHandle *file = [pipe fileHandleForReading];
        [logProcess launch];
        
        NSData *data = [file readDataToEndOfFile];
        NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //[string appendString:@"\n\n"];
        
        [[[pas3LogTextView textStorage] mutableString] setString: string];        
        
        NSRange range = NSMakeRange([string length], 1);
        [pas3LogTextView scrollRangeToVisible:range];      

        [string release];
        [fileManager release];    
        [logProcess release];            
    }
}


@end
