//
//  EngineWindowController.m
//  REFx
//
//  Created by Pim Snel on 22-10-13.
//
//

#import "EngineWindowController.h"
#import "RXEngineManager.h"
#import "RXREFxIntance.h"



@implementation EngineWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self reinitWindow];
}



-(void) reinitWindow
{
    [self.window setTitle:[NSString stringWithFormat:@"Engine: %@", self.EngineName]];
    
    [self.EngineTitle setStringValue:self.EngineName];
    [self.EngineVersion setStringValue:[[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"CFBundleVersion"]];
    [self.EngineDescription setStringValue: [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"CFBundleGetInfoString"]];
    
    [self.testJobMenu removeAllItems];
    
    for (NSDictionary *dict in [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"testJobs"])
    {
        [self.testJobMenu addItemWithTitle:[dict objectForKey:@"title"]];
    }
    
    //UPDATES BUTTON
    /*
    if([[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"UpdateURI"])
    {
        [self.updatesButton setEnabled:YES];
        [self.updatesButton setHidden:NO];
        
    
        
    }
    else
    {
        [self.updatesButton setEnabled:NO];
        [self.updatesButton setHidden:YES];
    }
    */
}

-(IBAction)checkForUpdate:(id)sender
{
    //check if git is installed
    
    //clone remote url in temp folder
    
    /*
    NSTask *gitCloneProc = [[NSTask alloc] init];
    
    [gitCloneProc setCurrentDirectoryPath:engineDir];
    [gitCloneProc setLaunchPath: @"/usr/bin/git"];
    [gitCloneProc setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];
    [gitCloneProc setArguments: args];
    [gitCloneProc launch];
     */
    //[[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"UpdateURI"]
    //check version
    //if higher
    //inform user set install text
    //else inform user
}


-(void) setWindowEngineName:(NSString*) eName
{
    self.EngineName = eName;
}

- (IBAction)insertTestJob:(id)sender
{
    bool cancelOperation = NO;

    RXEngineManager *sharedEngineManager = [RXEngineManager sharedEngineManager];
    
    NSString *railsEnvironment = [[[NSApp delegate] refxInstance] getRailsEnvironment];
    NSString *enginePath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/main.rb", [sharedEngineManager engineDirectoryPath],self.EngineName];
    NSString *engineDir = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/", [sharedEngineManager engineDirectoryPath],self.EngineName];
    NSString *runnerPath = [sharedEngineManager pathToEngineRunner];
    
    NSMutableArray * args = [NSMutableArray arrayWithObjects: runnerPath, @"-t",self.EngineName, @"--environment",railsEnvironment, nil];
    
    NSInteger testIndex = [self.testJobMenu indexOfSelectedItem];
    if(testIndex > 0 ){
        [args addObject:@"-i"];
        [args addObject:[NSString stringWithFormat:@"%li", testIndex]];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
    {
        [args addObject:@"-d"];
    }
    
    NSMutableArray* testArr = [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"testJobs"];
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
        [rubyJobProcess setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];
        [rubyJobProcess setArguments: args];
        [rubyJobProcess launch];
    }
}

- (IBAction)openApiDocs:(id)sender
{
    NSLog(@"url,:%@",[[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"ApiDocumentationURI"]);
 
    NSURL * myURL = [NSURL URLWithString: [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"ApiDocumentationURI"]];
    [[NSWorkspace sharedWorkspace] openURL:myURL];
}
- (IBAction)revealInFinder:(id)sender
{

    NSString *fullPathString = [[[NSApp delegate] sharedEngineManager] pathToEngine:self.EngineName];
    
    NSLog(@"open bundle in filemanager: %@", fullPathString);
    [[NSWorkspace sharedWorkspace] selectFile:fullPathString inFileViewerRootedAtPath:fullPathString];

}
- (IBAction)revealContentsInFinder:(id)sender
{

    NSString *fullPathString = [[[NSApp delegate] sharedEngineManager] pathToEngineContents:self.EngineName];
    
    NSLog(@"open bundle in filemanager: %@", fullPathString);
    [[NSWorkspace sharedWorkspace] selectFile:fullPathString inFileViewerRootedAtPath:fullPathString];
}

@end
