//
//  ViewController.m
//  iDowngrade
//
//  Created by Keaton Burleson on 7/5/15.
//  Copyright (c) 2015 Keaton Burleson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController(){
    NSString *temporaryFilePath;
    NSUserDefaults *defaults;
    NSTask *currentTask;
}
@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self setupEnviroment];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];

    
    // Do any additional setup after loading the view.
}
-(void)setupEnviroment{
    //Make temporary path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count])
    {
        NSString *bundleName =
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        temporaryFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
       
    }else{
        [self callError:1];
    }
    defaults = [NSUserDefaults standardUserDefaults];

}
-(void)callError:(int)errorCode{
    id errorCodeDictionaryObject = [NSNumber numberWithInteger: errorCode];
    NSDictionary *errorCodeDictionary = [NSDictionary dictionaryWithObjects:@[@"Couldn't make temporary folder"] forKeys:@[@"1001"]];
    NSString *informativeText = [NSString stringWithFormat:@"NSWarningAlertStyle \r Error: %@", [errorCodeDictionary objectForKey:errorCodeDictionaryObject]];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Alert"];
    [alert setInformativeText:informativeText];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:nil];
    
    
}

-(void)movePrerequisites{
    NSFileManager *fileManager = [NSFileManager new];
    NSError *errorRemovingOldFirmwareBundles;
    NSError *errorCopyingFirmwareBundles;
    NSError *errorMakingSHSHFolder;
    
    if ([fileManager fileExistsAtPath:[temporaryFilePath stringByAppendingString:@"/FirmwareBundles"]] == YES) {
        [fileManager removeItemAtPath:[temporaryFilePath stringByAppendingString:@"/FirmwareBundles"] error:&errorRemovingOldFirmwareBundles];
    }
    
    
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath]stringByAppendingString:@"/FirmwareBundles"];
    [fileManager copyItemAtPath:resourcePath toPath:[temporaryFilePath stringByAppendingString:@"/FirmwareBundles"] error:&errorCopyingFirmwareBundles];
    
    [fileManager createDirectoryAtPath:[temporaryFilePath stringByAppendingString:@"/shsh"] withIntermediateDirectories:NO attributes:nil error:&errorMakingSHSHFolder];
    
    [fileManager createDirectoryAtPath:[temporaryFilePath stringByAppendingString:@"/bss"] withIntermediateDirectories:NO attributes:nil error:&errorMakingSHSHFolder];
    
    if (errorRemovingOldFirmwareBundles) {
       // [self callError:2];
    }
    
    if (errorCopyingFirmwareBundles) {
        // [self callError:3];
    }
    
    if (errorMakingSHSHFolder) {
        // [self callError:4];
    }
    

    
}

- (void)downgradeDevice{
   
    [self movePrerequisites];
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setCurrentDirectoryPath:temporaryFilePath];
    
    NSLog(@"Temporary file path: %@", temporaryFilePath);
    NSLog(@"Application resource path: %@", [[NSBundle mainBundle]resourcePath]);
    
    NSString *firmwarePath = [[temporaryFilePath stringByAppendingString:@"/custom_downgrade.ipsw"]stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *launchPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingString:@"/ipsw"];
    
    [task setLaunchPath: launchPath];
    task.arguments  = @[[defaults objectForKey:@"oldFirmware"], firmwarePath, @"-bbupdate"];
    NSLog(@"Task arguments: %@", task.arguments);
    

  
    [task setStandardInput:[NSPipe pipe]];
    [defaults synchronize];
    currentTask = task;
    self.progressIndicator.hidden = NO;
    [self.progressIndicator startAnimation:nil];
    
    [task launch];
    [task waitUntilExit];
    
    self.progressIndicator.hidden = YES;
    [self.progressIndicator stopAnimation:nil];
    [defaults removeObjectForKey:@"oldFirmware"];
    
    

    
}
-(void)fetchSHSH{
    //Check if user specified custom blobs
    if([defaults objectForKey:@"shshBlobs"]!=nil){
        
    
        NSTask *task = [[NSTask alloc] init];
    
        [task setCurrentDirectoryPath:temporaryFilePath];

    
        NSString *firmwarePath = [[temporaryFilePath stringByAppendingString:@"/custom_downgrade.ipsw"]stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        NSString *launchPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingString:@"/idevicerestore"];
    
        [task setLaunchPath: launchPath];
        task.arguments  = @[@"-t", firmwarePath];
        NSLog(@"Task arguments: %@", task.arguments);
    
    
    
        [task setStandardInput:[NSPipe pipe]];
        [defaults synchronize];
        currentTask = task;
        self.progressIndicator.hidden = NO;
        [self.progressIndicator startAnimation:nil];
        [task launch];
        [task waitUntilExit];
        
        self.progressIndicator.hidden = YES;
        [self.progressIndicator stopAnimation:nil];
        [defaults removeObjectForKey:@"shshBlobs"];
        [defaults synchronize];
    }else{
        self.progressIndicator.hidden = NO;
        [self.progressIndicator startAnimation:nil];
        NSError *error;
        NSFileManager *fileManager = [NSFileManager new];
        NSError *errorMovingBlobs;
   
        NSString *shshPath = [self.shshField.stringValue stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        
        if ([ fileManager fileExistsAtPath:[temporaryFilePath stringByAppendingString:[NSString stringWithFormat:@"/shsh/%@",[shshPath lastPathComponent]]]])
        {
            //removing destination, so soucer may be copied
            if (![fileManager removeItemAtPath:[temporaryFilePath stringByAppendingString:[NSString stringWithFormat:@"/shsh/%@",[shshPath lastPathComponent]]] error:&error])
            {
                NSLog(@"Could not remove old files. Error:%@",error);
              
             
            }
        }
        
        [fileManager copyItemAtPath:shshPath toPath:[temporaryFilePath stringByAppendingString:[NSString stringWithFormat:@"/shsh/%@",[shshPath lastPathComponent]]] error:&errorMovingBlobs];
        if (errorMovingBlobs) {
            // [self callError:5];
            NSLog(@"Error moving blobs: %@", errorMovingBlobs);
            
            NSLog(@"SHSH blob path: %@", shshPath);
            
            NSLog(@"Reciving path: %@", [temporaryFilePath stringByAppendingString:@"/shsh/"]);
        }
        self.progressIndicator.hidden = YES;
        [self.progressIndicator stopAnimation:nil];
 
    }

    
    
}

-(void)makePwnediBSS{
    [self movePrerequisites];
    NSTask *task = [[NSTask alloc] init];
    NSFileManager *fileManager = [NSFileManager new];
    
    [task setCurrentDirectoryPath:temporaryFilePath];

    NSString *firmwarePath = [NSString stringWithFormat:@"%@/custom_firmware.ipsw", temporaryFilePath];
    NSString *junkPath = [NSString stringWithFormat:@"%@/bss", temporaryFilePath];
    
    
    [task setLaunchPath:@"/usr/bin/unzip"];
    task.arguments  = @[firmwarePath, @"-d",  junkPath];
    

    [task setCurrentDirectoryPath:[[NSBundle mainBundle]resourcePath]];
    [task launch];
     currentTask = task;
    [task waitUntilExit];
    task = [NSTask new];
    
    NSString *iBSS;
    junkPath = [NSString stringWithFormat:@"%@/bss/Firmware/dfu/", temporaryFilePath];
    

    
    for(NSString *item in [fileManager contentsOfDirectoryAtPath:junkPath error:nil]) {
        if ([item containsString:@"iBSS"]) {
            iBSS = item;
        }
        NSLog(@"iBSS folder: %@", item);
    }
    
    
    iBSS = [NSString stringWithFormat:@"%@/bss/Firmware/DFU/%@", temporaryFilePath, iBSS];
    NSLog(@"iBSS path: %@", iBSS);

 
    NSString *outputPath = [NSString stringWithFormat:@"%@/pwnediBSS", temporaryFilePath];
    [task setLaunchPath:[NSString stringWithFormat:@"%@/xpwntool",[[NSBundle mainBundle]resourcePath]]];
    
    task.arguments  = @[iBSS, outputPath];
    
    
    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out];
    
    [task launch];
    currentTask = task;
    [self cleanup];

  
    
    
}
-(void)cleanup{
    
    NSFileManager *fileManager = [NSFileManager new];
    NSError *errorRemovingOldFirmwareBundles;
    NSError *errorRemovingBSSFolder;
    NSError *errorRemovingSHSHFolder;
    
    if ([fileManager fileExistsAtPath:[temporaryFilePath stringByAppendingString:@"/FirmwareBundles"]] == YES) {
        [fileManager removeItemAtPath:[temporaryFilePath stringByAppendingString:@"/FirmwareBundles"] error:&errorRemovingOldFirmwareBundles];
    }
    
    

    
    [fileManager removeItemAtPath:[temporaryFilePath stringByAppendingString:@"/shsh"] error:&errorRemovingSHSHFolder];
    
    [fileManager removeItemAtPath:[temporaryFilePath stringByAppendingString:@"/bss"] error:&errorRemovingBSSFolder ];
    
    if (errorRemovingOldFirmwareBundles) {
        // [self callError:6];
    }
    
    if (errorRemovingBSSFolder) {
        // [self callError:7];
    }
    
    if (errorRemovingSHSHFolder) {
        // [self callError:8];
    }
    

    
    
}



-(IBAction)cancelDowngrade:(id)sender{
    [currentTask terminate];
    
    [self cleanup];
    
}
-(void)logData:(NSNotification *)notif {
    NSFileHandle *read = [notif object];
    NSData *data = [read availableData];
    NSString *stringOutput = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",stringOutput);
}

-(IBAction)selectedValue:(NSPopUpButton *)sender{
    [defaults setInteger:[sender indexOfSelectedItem] forKey:@"selectedItem"];
    [defaults synchronize];
}
-(IBAction)goButtonAction:(id)sender{
    switch ([defaults integerForKey:@"selectedItem"]) {
        case 0:
            [self downgradeDevice];
            break;
        case 1:
            [self fetchSHSH];
            break;
        case 2:
            [self makePwnediBSS];
            break;
            
        default:
            break;
    }
}

- (void)defaultsChanged:(NSNotification *)notification {
    // Get the user defaults
    NSUserDefaults *localDefaults = (NSUserDefaults *)[notification object];
    
    if ([localDefaults objectForKey:@"oldFirmware"] != nil && [localDefaults objectForKey:@"shshBlobs"] != nil) {
        self.goButton.enabled = YES;
    }else{
        self.goButton.enabled = NO;
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}



@end
