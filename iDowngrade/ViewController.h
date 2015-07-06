//
//  ViewController.h
//  iDowngrade
//
//  Created by Keaton Burleson on 7/5/15.
//  Copyright (c) 2015 Keaton Burleson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *firmwareField;
@property (weak) IBOutlet NSTextField *shshField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (weak) IBOutlet NSButton *goButton;


@property (weak) IBOutlet NSTextField *actionLabel;
@property (weak) IBOutlet NSButton *shshCheck;
@property (weak) IBOutlet NSButton *ipswCheck;


@end

