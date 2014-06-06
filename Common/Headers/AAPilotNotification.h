//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#ifndef _AAPilotNotifications_h
#define _AAPilotNotifications_h

#import <Foundation/NSArray.h>

// App-state related notifications
//// prior to starting the app
static NSString *const AAPilotAppWillStart = @"AAPilotAppWillStart";
//// app has just started
static NSString *const AAPilotAppStarted = @"AAPilotAppStarted";
//// app will be killed soon - app is still running (maybe even frontmost)
static NSString *const AAPilotAppWillExit = @"AAPilotAppWillExit";
//// app exited
static NSString *const AAPilotAppExited = @"AAPilotAppExited";


// Execution-state related notification

// These notifications will be received by SBSTAppExecutionManager
static NSString *const AAPilotAppExecutionStarted = @"AAPilotAppExecutionStarted";
static NSString *const AAPilotAppExecutionFinished = @"AAPilotAppExecutionFinished";

/// this notification can be used to reset the execution timeout
static NSString *const AAPilotAppExecutionRunning = @"AAPilotAppExecutionRunning";

/// the app execution timeout in minutes
///  the app will be killed after this period without a running notification
static NSInteger const AAPilotAppExectionTimeout = 1;


// These notifications will be sent by SBSTAppExecutionManager
static NSString *const AAPilotAppExecutionRequestStart = @"AAPilotAppExecutionRequestStart";
static NSString *const AAPilotAppExecutionRequestFinish = @"AAPilotAppExecutionRequestFinish";

static NSArray *AAPilotNotifications = nil;


__attribute__((constructor)) static void initialize_pilotNotifications()  {
  AAPilotNotifications = @[
                           AAPilotAppWillStart,
                           AAPilotAppStarted,
                           AAPilotAppWillExit,
                           AAPilotAppExited,
                           AAPilotAppExecutionStarted,
                           AAPilotAppExecutionFinished,
                           AAPilotAppExecutionRunning,
                           AAPilotAppExecutionRequestStart,
                           AAPilotAppExecutionRequestFinish
                           ];
}

#endif
