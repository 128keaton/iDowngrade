//
//  ViewController.h
//  iDowngrade
//
//  Created by Keaton Burleson on 7/5/15.
//  Copyright (c) 2015 Keaton Burleson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *firmwareField;
@property (weak) IBOutlet NSTextField *shshField;
@property (weak) IBOutlet NSProgressIndicator *ipswProgress;
@property (weak) IBOutlet NSProgressIndicator *shshProgress;
@property (weak) IBOutlet NSProgressIndicator *ibssProgess;

- (id)initWithCoder:(NSCoder *)coder;

@end

