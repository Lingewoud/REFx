//
//  RXEngines.m
//  REFx4
//
//  Created by Pim Snel on 24-09-13.
//
//

#import "RXEngineManager.h"

@implementation RXEngineManager

//@synthesize someProperty;

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
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        someProperty = [[NSString alloc] initWithString:@"Default Property Value"];

        [self enginesEnabledArray];
    
    
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

- (NSMutableArray *) enginesEnabledArray
{    
    NSFileManager *filemgr;
    NSMutableArray *enginesList;
    NSArray *enginesFileList;
    
    enginesList = [NSMutableArray arrayWithObjects: nil];
    NSInteger count;

    int i;
    
    enginesFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [self engineDirectoryPath] error: nil];
    
    count = [enginesFileList count];
    
    for (i = 0; i < count; i++)
    {
        if([[[enginesFileList objectAtIndex: i] pathExtension] isEqualToString: @"bundle"])
        {
            [enginesList addObject: [[enginesFileList objectAtIndex: i] stringByDeletingPathExtension]];
        }
    }
    
    NSInteger count2;
    count2 = [enginesList count];
    for (i = 0; i < count2; i++)
    {
        //NSLog (@"%@", [enginesList objectAtIndex: i]);
    }
    
    return enginesList;
}

- (id)engineInfoDict:(NSString*)anEngine objectForKey:(NSString*)key
{
    NSString *path = [[[RXEngineManager sharedEngineManager] pathToEngineContents:anEngine] stringByAppendingPathComponent:@"Info.plist"];
    NSMutableDictionary *engineDictPlist =[[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //NSLog(@"dic for key %@ :%@",key, [engineDictPlist objectForKey:key]);
    return [engineDictPlist objectForKey:key];
}


- (BOOL)engineIsValid:(NSString *)anEngine;
{
    NSString *path = [[[RXEngineManager sharedEngineManager] pathToEngineContents:anEngine] stringByAppendingPathComponent:@"Info.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSString *)pathToEngineRunner
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useAlternativeRunnerPath"])
    {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"altRunnerPath"];
    }
    else
    {
        return [NSString stringWithFormat:@"%@/Contents/Resources/RubyEngineRunner/RubyEngineRunner.rb", [[NSBundle mainBundle] bundlePath]];
    }
}


- (NSString *)pathToEngine:(NSString *)anEngine
{
    NSString * enginePath = [NSString stringWithFormat:@"%@/%@.bundle",[self engineDirectoryPath],anEngine];
    return enginePath;
}

- (NSString *)pathToEngineContents:(NSString *)anEngine
{
    NSString * engineContentsPath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/",[self engineDirectoryPath],anEngine];
    return engineContentsPath;
}

- (NSString *)pathToEngineResources:(NSString *)anEngine
{
    NSString * engineContentsPath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/",[self engineDirectoryPath],anEngine];
    return engineContentsPath;
}



- (NSURL *)urlToEngineApiDocs:(NSString *)anEngine{
    return NULL;
}
- (void)insertEngineTestJob:(NSString *)anEngine{}

@end
