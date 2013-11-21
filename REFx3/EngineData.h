//
//  MyData.h
//  TableViewExample
//
//  Created by julius on 30/03/2010.
//  Copyright 2010 Julius J. Guzy. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EngineData : NSObject

@property (nonatomic,copy) NSString * nsStrText;
@property (nonatomic,copy) NSImage * nsImageObj;


- (id) initWithImagePathString:(NSString *)pImagePath text:(NSString *)pText;

@end
