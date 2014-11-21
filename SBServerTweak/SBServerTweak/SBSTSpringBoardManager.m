//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <objc/runtime.h>
#import "CaptainHook.h"
#import "SBSTSpringBoardManager.h"
#import "SBSTCycriptExecutor.h"
#import "Common.h"
#import <AAPilotNotification.h>

#import <Foundation/NSTask.h>
#import <Foundation/NSDistributedNotificationCenter.h>

#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBUIController.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBAlertItemsController.h>

@implementation SBSTSpringBoardManager

CHDeclareClass(SBApplicationController)
CHDeclareClass(SBUIController)
CHDeclareClass(SBApplicationIcon)
CHDeclareClass(SBLockScreenManager)
CHDeclareClass(SBAlertItemsController)

+ (BOOL)openApplicationForBundleId:(NSString*)bundleId {

    SBApplication *app = [CHSharedInstance(SBApplicationController) applicationWithBundleIdentifier:bundleId];
    SBApplicationIcon *appIcon = [CHAlloc(SBApplicationIcon) initWithApplication:app];

    if (appIcon != nil) {
        dispatch_sync(dispatch_get_main_queue(),^{
            // the app launch has to be executed on the main queue!
            NSDistributedNotificationCenter *defaultCenter = [NSDistributedNotificationCenter defaultCenter];
            [defaultCenter postNotificationName:AAPilotAppWillStart
                                         object:nil
                                       userInfo:@{@"bundleId":bundleId}];
            sleep(2);
            [CHSharedInstance(SBUIController) launchIcon:appIcon fromLocation:0];
            sleep(2);
            [defaultCenter postNotificationName:AAPilotAppStarted
                                         object:nil
                                       userInfo:@{@"bundleId":bundleId}];
        });
    }
    return true;
}

+ (void)pressHomeButton {
    dispatch_sync(dispatch_get_main_queue(),^{
        // needs to be executed on the main queue!
        [CHSharedInstance(SBUIController) clickedMenuButton];
    });
}

+ (void)killApplicationForBundleId:(NSString*)bundleId {
    // TODO: Utilizing NSTask and kill should be a temporary solution. The pirvate SystemServices API should be used instead:
    //    BKSSystemServices *ss = [CHAlloc(BKSSystemServices) init];
    //    [ss terminateApplication:bundleId forReason:1 andReport:false withDescription:@"killed from SBSTSpringBoardManager"];
    
    SBApplication *app = [SBSTSpringBoardManager applicationForBundleId:bundleId];
    if (app == nil)
        return;

    NSDistributedNotificationCenter *defaultCenter = [NSDistributedNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:AAPilotAppWillExit
                                 object:nil
                               userInfo:@{@"bundleId":bundleId}];
    int pid = app.pid;
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/kill"];
    [task setArguments: @[ [NSString stringWithFormat:@"%d",pid] ]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    DDLogVerbose(@"waiting some more seconds to allow proper handling of AAPilotAppWillExit");
    sleep(5);
    DDLogVerbose(@"pressing HomeButton");
    [SBSTSpringBoardManager pressHomeButton];
    sleep(2);
    DDLogVerbose(@"killing bundleId: %@", bundleId);
    [task launch];
    [task waitUntilExit];
    [defaultCenter postNotificationName:AAPilotAppExited
                                 object:nil
                               userInfo:@{@"bundleId":bundleId}];
}

+ (BOOL)unlock {
    
    SBLockScreenManager *manager = CHSharedInstance(SBLockScreenManager);
    
    if([manager isUILocked]) {
        dispatch_sync(dispatch_get_main_queue(),^{
            [manager unlockUIFromSource:1 withOptions:nil];
        });
    }
    
    return ![manager isUILocked];
}


+ (NSDictionary*)applicationInfo {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    NSArray *apps = [CHSharedInstance(SBApplicationController) allApplications];
    
    for (SBApplication *app in apps) {
        NSMutableDictionary *appDict = [[NSMutableDictionary alloc]init];
        appDict[@"name"] = [app displayName];
        appDict[@"bundleId"] = [app bundleIdentifier];
        appDict[@"version"] = [app bundleVersion];
        
// TODO: JSON Serialisation will cause a crash if enabled
//        [appDict setValue:[[app bundle] infoDictionary] forKey:@"infoDictionary"];
        
        dict[appDict[@"bundleId"]] = appDict;
    }
    
    return dict;
    
}

+ (SBApplication*)applicationForBundleId:(NSString*)bundleId {
    return [CHSharedInstance(SBApplicationController) applicationWithBundleIdentifier:bundleId];
}



+ (void)dismissAlerts {
    SBAlertItemsController *alertController = CHSharedInstance(SBAlertItemsController);
    dispatch_sync(dispatch_get_main_queue(),^{
        SBAlertItem *item;
        while((item = [alertController visibleAlertItem])) {
            [item dismiss];
            usleep(1500);
        }
    });
}

CHConstructor {
    CHLoadLateClass(SBApplicationController);
    CHLoadLateClass(SBUIController);
    CHLoadLateClass(SBApplicationIcon);
    CHLoadLateClass(SBLockScreenManager);
    CHLoadLateClass(SBAlertItemsController);
}

@end
