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
    [self.EngineTitle setStringValue:self.EngineName];
    [self.EngineDescription setStringValue:@""];
    [self.EngineVersion setStringValue:@""];
    [self.window setTitle:[NSString stringWithFormat:@"Engine: %@", self.EngineName]];
    NSLog(@"title? %@",[[self EngineTitle] stringValue]);
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void) setWindowEngineName:(NSString*) eName
{
    self.EngineName = eName;
}

- (IBAction)insertTestJob:(id)sender
{
    //run nstask
    
    
    RXEngineManager *sharedEngineManager = [RXEngineManager sharedEngineManager];
    NSString *railsEnvironment = [[[NSApp delegate] refxInstance] getRailsEnvironment];
    //NSString *railsEnvironment = @"";
    NSString *enginePath = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/main.rb", [sharedEngineManager engineDirectoryPath],self.EngineName];
    NSString *engineDir = [NSString stringWithFormat:@"%@/%@.bundle/Contents/Resources/", [sharedEngineManager engineDirectoryPath],self.EngineName];
    NSString *runnerPath = [NSString stringWithFormat:@"%@/Contents/Resources/RubyEngineRunner/RubyEngineRunner.rb", [[NSBundle mainBundle] bundlePath]];
    
    NSTask *rubyJobProcess = [[NSTask alloc] init];
    
    [rubyJobProcess setCurrentDirectoryPath:engineDir];
    [rubyJobProcess setLaunchPath: enginePath];
    
    [rubyJobProcess setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:NSHomeDirectory(), @"HOME", NSUserName(), @"USER", nil]];
        
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"])
    {
        [rubyJobProcess setArguments: [NSArray arrayWithObjects:
                                       runnerPath,
                                       @"-t",self.EngineName,
                                       @"-d",
                                       @"--environment",railsEnvironment,
                                       nil]];
        
    }
    else{
        [rubyJobProcess setArguments: [NSArray arrayWithObjects:runnerPath,
                                       @"-t",self.EngineName,
                                       @"--environment",railsEnvironment,
                                       nil]];
    }
    [rubyJobProcess launch];
}

- (IBAction)openApiDocs:(id)sender
{
    //get dir
    //open filemanager
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
