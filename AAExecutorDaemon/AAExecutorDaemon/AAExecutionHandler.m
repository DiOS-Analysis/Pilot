//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAutomation.h"
#import "Common.h"
#import "AAExecutionHandler.h"
#import "AAAlertManager.h"

@interface AAExecutionHandler() <AAAppExecutionDelegate>
@end

@implementation AAExecutionHandler

+ (AAExecutionHandler*)sharedInstance {
    static AAExecutionHandler *singleton;
    
    @synchronized(self) {
        if (!singleton) {
            singleton = [[AAExecutionHandler alloc] init];
        }
        return singleton;
    }
}

- (BOOL)startExecutionWithExecutor:(AAAppExecutor*)executor {
    self->_executor = executor;
    [self _setupExecutor:executor];
    
    DDLogVerbose(@"[AAExecutionHandler] checking for active alerts prior to execution");
    UIAAlert *alert = UIATarget.localTarget.frontMostApp.alert;
    while ([alert isKindOfClass:[UIAAlert class]] && alert.isVisibleBool) {
        DDLogWarn(@"[AAExecutionHandler] active alert detected. Requesting handling for: %@", alert);
        if (![[AAAlertManager sharedInstance] handleAlert:alert] && alert.isVisibleBool) {
            DDLogError(@"[AAExecutionHandler] Unable to handle alert! Aborting execution! Alert: %@", alert);
            return false;
        }
        usleep(1500);
        alert = UIATarget.localTarget.frontMostApp.alert;
    }
    DDLogInfo(@"[AAExecutionHandler] starting execution with executor: %@", executor);
    return [executor startExecution];
}

- (BOOL)stopExecution {
    BOOL result = FALSE;
    if (_executor) {
        result = [_executor stopExecution];
    }
    return result;
}

- (void)_setupExecutor:(AAAppExecutor*)executor {

    //set the handler as execution-delegate
    [executor setDelegate:self];
}

#pragma mark AAAppExecutionDelegate implementation
- (void)appExecutionHasFinished:(NSString *)bundleId {
    DDLogInfo(@"The app executor has finished the execution for app %@", bundleId);
    if (_executionFinishedBlock != nil) {
        _executionFinishedBlock();
    }
}


@end

