//
//  RXEngines.m
//  REFx4
//
//  Created by Pim Snel on 24-09-13.
//
//

#import "RXEngineManager.h"

@implementation RXEngineManager

@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedEngineManager {
    static RXEngineManager *sharedEngineManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngineManager = [[self alloc] init];
    });
    return sharedEngineManager;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (id)init
{
    self = [super init];
    if (self) {
        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];

        [self enginesEnabled];
    
    
    }
    
    return self;
}



- (NSString *) engineDirectoryPath
{
    NSString * enginePath = [[[[NSApp delegate] applicationFilesDirectory] path] stringByAppendingPathComponent:@"Engines"];
    return enginePath;
}

- (void) initEngineDirectory
{
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if(![fileManager fileExistsAtPath:[self engineDirectoryPath]]){
        NSLog(@"Creating %@",[self engineDirectoryPath]);
        
        [fileManager createDirectoryAtPath:[self engineDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [fileManager release];
}

- (NSMutableArray *) enginesEnabled
{    
    NSFileManager *filemgr;
    NSMutableArray *enginesList;
    NSArray *enginesFileList;
    
    enginesList = [NSMutableArray arrayWithObjects: nil];
    int count;

    int i;
    
    filemgr = [NSFileManager defaultManager];
    
    enginesFileList = [filemgr contentsOfDirectoryAtPath: [self engineDirectoryPath] error: nil];
    
    count = [enginesFileList count];
    
    for (i = 0; i < count; i++)
    {
        if([[[enginesFileList objectAtIndex: i] pathExtension] isEqualToString: @"bundle"])
        {
            [enginesList addObject: [[enginesFileList objectAtIndex: i] stringByDeletingPathExtension]];
        }
    }
    
    int count2;
    count2 = [enginesList count];
    for (i = 0; i < count2; i++)
    {
        NSLog (@"%@", [enginesList objectAtIndex: i]);
    }
    
    return enginesList;
}

@end