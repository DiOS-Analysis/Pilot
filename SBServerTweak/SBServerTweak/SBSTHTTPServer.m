//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSTHTTPServer.h"
#import "Common.h"

#import "SBSTAppStoreManager.h"
#import "SBSTCydiaStoreManager.h"
#import "SBSTSpringBoardManager.h"
#import "SBSTCycriptExecutor.h"
#import "SBSTAppExecutionManager.h"

#define HTTP_CODE_BAD_REQUEST @400
#define HTTP_CODE_LOCKED @423
#define HTTP_CODE_NOT_IMPLEMENTED @501

#define STATUS_TASK_RUNNING @"taskRunning"
#define STATUS_TASK_INFO @"taskInfo"

#define TASK_CALLBACK_URL @"callback-url"

#define RESPONSE_CODE @"code"
#define RESPONSE_MESSAGE @"message"

@interface SBSTHTTPServer()
- (BOOL)_requestTaskRunWithTaskInfo:(NSDictionary*)taskInfo;
- (void)_setTaskFinished;
- (NSDictionary*)_taskInfoFromRequestDict:(NSDictionary*)requestDict;
- (void)_AppStoreRequestFinished;
@end

@implementation SBSTHTTPServer {
    NSMutableDictionary *statusDict;
    NSMutableDictionary *statusTaskInfo;
    NSMutableDictionary *taskData;
    SBSTAppStoreManager *appStoreManager;
    SBSTAppExecutionManager *execManager;
}

@synthesize http;

+ (SBSTHTTPServer*)sharedInstance {
    static SBSTHTTPServer *sharedSingleton;
    
    @synchronized(self) {
        if (!sharedSingleton)
            sharedSingleton = [[SBSTHTTPServer alloc] init];
        return sharedSingleton;
    }
}

- (id)init {
    self = [super init];
    if(self) {
        statusTaskInfo = [[NSMutableDictionary alloc] init];
        statusDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                 STATUS_TASK_RUNNING:@NO,
                                                 STATUS_TASK_INFO:statusTaskInfo
                      }];
        taskData = [[NSMutableDictionary alloc] init];
        isCmdRunning = NO;
        
        appStoreManager = [[SBSTAppStoreManager alloc] init];
        execManager = [[SBSTAppExecutionManager alloc] init];
        
        __weak SBSTHTTPServer *weakSelf = self;
        [appStoreManager setRequestFinishedBlock:^(NSString *error) {
            SBSTHTTPServer *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf _AppStoreRequestFinished];
            } else {
                DDLogError(@"Request finished and weak reference to self not present anymore!!!");
            }
        }];
        
        
        self.http = [[RoutingHTTPServer alloc] init];
        [http setDefaultHeader:@"Server" value:@"SBHTTPServer/1.0"];
//        [self.http setType:@"http._tcp."];
        [self.http setPort: 8080];
        [self setupRoutes];
    }
    return self;
}



- (NSMutableDictionary*)_defaultResponseDict{
    return [[NSMutableDictionary alloc] initWithDictionary:@{
                                             RESPONSE_CODE:@200,
                                          RESPONSE_MESSAGE:@"OK"
            }];
}


#pragma mark The routes

- (void)setupRoutes {
    [self.http get:@"/status" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:statusDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    [self.http get:@"/applications" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSDictionary *responseDict = [SBSTSpringBoardManager applicationInfo];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    [self.http post:@"/install/appstore" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        NSData *requestBody = request.body;
        if (requestBody==nil) {
            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
            responseDict[RESPONSE_MESSAGE] = @"empty request";
        } else {
            
            NSError *error;
            NSDictionary *requestDict = [NSJSONSerialization JSONObjectWithData:requestBody
                                                                        options:0
                                                                          error:&error];
            DDLogVerbose(@"RequestDict: %@", requestDict);
            DDLogVerbose(@"Error: %@", error);
            
            NSDictionary *appInfo = requestDict[@"appInfo"];
            DDLogVerbose(@"appInfo: %@", appInfo);
            if(![appInfo isKindOfClass:[NSDictionary class]]) {
                responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
                responseDict[RESPONSE_MESSAGE] = @"Missing or invalid parameter: appInfo";
                
            } else {
                NSNumber *accountIdentifier = @0;
                id accIdVal = requestDict[@"accountIdentifier"];
                if ([accIdVal isKindOfClass:[NSNumber class]]) {
                    accountIdentifier = accIdVal;
                } else if ([accIdVal isKindOfClass:[NSString class]]) {
                    accountIdentifier = @([accIdVal longLongValue]);
                }
                DDLogVerbose(@"accountIdentifier: %@", accountIdentifier);
                if ([accountIdentifier isEqualToNumber:@0]) {
                    responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
                    responseDict[RESPONSE_MESSAGE] = @"Missing parameter: accountIdentifier";

                } else {
                     // ensure clean instance variables
                    if ([self _requestTaskRunWithTaskInfo:[self _taskInfoFromRequestDict:requestDict]]) {
                        
                        //check if callback is present
                        NSString *callbackUrl = requestDict[@"callback"];
                        if (callbackUrl != nil) {
                            DDLogVerbose(@"CallbackURL: %@", callbackUrl);
                            taskData[TASK_CALLBACK_URL] = callbackUrl;
                        }
                        
                        // initiate purchase
                        if (![appStoreManager initiateAppPurchase:appInfo
                                   withAccountForUniqueIdentifier:accountIdentifier]) {
                            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
                            responseDict[RESPONSE_MESSAGE] = @"Install failed";
                            [self _setTaskFinished];

                        } else {
                            responseDict[RESPONSE_MESSAGE] = @"Install successfull";
                            // task will be set finished via _AppStoreRequestFinished
                        }
                        
                    } else {
                        responseDict[RESPONSE_CODE] = HTTP_CODE_LOCKED;
                    }
                }
            }
        }
        
        
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    [self.http post:@"/install/cydia" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        NSData *requestBody = request.body;
        if (requestBody==nil) {
            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
            responseDict[RESPONSE_MESSAGE] = @"empty request";
        } else {
            
            NSError *error;
            NSDictionary *requestDict = [NSJSONSerialization JSONObjectWithData:requestBody
                                                                        options:0
                                                                          error:&error];
            DDLogVerbose(@"RequestDict: %@", requestDict);
            DDLogVerbose(@"Error: %@", error);
            
            NSString *bundleId = requestDict[@"bundleId"];
            DDLogInfo(@"Installing cydia app: %@", bundleId);
            
            // ensure secure and clean instance variables
            if ([self _requestTaskRunWithTaskInfo:[self _taskInfoFromRequestDict:requestDict]]) {
                
                if (![SBSTCydiaStoreManager installApplicationForBundleId:bundleId]) {
                    responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
                    responseDict[RESPONSE_MESSAGE] = @"Install failed";
                    
                } else {
                    responseDict[RESPONSE_MESSAGE] = @"Install successfull";
                }
                [self _setTaskFinished];
                
            } else {
                responseDict[RESPONSE_CODE] = HTTP_CODE_LOCKED;
            }
        }
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    
    
    
    [self.http post:@"/open/:bundleId" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        NSString *bundleId = [request param:@"bundleId"];
        if (bundleId==nil) {
            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
            responseDict[RESPONSE_MESSAGE] = @"bundleId missing";
        } else {
            if ([self _requestTaskRunWithTaskInfo:@{}]) {
                DDLogInfo(@"openApplication: %@", bundleId);
                [SBSTSpringBoardManager unlock];
                [SBSTSpringBoardManager openApplicationForBundleId:bundleId];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
                [self _setTaskFinished];
            } else {
                responseDict[RESPONSE_CODE] = HTTP_CODE_LOCKED;
                responseDict[RESPONSE_MESSAGE] = @"A task is already running";
            }
        }
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    
    [self.http post:@"/execute/:bundleId" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        NSString *bundleId = [request param:@"bundleId"];
        if (bundleId==nil) {
            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
            responseDict[RESPONSE_MESSAGE] = @"bundleId missing";
        } else {
            NSError *error;
            NSDictionary *requestDict = [NSJSONSerialization JSONObjectWithData:request.body
                                                                        options:0
                                                                          error:&error];
            DDLogVerbose(@"RequestDict: %@", requestDict);
            DDLogVerbose(@"Error: %@", error);
            
            if ([self _requestTaskRunWithTaskInfo:[self _taskInfoFromRequestDict:requestDict]]) {
                [SBSTSpringBoardManager unlock];
                [SBSTSpringBoardManager dismissAlerts];
                [SBSTSpringBoardManager openApplicationForBundleId:bundleId];
                //wait some time until app has started
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
                [execManager executeAppWithBundleId:bundleId onExecutionFinished:^{
                    sleep(5);
                    [SBSTSpringBoardManager killApplicationForBundleId:bundleId];
                    sleep(10);
                    [self _setTaskFinished];
                }];
            } else {
                responseDict[RESPONSE_CODE] = HTTP_CODE_LOCKED;
                responseDict[RESPONSE_MESSAGE] = @"A task is already running";
            }
        }
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];

    
    [self.http post:@"/inject" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        NSData *requestBody = request.body;
        if (requestBody==nil) {
            responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
            responseDict[RESPONSE_MESSAGE] = @"empty request";
        } else {
            
            NSError *error;
            NSDictionary *requestDict = [NSJSONSerialization JSONObjectWithData:requestBody
                                                                        options:0
                                                                          error:&error];
            DDLogVerbose(@"RequestDict: %@", requestDict);
            DDLogVerbose(@"Error: %@", error);
            
            NSString *process = requestDict[@"process"];
            NSString *command = requestDict[@"command"];
            
            if (process == nil || command == nil) {
                responseDict[RESPONSE_CODE] = HTTP_CODE_BAD_REQUEST;
                responseDict[RESPONSE_MESSAGE] = @"Missing parameter: process/command";
                
            } else {
                //check lock and run if possible
                if ([self _requestTaskRunWithTaskInfo:[self _taskInfoFromRequestDict:requestDict]]) {                    
                    
                    NSDictionary *results = [SBSTCycriptExecutor run:process withCommand:command];
                    [responseDict addEntriesFromDictionary:results];
                    
                    [self _setTaskFinished];
                } else {
                    responseDict[RESPONSE_CODE] = HTTP_CODE_LOCKED;
                    responseDict[RESPONSE_MESSAGE] = @"A task is already running";
                }
            }
        }
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
        [response respondWithData:[NSJSONSerialization dataWithJSONObject:responseDict
                                                                  options:0
                                                                    error:nil]];
    }];
    
    
    [self.http get:@"/reset" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSMutableDictionary *responseDict = [self _defaultResponseDict];
        
        DDLogWarn(@"%@ resetting internal state!!!", [self class]);
        [self _setTaskFinished];
        
        [response setStatusCode:[responseDict[RESPONSE_CODE] integerValue]];
    }];

}


#pragma mark Task management

//check if task can run
- (BOOL)_requestTaskRunWithTaskInfo:(NSDictionary*)taskInfo {
    DDLogVerbose(@"-[SBSTHTTPServer _requestTaskRunWithTaskInfo:] - %@", taskInfo);
    BOOL canRun = false;
    @synchronized(self) {
        if (!isCmdRunning) {
            isCmdRunning = true;
            canRun = true;
        }
    }
    if (canRun) {
        statusDict[STATUS_TASK_RUNNING] = @YES;
        if (taskInfo != nil) {
            [statusTaskInfo addEntriesFromDictionary:taskInfo];
        }
    }
    return canRun;
}

//set task finished
- (void)_setTaskFinished {
    DDLogVerbose(@"-[SBSTHTTPServer _setTaskFinished]");
    [taskData removeAllObjects];
    [statusTaskInfo removeAllObjects];
    [statusDict removeAllObjects];
    statusDict[STATUS_TASK_INFO] = statusTaskInfo;
    statusDict[STATUS_TASK_RUNNING] = @NO;
    isCmdRunning = false;
}

- (NSDictionary*)_taskInfoFromRequestDict:(NSDictionary*)requestDict {
    id taskInfoValue = requestDict[STATUS_TASK_INFO];
    if ([taskInfoValue isKindOfClass:[NSDictionary class]]) {
        return taskInfoValue;
    } else {
        return nil;
    }
}


//callback for requests
- (void)_AppStoreRequestFinished {
    NSString *callbackUrl = taskData[TASK_CALLBACK_URL];
    
    [self _setTaskFinished];
    
    NSURL *url = [NSURL URLWithString:callbackUrl];
    if (url!=nil) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPBody:nil];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        }];
    }
}


#pragma mark Server start/stop

- (void)startServer {
    NSError *error;
    if([http start:&error]) {
		DDLogInfo(@"Started HTTP Server on port %hu", [http listeningPort]);
	} else {
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

- (void)stopServer {
    if(http) {
        [http stop];
        DDLogInfo(@"Stopped HTTP Server on port %hu", [http listeningPort]);
    }
}

@end
