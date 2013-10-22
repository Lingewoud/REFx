//
//  EngineWindowController.m
//  REFx4
//
//  Created by Pim Snel on 22-10-13.
//
//

#import "EngineWindowController.h"
#import "RXEngineManager.h"

/*@interface EngineWindowController ()

@end
*/


@implementation EngineWindowController

//@synthesize EngineTitle;
//@synthesize EngineDescription;
//@synthesize EngineVersion;

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
}
- (IBAction)openApiDocs:(id)sender
{
    //get dir
    //open filemanager
}
- (IBAction)revealInFinder:(id)sender
{

    NSString *fullPathString = [[[NSApp delegate] sharedEngineManager] pathToEngine:self.EngineName];
    NSString *pathString = [[[NSApp delegate] sharedEngineManager] engineDirectoryPath];
    
    NSLog(@"open bundle in filemanager: %@", fullPathString);
    [[NSWorkspace sharedWorkspace] selectFile:fullPathString inFileViewerRootedAtPath:fullPathString];

}
- (IBAction)revealContentsInFinder:(id)sender
{

    NSString *fullPathString = [[[NSApp delegate] sharedEngineManager] pathToEngineContents:self.EngineName];
    NSString *pathString = [[[NSApp delegate] sharedEngineManager] engineDirectoryPath];
    
    NSLog(@"open bundle in filemanager: %@", fullPathString);
    [[NSWorkspace sharedWorkspace] selectFile:fullPathString inFileViewerRootedAtPath:fullPathString];
    
}

@end
