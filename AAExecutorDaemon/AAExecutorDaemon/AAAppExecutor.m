//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAAppExecutor.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIAutomation.h"
#import "Common.h"

@implementation AAAppExecutionException
@end

@implementation AAAppExecutor

#pragma mark initialization

- (id)init {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _executionRunning = NO;
    }
    return self;
}

- (id)initWithBundleId:(NSString*)bundleId {
    self = [self init];
    if (self) {
        _bundleId = bundleId;
    }
    return self;
}

- (id)initWithBundleId:(NSString*)bundleId andExecutionTime:(NSUInteger)executionTime {
    _executionTime = executionTime;
    return [self initWithBundleId:bundleId];
}


#pragma mark start/stop execution

- (BOOL)startExecution {
    // register as alert handler
    [[AAAlertManager sharedInstance] addAlertHandler:self];

    //check the frontmost apps bundleId to match the bundleId under execution
    UIATarget *target = [UIATarget localTarget];
    UIAApplication *app = [target frontMostApp];

    // check for alert if frontMostApp does not match
    if ([app.bundleID compare:_bundleId] != 0) {
        for (int counter = 0; counter < 30; counter++) {
            if ([app.alert isKindOfClass:[UIAAlert class]]) {
                DDLogInfo(@"frontMostApp is not matching the app under execution and an alert is present. Wait for alert to be handled.");
            } else {
                // no alert present
                break;
            }
            sleep(1);
        }
        app = [target frontMostApp];
    }
    if ([app.bundleID compare:_bundleId] != 0) {
        DDLogWarn(@"The currently active app (%@) does not match the app under execution (%@). Trying to reactivate the app now.", app.bundleID, _bundleId);
        [UIATarget.localTarget openApplication:_bundleId];
        app = [target frontMostApp];
    }
    if ([app.bundleID compare:_bundleId] != 0) {
        DDLogWarn(@"The currently active app (%@) does not match the app under execution (%@). Aborting.", app.bundleID, _bundleId);
        return FALSE;
    }        
    
    @synchronized(self) {
        _executionRunning = TRUE;
    }
    return TRUE;
}

- (BOOL)stopExecution {
    BOOL result = false;
    @synchronized(self) {
        if (_queue.operationCount > 0) {
            [_queue cancelAllOperations];
            [_queue waitUntilAllOperationsAreFinished];
            result = true;
        }
    }
    return result;
}

- (void)setExecutionFinished {
    @synchronized(self) {
        _executionRunning = FALSE;
    }
    [[AAAlertManager sharedInstance] removeAlertHandler:self];
    [_delegate appExecutionHasFinished:_bundleId];
}

#pragma mark AAAlertHandler methods

- (BOOL)handleAlert:(UIAAlert*)alert {
    DDLogVerbose(@"-[AppExecutor handleAlert:]");
    [self saveScreenshotToCameraRoll];
    return false;
}

- (NSArray*)bundleIds {
    return @[_bundleId];
}


#pragma mark some helper methods

- (BOOL)isLoginRegisterView {
    static NSString *regexPattern = @"\\b((log-*in)|(anmelden)|(regist\\S+))\\b";
    static NSRegularExpression *regex;
    if (regex == nil) {
        regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
    }
    
    BOOL result = false;
    UIAWindow *window = UIATarget.localTarget.frontMostApp.mainWindow;
    if ([window isKindOfClass:[UIAWindow class]]) {
        UIAElementArray *buttons = window.buttons;
        if ([buttons isKindOfClass:[UIAElementArray class]]) {
            for (UIAButton *button in buttons) {
                if (![button isKindOfClass:[UIAButton class]] || button.name == nil) {
                    continue;
                }
                NSUInteger numberOfMatches = [regex numberOfMatchesInString:button.name
                                                                    options:0
                                                                      range:NSMakeRange(0, [button.name length])];
                if (numberOfMatches > 1) {
                    result = true;
                    break;
                }
            }
        }
    }
    return result;
}

// (re-)opens the application under execution
- (BOOL)openApplication {
    return [UIATarget.localTarget openApplication:_bundleId];
}


extern CGImageRef UICreateScreenImage();

- (UIImage*)takeScreenshot {
    CGImageRef screenImage = UICreateScreenImage();
    UIImage *screenshot = [UIImage imageWithCGImage:screenImage];
    CGImageRelease(screenImage);
    return screenshot;
}

- (void)saveScreenshotToCameraRoll {
    UIImageWriteToSavedPhotosAlbum([self takeScreenshot], nil, nil, nil);
}

@end