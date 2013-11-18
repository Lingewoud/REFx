//
//  EngineWindowController.h
//  REFx
//
//  Created by Pim Snel on 22-10-13.
//
//

#import <Cocoa/Cocoa.h>

@interface EngineWindowController : NSWindowController

@property (assign) NSString *EngineName;
@property (assign) IBOutlet NSTextField *EngineTitle;
@property (assign) IBOutlet NSTextField *EngineVersion;
@property (assign) IBOutlet NSTextField *EngineDescription;
//@property (assign) IBOutlet NSTextField *newVersionText;

@property (assign) IBOutlet NSPopUpButton *testJobMenu;
@property (assign) IBOutlet NSButton *updatesButton;

- (void)setWindowEngineName:(NSString*) eName;
- (IBAction)insertTestJob:(id)sender;
- (IBAction)openApiDocs:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)revealContentsInFinder:(id)sender;
- (void)reinitWindow;
@end
