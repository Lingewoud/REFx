//
//  RXEngines.m
//  REFx
//
//  Created by Pim Snel on 24-09-13.
//
//

#import "RXEngineManager.h"
#import "RXREFxIntance.h"

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
  //  NSFileManager *filemgr;
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


-(void)insertTestJobFor:(NSString*)engine withIndex:(NSInteger)testIndex
{
    bool cancelOperation = NO;
    
    RXEngineManager *sharedEngineManager = [RXEngineManager sharedEngineManager];
    
    NSString *railsEnvironment = [[[NSApp delegate] refxInstance] getRailsEnvironment];
    NSString *enginePath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/main.rb", [sharedEngineManager engineDirectoryPath],engine];
    NSString *engineDir = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/", [sharedEngineManager engineDirectoryPath],engine];
    NSString *runnerPath = [sharedEngineManager pathToEngineRunner];
    
    NSMutableArray * args = [NSMutableArray arrayWithObjects: runnerPath, @"-t",engine, @"--environment",railsEnvironment, nil];
    
    if(testIndex > 0 ){
        [args addObject:@"-i"];
        [args addObject:[NSString stringWithFormat:@"%li", testIndex]];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
    {
        [args addObject:@"-d"];
    }
    
    NSMutableArray* testArr = [[RXEngineManager sharedEngineManager] engineInfoDict:engine objectForKey:@"testJobs"];
    NSMutableDictionary * testDict = [testArr objectAtIndex:testIndex];
    NSLog(@"dict:%@",testDict);
    
    if ([[testDict objectForKey:@"needSourceFile"] intValue] != 0 ) {
        
        NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
        [openPanel setCanChooseFiles:YES];
        [openPanel setCanChooseDirectories:NO];
        [openPanel setAllowsMultipleSelection:NO];
        
        if ([openPanel runModal] == NSOKButton)
        {
            NSString *selectedFileName = [[openPanel URL] path];
            
            [args addObject:@"-f"];
            [args addObject:selectedFileName];
        }
        else
        {
            NSLog(@"what to do when no file was given?");
            cancelOperation = YES;
        }
    }
    
    if(cancelOperation == NO)
    {
        NSLog(@"args: %@",args);
        
        NSTask *rubyJobProcess = [[NSTask alloc] init];
        
        [rubyJobProcess setCurrentDirectoryPath:engineDir];
        [rubyJobProcess setLaunchPath: enginePath];
        [rubyJobProcess setEnvironment:
         [NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];
        [rubyJobProcess setArguments: args];
        [rubyJobProcess waitUntilExit];
        [rubyJobProcess launch];
    }
}



- (NSURL *)urlToEngineApiDocs:(NSString *)anEngine{
    return NULL;
}
- (void)insertEngineTestJob:(NSString *)anEngine{}

@end
