//
//  EngineWindowController.m
//  REFx4
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

    [self.window setTitle:[NSString stringWithFormat:@"Engine: %@", self.EngineName]];
    
    [self.EngineTitle setStringValue:self.EngineName];
    [self.EngineVersion setStringValue:[[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"CFBundleVersion"]];
    [self.EngineDescription setStringValue: [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"CFBundleGetInfoString"]];
 
    for (NSDictionary *dict in [[RXEngineManager sharedEngineManager] engineInfoDict:self.EngineName objectForKey:@"testJobs"])
    {
        [self.testJobMenu addItemWithTitle:[dict objectForKey:@"title"]];
    }
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
        
        NSLog(@"Open input file handler");
        int i; // Loop counter.
        
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        [openDlg setCanChooseFiles:YES];
        [openDlg setCanChooseDirectories:NO];
        [openDlg setAllowsMultipleSelection:NO];
        
        NSString* fileName;

        if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
        {
            // Get an array containing the full filenames of all
            // files and directories selected.
            NSArray* files = [openDlg filenames];
            
            // Loop through all the files and process them.
            for( i = 0; i < [files count]; i++ )
            {
                fileName = [files objectAtIndex:i];
            }
            NSLog(@"filename %@",fileName);
            
            [args addObject:@"-f"];
            [args addObject:fileName];
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
