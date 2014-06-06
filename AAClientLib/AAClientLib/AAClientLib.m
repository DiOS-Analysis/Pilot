//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/NSDistributedNotificationCenter.h>
#import <AAPilotNotification.h>
#import "AAClientLib.h"

#define SBSTBaseURL @"http://127.0.0.1:8080"

NSString *const AACResultTypeAppArchive = @"app_archive";
NSString *const AACResultTypeCriteria = @"criteria";
NSString *const AACResultTypeScreenshot = @"screenshot";
NSString *const AACResultTypeTcpdump = @"tcpdump";
NSString *const AACResultTypeStackTrace = @"stacktrace";
NSString *const AACResultTypeMethodCoverage = @"coverage";
NSString *const AACResultTypeString = @"string";

NSString *const AACNotificationAppExecutionStarted = @"AACNotificationAppExecutionStarted";
NSString *const AACNotificationAppExecutionFinished = @"AACNotificationAppExecutionFinished";

@implementation NSDictionary (AAClientLib)

- (NSString *)runId {
    return self[@"runId"];
}

- (NSString *)backendURL {
    NSString* backendURL = self[@"backendUrl"];
    return [NSString stringWithFormat:@"%@/results", backendURL];
}

@end

@interface AAClientLib()

// execution state
@property() NSMutableDictionary *blocksMap;

//The currently requested bundleId
@property() NSString *executionStartRequestedBundleId;

@property() NSTimer *setExecutionRunningTimer;

@end


@implementation AAClientLib

- (id)init {
    self = [super init];
    if(self) {
        
        // initialize arrays
        _blocksMap = [[NSMutableDictionary alloc]init];
        for (NSString *notification in AAPilotNotifications) {
            (_blocksMap)[notification] = [[NSMutableArray alloc]init];
        }
        [self _resetState];
        
        // add observers
        NSDistributedNotificationCenter *notificationCenter = [NSDistributedNotificationCenter defaultCenter];

        for (NSString *notification in AAPilotNotifications) {
            [notificationCenter addObserver:self
                                   selector:@selector(_notificationCallback:)
                                       name:notification
                                     object:nil];
        }

    }
    return self;
}

- (void)dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

// reset internal object state to initial
- (void)_resetState {
    @synchronized(self) {
        //reset status flags
        _executionStartRequested = FALSE;
        _executionStarted = FALSE;
        _executionFinishRequested = FALSE;
        
        _executionStartRequestedBundleId = nil;
    }
}

+ (AAClientLib*)sharedInstance {
    static AAClientLib *singleton;
    
    @synchronized(self) {
        if (!singleton) {
            singleton = [[AAClientLib alloc] init];
        }
        return singleton;
    }
}

#pragma mark result handling

- (BOOL)saveResult:(id)result {
    return [self saveResult:result withType:AACResultTypeString];
}

- (BOOL)saveResult:(id)result withType:(NSString*)type {
    NSDictionary *taskInfo = [self taskInfo];
    
    if (taskInfo) {
        return [self saveResult:result withType:type andTaskInfo:taskInfo];
    }
    
    return FALSE;
}

- (BOOL)saveResult:(id)result withType:(NSString *)type andTaskInfo:(NSDictionary *)taskInfo {
    if (taskInfo != nil) {
        NSMutableURLRequest *request = [self requestForResult:result withType:type andTaskInfo:taskInfo];
        
        NSURLResponse* urlResponse;
        NSLog(@"AAClient: Saving result to backend %@ with runId %@", [taskInfo backendURL], [taskInfo runId]);
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
        if (response != nil) {
            return TRUE;
        }
    }
    
    return FALSE;
}

- (NSData *)resultData:(id)result withType:(NSString *)type forRunId:(NSString *)runId {
    NSDictionary* requestDict = @{
                                  @"run": runId,
                                  @"resultInfo": @{
                                          @"type": type,
                                          @"data": result,
                                          },
                                  };
    
    return [NSJSONSerialization dataWithJSONObject:requestDict options:kNilOptions error:nil];
}

- (NSMutableURLRequest *)requestForResult:(id)result withType:(NSString *)type andTaskInfo:(NSDictionary*)taskInfo {
    NSData *requestData = [self resultData:result withType:type forRunId:[taskInfo runId]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[taskInfo backendURL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    return request;
}


#pragma mark some utility methods

// request the execution of the app specified by the given bundleId
- (void)requestAppExecution:(NSString*)bundleId {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionRequestStart
                                                                   object:nil
                                                                 userInfo:@{@"bundleId":bundleId}];   
}

//get the current taskInfo dict
- (NSDictionary*)taskInfo {
    NSDictionary* taskInfo = nil;
    
    // get info from SpringBoard Tweak
    NSURL *url = [NSURL URLWithString:[SBSTBaseURL stringByAppendingString:@"/status"]];
    NSError* error;
    NSData* data = [NSData dataWithContentsOfURL:url options:kNilOptions error:&error];
    if (data == nil) {
        NSLog(@"AAClient: SBST could not be reached!");
    } else {
        NSError* error;
        NSDictionary* status = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (status == nil) {
            NSLog(@"AAClient: SBST returned none or invaild data!");
        } else {
            if ([status[@"taskRunning"] isEqual:@NO]) {
                NSLog(@"AAClient: SBST-Error: Currently no task running!");
            } else {
                taskInfo = status[@"taskInfo"];
            }
        }
    }
    return taskInfo;
}


#pragma callback handling

- (void)registerForNotification:(NSString*)notification withBlock:(void(^)(void))block {
    @synchronized(self) {
        [_blocksMap[notification] addObject:block];
    }
}

- (void)registerForAppExecutionRequestStartNotificationWithBlock:(void(^)(NSString *bundleId))block {
    @synchronized(self) {
        [_blocksMap[AAPilotAppExecutionRequestStart] addObject:block];
    }
}

- (void)_notificationCallback:(NSNotification*)notification {

    // some special handling
    if ([notification.name isEqualToString:AAPilotAppExecutionRequestStart]) {
        @synchronized(self) {
            _executionStartRequested = TRUE;
        }

    } else if ([notification.name isEqualToString:AAPilotAppExecutionStarted]) {
        @synchronized(self) {
            _executionStarted = TRUE;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:AACNotificationAppExecutionStarted object:nil];


    } else if ([notification.name isEqualToString:AAPilotAppExecutionRequestFinish]) {
        //require a started execution
//        if (!_executionStarted) {
//            NSLog(@"AAClient: ignoring AAPilotAppExecutionRequestFinish. No running execution.");
//            return;
//        }
        _executionFinishRequested = TRUE;

    } else if ([notification.name isEqualToString:AAPilotAppExecutionFinished]) {
        //require a started execution
//        if (!_executionStarted) {
//            NSLog(@"AAClient: ignoring AAPilotAppExecutionFinished. No running execution.");
//            return;
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_setExecutionRunningTimer.isValid) {
                NSLog(@"invalidating execution timer");
                [_setExecutionRunningTimer invalidate];
            }
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:AACNotificationAppExecutionFinished object:nil];
        [self _resetState];
    }

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    @synchronized(self) {
        for (__strong dispatch_block_t block in _blocksMap[notification.name]) {
            
            if ([notification.name isEqualToString:AAPilotAppExecutionRequestStart]) {
                NSString *bundleId = nil;
                // check bundleId if present
                NSDictionary *userInfo = [notification userInfo];
                if (userInfo != nil) {
                    bundleId = userInfo[@"bundleId"];
                }
                block = ^{
                    ((void(^)(NSString*))block)(bundleId);
                };
            }
            dispatch_async(queue, block);
        }
    }
}


#pragma mark execution state handling


- (void)setAppExecutionHasStartedAndAutoScheduleSetRunning:(BOOL)scheduleRunning {

//    @synchronized(self) {
//        if (_executionStarted)
//            return;
//    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionStarted
                                                                   object:nil];
    if (scheduleRunning) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            double interval = AAPilotAppExectionTimeout*60-15;
            NSLog(@"interval: %f seconds", interval);
            if (_setExecutionRunningTimer.isValid) {
                [_setExecutionRunningTimer invalidate];
            }
            _setExecutionRunningTimer = nil;
            _setExecutionRunningTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                                     interval:interval
                                                                       target:self
                                                                     selector:@selector(_timerFired:)
                                                                     userInfo:nil
                                                                      repeats:true];
            [[NSRunLoop mainRunLoop] addTimer:_setExecutionRunningTimer
                                      forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)_timerFired:(NSTimer*)timer {
   [self setAppExecutionRunning];
}

- (void)setAppExecutionRunning {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionRunning object:nil];
}

- (void)setAppExecutionHasFinished {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AAPilotAppExecutionFinished object:nil];
}

@end
