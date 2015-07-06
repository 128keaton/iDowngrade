//
//  DragView.m
//  
//
//  Created by Keaton Burleson on 7/5/15.
//
//

#import "DragView.h"

@implementation DragView

@dynamic isHighlighted;

- (void)awakeFromNib {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [[self window]makeFirstResponder:self];
    
    
    

}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            
            NSLog(@"File extension: %@", [path pathExtension]);
            
            if ([[path pathExtension]  isEqual: @"ipsw"]) {
                [defaults setObject:path forKey:@"oldFirmware"];
                [self setHighlighted:YES];
                [self.ipswCheck setState:NSOnState];
                
                [self.ipswCheck performClick:self];
                NSLog(@"ipsw found");
                return NSDragOperationCopy;
                
                
            }else if([[path pathExtension] isEqual: @"shsh"]){
                [defaults setObject:path forKey:@"shshBlobs"];
                [self setHighlighted:YES];
                  [self.ipswCheck performClick:self];
                return NSDragOperationCopy;
                
            }
          
                
            
                return NSDragOperationNone;
            
        }
        [defaults synchronize];
    }
    [self setHighlighted:YES];
    return NSDragOperationEvery;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender  {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
    return YES;
}
- (BOOL)isHighlighted {
    return isHighlighted;
}

- (void)setHighlighted:(BOOL)value {
    isHighlighted = value;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (isHighlighted) {
  
        [self drawBorder:dirtyRect lineWidth:5.0];
        
    }
     [self drawBorder:dirtyRect lineWidth:2.0];
    [[NSImage imageNamed:@"shsh-drop.png"] drawInRect:dirtyRect];

}
-(IBAction)clearValue:(NSButton *)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(sender == self.ipswCheck){
        [defaults removeObjectForKey:@"oldFirmware"];
    }else{
        [defaults removeObjectForKey:@"shshBlobs"];
        
    }
    if (sender == [NSButton class]) {
   
    if (sender.state == 1) {
        sender.state = 0;
    }
    }
    [defaults synchronize];
}
-(void)setButtonState:(NSButton *)button state:(NSInteger)state{
    switch (state) {
        case 0:
            button.state = NSOffState;
            break;
        case 1:
            button.state = NSOnState;
            break;
            
        default:
            break;
    }
  
}


-(void)drawBorder:(NSRect)rect lineWidth:(CGFloat)lineWidth{
    //  NSRect rect = [self bounds];
    NSRect frameRect = [self bounds];
    
    if(rect.size.height < frameRect.size.height)
        return;
    NSRect newRect = NSMakeRect(rect.origin.x+2, rect.origin.y+2, rect.size.width-3, rect.size.height-3);
    
    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:3 yRadius:3];
    [textViewSurround setLineWidth:lineWidth];
    [[NSColor keyboardFocusIndicatorColor] set];
    

    [textViewSurround stroke];
    
}

@end