//
//  MyData.h
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EngineData : NSObject {
	NSString * nsStrText;
	NSImage * nsImageObj;

}
@property (assign) NSString * nsStrText;
@property (assign) NSImage * nsImageObj;


- (id) initWithImagePathString:(NSString *)pImagePath text:(NSString *)pText;

@end
