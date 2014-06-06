//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAutomation.h"

#import "AAExecutionHandler.h"
#import "AAOpenCloseExecutor.h"
#import "AARandomExecutor.h"
#import "AASmartExecutor.h"

#import "AAAlertManager.h"
#import "AAGenericAlertHandler.h"
#import "AAAppStoreAlertHandler.h"

#import "AAClientLib.h"
#import "Common.h"

#define AADefaultExecutor AAOpenCloseExecutor

typedef enum {
    kDefaultExecution,
    kOpenCloseExecution,
    kRandomExecution,
    kSmartExecution,
} AAExecutionStrategy;

NSDictionary *executionStrategyDict = @{
                                        @(kDefaultExecution):@"DefaultExecution",
                                        @(kOpenCloseExecution):@"OpenCloseExecution",
                                        @(kRandomExecution):@"RandomExecution",
                                        @(kSmartExecution):@"SmartExecution",
                                        };

NSString* executionStrategyToString(AAExecutionStrategy strategy) {
    return executionStrategyDict[@(strategy)];
}

AAExecutionStrategy executionStrategyFromString(NSString* strategyName) {
    NSArray *keys = [executionStrategyDict allKeysForObject:strategyName];
    if ([keys count] > 0) {
        return (AAExecutionStrategy)[keys[0] intValue];
    } else {
        return kDefaultExecution;
    }
}

int main(int argc, char **argv, char **envp) {

    @autoreleasepool {
        
        //setup logging
        [DDLog addLogger:[DDASLLogger sharedInstance]];

        DDLogCInfo(@"starting ...");
        
        //check if UIAutomation is working
        BOOL UIAutomationIsWorking = YES;
        @try {
            [[UIATarget localTarget].frontMostApp isVisible];
            if (UIAutomationIsWorking &&
                [UIATarget localTarget].springboard.pid == nil) {
                UIAutomationIsWorking = NO;
            }
        }
        @catch (NSException *exception) {
            UIAutomationIsWorking = NO;
        }
        
        if (!UIAutomationIsWorking) {
            DDLogCError(@"UIAutomation.framework is not working!!!");
            DDLogCInfo(@"sleeping for some time and exit afterwards...");
            sleep(15);
            exit(1);
#pragma message "TODO: mark device as not working if this is not working after some tries"
        }
        
        //setup executionHandler and alertManager
        AAExecutionHandler *executionHandler = [AAExecutionHandler sharedInstance];
        AAAlertManager *alertManager = [AAAlertManager sharedInstance];

        // add generic handler to ensure all alerts will be handled
        [alertManager addAlertHandler:[[AAGenericAlertHandler alloc] init]];
        // add authentication handler
        [alertManager addAlertHandler:[[AAAppStoreAlertHandler alloc] init]];
        
        //set the local targets delegate (this allows alert-handling, ...)
        [UIATarget.localTarget setDelegate:alertManager];
        [UIATarget.localTarget setHandlesAlerts:true];
        
        AAClientLib *client = [AAClientLib sharedInstance];
        __weak AAClientLib *weakclient = client;
        
        // setup the livecycle
#pragma mark AAClient: onExecutionStartRequested
        [client registerForAppExecutionRequestStartNotificationWithBlock:^(NSString *bundleId) {
            
            if (weakclient.executionStarted) {
                DDLogCWarn(@"execution already running. Aborting!");
                return;
            }
            
            NSDictionary *taskInfo = [weakclient taskInfo];
            NSString *executionStrategyValue = taskInfo[@"executionStrategy"];
            NSString *strategyName = nil;
            NSUInteger executionTime = 0;
            
            if (executionStrategyValue != nil) {
                
                NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(\\D+)(\\d*)"
                                                                                            options:0
                                                                                              error:nil];
                NSTextCheckingResult *result = [expression firstMatchInString:executionStrategyValue
                                                                      options:0
                                                                        range:NSMakeRange(0, executionStrategyValue.length)];
                strategyName = executionStrategyValue;
                
                if ([result numberOfRanges] == 3) {
                    strategyName = [executionStrategyValue substringWithRange:[result rangeAtIndex:1]];
                    executionTime = [[executionStrategyValue substringWithRange:[result rangeAtIndex:2]] intValue];
                }
            }

            AAExecutionStrategy executionStrategy = executionStrategyFromString(strategyName);
            DDLogCInfo(@"Requested execution with strategy: %@ and execution time: %lu", strategyName, (unsigned long)executionTime);
            AAAppExecutor* executor;
            switch (executionStrategy) {
                case kSmartExecution:
                    executor = [AASmartExecutor alloc];
                    break;

                case kRandomExecution:
                    executor = [AARandomExecutor alloc];
                    break;

                case kOpenCloseExecution:
                    executor = [AAOpenCloseExecutor alloc];
                    break;
                    
                case kDefaultExecution:
                default:
                    DDLogCWarn(@"Unknown execution strategy! Using default strategy.");
                    executor = [AADefaultExecutor alloc];
                    break;
            }
            executor = [executor initWithBundleId:bundleId andExecutionTime:executionTime];
                                
            DDLogCVerbose(@"weakclient: %@", weakclient);
            [weakclient setAppExecutionHasStartedAndAutoScheduleSetRunning:TRUE];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(10); // wait some time to get the app started
                BOOL result = [executionHandler startExecutionWithExecutor:executor];
                if (result) {
                    DDLogCInfo(@"execution started");
                } else {
                    DDLogCError(@"starting execution failed!!!");
                    DDLogCVerbose(@"weakclient: %@", weakclient);
                    [weakclient setAppExecutionHasFinished];
                }
            });
        }];

#pragma mark [AAClient onExecutionFinishRequested]
        [client registerForNotification:AAPilotAppExecutionRequestFinish withBlock:^{
            [executionHandler stopExecution];
            DDLogCVerbose(@"weakclient: %@", weakclient);
            [weakclient setAppExecutionHasFinished];
        }];

#pragma mark [AAClient onExecutionFinished]
// reset execution state on finished notifications to be able to recover from bad state
        [client registerForNotification:AAPilotAppExecutionFinished withBlock:^{
            if (executionHandler.executor.executionRunning) {
                DDLogCWarn(@"execution still running on AAPilotAppExecutionFinished notification!");
                if(![executionHandler stopExecution]) {
                    DDLogCInfo(@"execution stopped now. Setting execution finished.");
                } else {
                    DDLogCError(@"Unable to stop the execution! It will be set to execution finished by force now.");
                }
                [executionHandler.executor setExecutionFinished];
            }
        }];
        
#pragma mark [ExecutionHandler onExecutionFinished]
        [executionHandler setExecutionFinishedBlock:^{
            [client setAppExecutionHasFinished];
        }];
        
        
        DDLogCInfo(@"started!");
        
        NSRunLoop *runLoop = [NSRunLoop mainRunLoop];

        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:5*60
                                                    target:nil
                                                  selector:@selector(keepLoopRunning:)
                                                  userInfo:nil
                                                   repeats:YES];
        
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        DDLogCInfo(@"entering runloop");
        [runLoop run];
        DDLogCInfo(@"runloop exited");

        DDLogCInfo(@"Try to stop all running executions ...");
        BOOL result = [executionHandler stopExecution];
        DDLogCInfo(@"execution stopped: %c", result);
        
        client = nil;
    }
    return 0;
}


