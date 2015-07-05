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
    
    [self setupEnviroment];
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
-(void)fetchFirmware{
    //Fetch old 6.1.3 firmware
    
    [defaults setObject:[self.firmwareField.stringValue stringByReplacingOccurrencesOfString:@" " withString:@" "] forKey:@"pre-hacked-firmware"];
    [defaults synchronize];
    
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
    
    if (errorRemovingOldFirmwareBundles) {
       // [self callError:2];
    }
    
    if (errorCopyingFirmwareBundles) {
        // [self callError:3];
    }
    
    if (errorMakingSHSHFolder) {
        // [self callError:3];
    }
    

    
}

- (IBAction)downgradeDevice:(id)sender {
    [self fetchFirmware];
    [self movePrerequisites];
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setCurrentDirectoryPath:temporaryFilePath];
    
    NSLog(@"Temporary file path: %@", temporaryFilePath);
    NSLog(@"Application resource path: %@", [[NSBundle mainBundle]resourcePath]);
    
    NSString *firmwarePath = [[temporaryFilePath stringByAppendingString:@"/custom_downgrade.ipsw"]stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *launchPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingString:@"/ipsw"];
    
    [task setLaunchPath: launchPath];
    task.arguments  = @[[defaults objectForKey:@"pre-hacked-firmware"], firmwarePath, @"-bbupdate"];
    NSLog(@"Task arguments: %@", task.arguments);
    

  
    [task setStandardInput:[NSPipe pipe]];
    [defaults synchronize];
    currentTask = task;
    [task launch];

    
}
-(IBAction)cancelDowngrade:(id)sender{
    [currentTask terminate];
    
}
-(void)logData:(NSNotification *)notif {
    NSFileHandle *read = [notif object];
    NSData *data = [read availableData];
    NSString *stringOutput = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",stringOutput);
}




- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
