//
//  MyData.m
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import "EngineData.h"


@implementation EngineData
@synthesize nsStrText;
@synthesize nsImageObj;

- (id) initWithImagePathString:(NSString *)pImagePath text:(NSString *)pText {

    if (! (self = [super init])) {
        NSLog(@"*Error* MyData initWithImagePathString");
		return self;
    }
	
	self.nsStrText = pText;
	
	self.nsImageObj	= [[NSImage alloc] initWithContentsOfFile:pImagePath];
		
    return self;
	
}

@end
