//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/NSDistributedNotificationCenter.h>

#import <CaptainHook.h>
#import <AAPilotNotification.h>

#import "Common.h"
#import "SBSTAppExecutionManager.h"
#import "SBSTSpringBoardManager.h"

//the response timeout for requests in seconds
#define NOTIFICATION_RESPONSE_TIMEOUT 60
#define POST_EXECUTION_FINISHED_SLEEP_TIME 10

@interface SBSTAppExecutionManager() {

    // will receive a singal after the execution was started
    NSCondition *appExecutionStarted;
    // will receive a singal to reset the execution timeout
    NSCondition *appExecutionTimeout;
    // will receive a singal after the execution was finished
    NSCondition *appExecutionFinished;
    
    BOOL appExecutionHasFinished;
    
}

@end

static NSLock *__appExecutionLock;

@implementation SBSTAppExecutionManager

CHDeclareClass(NSDistributedNotificationCenter)


- (id)init {
    self = [super init];
    if(self) {
        @synchronized([self class]) {
            if (!__appExecutionLock)
                __appExecutionLock = [[NSLock alloc] init];
        }
        
        appExecutionStarted = [[NSCondition alloc]init];
        appExecutionTimeout = [[NSCondition alloc]init];
        appExecutionFinished = [[NSCondition alloc]init];
        appExecutionHasFinished = NO;
        
        //setup notifications
        NSDistributedNotificationCenter *distNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
        [distNotificationCenter addObserver:self
                                   selector:@selector(_appExecutionStarted:)
                                       name:AAPilotAppExecutionStarted object:nil];

        [distNotificationCenter addObserver:self
                                   selector:@selector(_appExecutionRunning:)
                                       name:AAPilotAppExecutionRunning object:nil];
        
        [distNotificationCenter addObserver:self
                                   selector:@selector(_appExecutionFinished:)
                                       name:AAPilotAppExecutionFinished object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark execution methods

- (void)executeAppWithBundleId:(NSString*)bundleId {
    [__appExecutionLock lock];
    DDLogInfo(@"Starting AppExecution: %@", bundleId);
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];

    // get lock to ensure the signal won't arrive prior to wait
    [appExecutionStarted lock];

    //request app execution
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionRequestStart
                                                                   object:nil
                                                                 userInfo:@{@"bundleId":bundleId}];
    
    DDLogVerbose(@"Waiting for AppExecutionStarted notification (%@)", bundleId);
    BOOL signalReceived = [appExecutionStarted waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:NOTIFICATION_RESPONSE_TIMEOUT]];

    [appExecutionStarted unlock];
    
    if (signalReceived) {
        DDLogInfo(@"AppExecution has started: %@", bundleId);
        
        [operationQueue addOperationWithBlock:^(void) {
            // check for timeout
            BOOL signalReceived = YES;
            while (signalReceived) {
                [appExecutionTimeout lock];
                signalReceived = [appExecutionTimeout waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:(AAPilotAppExectionTimeout*60)]];
                [appExecutionTimeout unlock];
                // break if signal received and execution has alredy finished (cancel timeout signal)
                if (signalReceived && appExecutionHasFinished)
                    break;
                
            }
            if (!appExecutionHasFinished) {
                DDLogInfo(@"AppExecution reached timeout! (%@)", bundleId);
                DDLogVerbose(@"sending appExecutionFinishedNotification due to timeout");
                [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionFinished
                                                                               object:nil
                                                                             userInfo:@{@"bundleId":bundleId, @"message":@"timout reached"}];
            }
        }];

        //wait until execution is finished
        [appExecutionFinished lock];
        [appExecutionFinished wait];
        [appExecutionFinished unlock];
        
    } else { // timeout reached
        NSString *msg = @"AppExecution has not started - timeout reached!";
        DDLogError(@"%@ (%@)", msg, bundleId);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionFinished
                                                                       object:nil
                                                                     userInfo:@{@"bundleId":bundleId, @"message":msg}];
    }
    
    // clean up operationQueue
    [operationQueue cancelAllOperations];

    //sleep some time to give other tweaks some time to handle the finished notification
    DDLogVerbose(@"sleep(%i) to give other tweaks some time to handle the finished notification", POST_EXECUTION_FINISHED_SLEEP_TIME);
    sleep(POST_EXECUTION_FINISHED_SLEEP_TIME);
    [__appExecutionLock unlock];
}

- (void)executeAppWithBundleId:(NSString*)bundleId onExecutionFinished:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self executeAppWithBundleId:bundleId];
        // call onExecutionFinished-block
        if (block != nil) {
            block();
        }
    });
}


#pragma mark notification callbacks

- (void)_appExecutionStarted:(NSNotification*)notification {
    DDLogVerbose(@"App execution started notification: %@", notification);
    appExecutionHasFinished = NO;
    [appExecutionStarted lock];
    // use broadcast to wake all threads (should not be necessary but should be safer)
    [appExecutionStarted broadcast];
    [appExecutionStarted unlock];
}

- (void)_appExecutionRunning:(NSNotification*)notification {
    DDLogVerbose(@"App execution running notification: %@", notification);
    [appExecutionTimeout lock];
    [appExecutionTimeout broadcast];
    [appExecutionTimeout unlock];
}

- (void)_appExecutionFinished:(NSNotification*)notification {
    DDLogVerbose(@"App execution finished notification: %@", notification);
    appExecutionHasFinished = YES;
    [appExecutionFinished lock];
    [appExecutionFinished broadcast];
    [appExecutionFinished unlock];

    // cleanup timeout stuff
    [appExecutionTimeout lock];
    [appExecutionTimeout broadcast];
    [appExecutionTimeout unlock];
}

#pragma mark CHConstructor

CHConstructor {
    CHLoadLateClass(NSDistributedNotificationCenter);
}

@end
