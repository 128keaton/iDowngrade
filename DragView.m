//
//  DragView.m
//  
//
//  Created by Keaton Burleson on 7/5/15.
//
//

#import "DragView.h"

@implementation DragView

- (id)initWithFrame:(NSRect)frame {
    if (! (self = [super initWithFrame:frame] ) ) {
        NSLog(@"Error: MyNSView initWithFrame");
        return self;
    } // end if
    
    self.nsImageObj = nil;
    
    [self registerForDraggedTypes:
     [NSArray arrayWithObjects:NSTIFFPboardType,NSFilenamesPboardType,nil]];
    return self;
}  // end initWithFrame

- (NSDragOperation)draggingEntered:(id )sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric) {
        
        return NSDragOperationGeneric;
        
    } // end if
    
    // not a drag we can use
    return NSDragOperationNone;
    
} // end draggingEntered

- (BOOL)prepareForDragOperation:(id )sender {
    return YES;
} // end prepareForDragOperation

(BOOL)performDragOperation:(id )sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // define the images  types we accept
    // NSPasteboardTypeTIFF: (used to be NSTIFFPboardType).
    // NSFilenamesPboardType:An array of NSString filenames
    NSArray *zImageTypesAry = [NSArray arrayWithObjects:NSPasteboardTypeTIFF,
                               NSFilenamesPboardType, nil];
    
    NSString *zDesiredType =
    [zPasteboard availableTypeFromArray:zImageTypesAry];
    
    if ([zDesiredType isEqualToString:NSPasteboardTypeTIFF]) {
        NSData *zPasteboardData   = [zPasteboard dataForType:zDesiredType];
        if (zPasteboardData == nil) {
            NSLog(@"Error: MyNSView zPasteboardData == nil");
            return NO;
        } // end if
        
        self.nsImageObj = [[NSImage alloc] initWithData:zPasteboardData];
        [self setNeedsDisplay:YES];
        return YES;
        
    } //end if
    
    
    if ([zDesiredType isEqualToString:NSFilenamesPboardType]) {
        // the pasteboard contains a list of file names
        //Take the first one
        NSArray *zFileNamesAry =
        [zPasteboard propertyListForType:@"NSFilenamesPboardType"];
        NSString *zPath = [zFileNamesAry objectAtIndex:0];
        NSImage *zNewImage = [[NSImage alloc] initWithContentsOfFile:zPath];
        
        if (zNewImage == nil) {
            NSLog(@"Error: MyNSView performDragOperation zNewImage == nil");
            return NO;
        }// end if
        
        self.nsImageObj = zNewImage;
        [self setNeedsDisplay:YES];
        return YES;
        
    }// end if
    
    //this cant happen ???
    NSLog(@"Error MyNSView performDragOperation");
    return NO;
    
} // end performDragOperation


- (void)concludeDragOperation:(id )sender {
    [self setNeedsDisplay:YES];
} // end concludeDragOperation



- (void)drawRect:(NSRect)dirtyRect {
    if (self.nsImageObj == nil) {
        [[NSColor blackColor] set];
        NSRectFill( dirtyRect );
    } // end if
    NSRect zOurBounds = [self bounds];
    [super drawRect:dirtyRect];
    [self.nsImageObj compositeToPoint:(zOurBounds.origin)
                            operation:NSCompositeSourceOver];
} // end drawRect



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
