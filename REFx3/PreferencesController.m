//
//  PreferencesController.m
//  REFx3
//
//  Created by Pim Snel on 07-03-12.
//  Copyright (c) 2012 Lingewoud b.v. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()
@end


@implementation PreferencesController

-(id)init{
    if (![super initWithWindowNibName:@"Preferences"]){
        return nil;
    }
    return self;
}


- (id)initWithWindow:(NSWindow *)window
{


    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
}

@end
