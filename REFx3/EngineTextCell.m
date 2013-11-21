//	ImageAndTextCell.m
//	Copyright � 2006, Apple Computer, Inc., all rights reserved.
//
//	Subclass of NSTextFieldCell which can display text and an image simultaneously.
//  JJG: edited to remove memory management statements and currently inessential code.

#import "EngineTextCell.h"

@implementation EngineTextCell
@synthesize nsImageObj;

- (id)copyWithZone:(NSZone *)zone {

    return self;
    EngineTextCell *zCell = (EngineTextCell *)[super copyWithZone:zone];
    zCell.nsImageObj = self.nsImageObj;
    return zCell;
}



// over-ride NSCell selectWithFrame : called when frame is selected for editing
- (void)xxselectWithFrame:(NSRect)aRect
				 inView:(NSView *)controlView 
				 editor:(NSText *)textObj 
			   delegate:(id)anObject 
				  start:(NSInteger)selStart 
				 length:(NSInteger)selLength {
	
	NSLog(@"My Cell: selectWithFrame");
    NSRect textFrame, imageFrame;

    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [nsImageObj size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}


// draw the image on the left hand side of the NSTextFieldCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {	
	if (nsImageObj == nil) {
		[super drawWithFrame:cellFrame inView:controlView];
		return;
	} // end if
	
	NSSize	imageSize;
	NSRect	imageFrame;

	imageSize = [nsImageObj size];
	NSDivideRect(cellFrame, &imageFrame, &cellFrame, 5 + imageSize.width, NSMinXEdge);
	if ([self drawsBackground]){
		[[self backgroundColor] set];
		NSRectFill(imageFrame);
	}
    

	imageFrame.origin.x += 3;
	imageFrame.size = imageSize;

	if ([controlView isFlipped]) {
		imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
	} else {
		imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
	}

	[nsImageObj compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
	
    [super drawWithFrame:cellFrame inView:controlView];
}

@end

