//
//  DragView.h
//  
//
//  Created by Keaton Burleson on 7/5/15.
//
//

#import <Cocoa/Cocoa.h>
@interface DragView : NSView {
    BOOL        isHighlighted;
}

@property (assign, setter=setHighlighted:) BOOL isHighlighted;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *ipswCheck;
@property (weak) IBOutlet NSButton *shshCheck;

@end