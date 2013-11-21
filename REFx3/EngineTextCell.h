//
//  ImageAndTextCell.h
//
//  Copyright � 2006, Apple. All rights reserved.


#import <Cocoa/Cocoa.h>

@interface EngineTextCell : NSTextFieldCell
/*@private
 NSImage	*nsImageObj;
 */

@property (assign) NSImage	*nsImageObj;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
