//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "Common.h"
#import "AAClientLib.h"

#import "NSData+Base64.h"
#import "NSArray+Random.h"
#import "NSSet+Random.h"

#import <UIKit/UIScreen.h>
#import "UIAutomation.h"
#import "UIAElement+SmartExecution.h"
#import "UIAElementArray+SmartExecution.h"

#import "AAGenericAlertHandler.h"

#import "AASmartExecutor.h"
#import "AASEView.h"
#import "AASEOtherApplicationView.h"

#import "AASEGraph.h"

#pragma mark AASmartExecutionOperation declaration

@interface AASmartExecutionOperation : NSOperation
- (id)initWithExecutor:(AASmartExecutor*)executor;
@property(readonly)AASmartExecutor* executor;
@end


#pragma mark AASmartExecutor

#define DEFAULT_EXECUTION_TIMEOUT 3*60

@implementation AASmartExecutor

UIATarget *localTarget;

+ (void)initialize {
    localTarget = UIATarget.localTarget;
}

- (BOOL)startExecution {
    BOOL result = [super startExecution];
    if (result) {

        NSUInteger executionTimeout = DEFAULT_EXECUTION_TIMEOUT;
        if (self.executionTime > 0) {
            executionTimeout = 60*self.executionTime;
        }
        
        [self.queue addOperation:[[AASmartExecutionOperation alloc] initWithExecutor:self]];
        NSCondition *executionTimeoutReached = [[NSCondition alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [executionTimeoutReached lock];
            [executionTimeoutReached waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:executionTimeout]];
            [executionTimeoutReached unlock];
            
            DDLogInfo(@"execution timeout reached. Execution will be canceled now.");
            [self.queue cancelAllOperations];
            [self.queue waitUntilAllOperationsAreFinished];
            [self setExecutionFinished];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.queue waitUntilAllOperationsAreFinished];
            [executionTimeoutReached signal];
        });
    }
    return result;
}


- (BOOL)handleAlert:(UIAAlert*)alert {
    DDLogVerbose(@"-[AASmartExecutor handleAlert:]: %@", alert);
    return true; // alert handling is done via runExecution
}

- (NSArray*)bundleIds {
    return @[self.bundleId];
}

@end


#pragma mark AASmartExecutionOperation implementation

@interface AASmartExecutionOperation ()

@property() AASEGraph *executionGraph;

@end

@implementation AASmartExecutionOperation

- (id)init {
    self = [super init];
    if (self) {
        _executionGraph = [[AASEGraph alloc] init];
    }
    return self;
}

- (id)initWithExecutor:(AASmartExecutor*)executor {
    self = [self init];
    if (self) {
        _executor = executor;
    }
    return self;
}


- (void)main {
    
    if ([_executor isLoginRegisterView]) {
        DDLogInfo(@"login window detected. Saving screenshot to backend");
        UIImage *screenshot = [_executor takeScreenshot];
        NSString *screenshotBase64 = [UIImagePNGRepresentation(screenshot) base64String];
        NSDictionary *resultDict = @{
                                     @"data": screenshotBase64,
                                     @"message": @"login required"
                                     };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[AAClientLib sharedInstance] saveResult:resultDict withType:AACResultTypeScreenshot];
            DDLogInfo(@"Screenshot saved to backend.");
        });
        DDLogInfo(@"Try to do some stuff without login / account.");
    }
    
    DDLogInfo(@"starting smart execution.");
    @try {
        [self runExecution];
    } @catch (AAAppExecutionException *exception) {
        DDLogError(@"smartExecution: Caught %@: %@. Aborting execution.", [exception name], [exception reason]);
    } @catch (NSException *exception) {
        DDLogError(@"smartExecution: Caught %@: %@", [exception name], [exception reason]);
//        @throw exception;
    }
    DDLogVerbose(@"smart execution exited.");
}


- (void)runExecution {
    DDLogVerbose(@"-[AASmartExecutor exec]");

    UIATarget *target = UIATarget.localTarget;
    
    // validate frontmostapp is app under execution
    if (![target.frontMostApp.bundleID isEqualToString:_executor.bundleId]) {
        DDLogWarn(@"App under execution is not frontmost! Try to open it now.");
        if (![target openApplication:_executor.bundleId]) {
            DDLogError(@"Unable to open app under execution. Aborting.");
            return;
        }
    }

    [target pushPatience:2.5];

    UIAWindow *window = target.frontMostApp.mainWindow;

    NSMutableSet *seViews = [[NSMutableSet alloc] init];
    NSMutableSet *openViews = [[NSMutableSet alloc] init];
    NSMutableSet *pausedViews = [[NSMutableSet alloc] init];
    
    AASEView *tmpView = nil;
    AASEView *prevSeView = nil;
    // pre-initialize the "start-view"
    AASEView *seView = [[AASEView alloc] initWithUIAWindow:window];
    [seViews addObject:seView];
    [openViews addObject:seView];
    [_executionGraph addView:seView];
    
    // the current element under execution
    AASEElement *actionElement = nil;
    
    // a counter used to wait some times prior to finishing the execution
    // due to missing pending views
    int waitCounter = 0;
    
    DDLogVerbose(@"-[AASmartExecutor exec] starting execution loop");
    while(!self.isCancelled) {
        // execution loop will break if no pending action elements are left
 
        // 1) selection: choose next action
        // optimize (threshold for list elements execution)
        // sequencing
        // (context ? - fill forms?)
        
        //search for inputs (recursivly search scrollviews too)
        // set inputs / change switches ,...
        
        
        // check pre execution state
        actionElement = nil;
        
        //  2.1.1) get next action
        // execute view elements until every action was triggered
        // search for unexecuted actions
        
        // This method should be called even on finished views to ensure there is no action anymore.
        // But more important: It will fill some input fields which may enable some necessary buttons 
        actionElement = [seView nextActionElement];
        
        if (actionElement == nil) {
            // 2.1.2) the current view is fully executed
            //        navigate to other view if possible

            NSMutableSet *pendingViews = [[NSMutableSet alloc] initWithSet:openViews];
            [pendingViews unionSet:pausedViews];

            for (AASEView *view in pendingViews) {
#pragma message "TODO: avoid recalculating the path all the time. Do proper caching!!!"
                actionElement = [_executionGraph pathFromView:seView toView:view][0];
                if (actionElement != nil)
                    break;
            }
            
            // stop the execution after waiting some times for new stuff to happen
            if (actionElement == nil) {
                // wait some times to be able to tolerate "loading" screens
                if (waitCounter < 5) {
                    waitCounter++;
                    DDLogInfo(@"-[AASmartExecutor exec] no executable element found - waiting some time.");
                    sleep(5);
                    DDLogVerbose(@"-[AASmartExecutor exec] ... retrying now");
                } else {
                    // STOP EXECUTION HERE
                    if ([pendingViews count] == 0) {
                        DDLogInfo(@"-[AASmartExecutor exec] execution sucessfully finished.");
                    } else {
                        DDLogInfo(@"-[AASmartExecutor exec] pending views not reachable - aborting execution.");
                        DDLogVerbose(@"Pending views: %@", pendingViews);
                    }
                    [self cancel];
                    break;
                }
            }
        }

        if (actionElement != nil) {
            // 2.2) execute the prepared action element
            [self _executeElement:actionElement];
        } else {
            DDLogError(@"-[AASmartExecutor exec]: no action element found.");
        }
        
        // check post execution state
        AASEExecutionState state = [seView executionState];
        
        switch (state) {
            case kSEStateOpen:
                [pausedViews removeObject:seView];
                [openViews addObject:seView];
                break;
            case kSEStatePaused:
                // remove the view if already paused to avoid endless looping
                if ([pausedViews member:seView] == nil) {
                    [pausedViews addObject:seView];
                    [openViews removeObject:seView];
                }
                break;
            case kSEStateDone:
                [pausedViews removeObject:seView];
                [openViews removeObject:seView];
                break;
        }
        
        /// wait some time to give gui actions some more time to finish
        sleepRunloop(6); // may return earlier than the given time
        sleep(3);

        
        // 3) post execution analysis
        
        
        // check for simple alerts (like permission requests) and handle them via generic handler
        UIAAlert *alert = target.frontMostApp.alertSync;
        int alertCounter = 0;
        while (alert != nil && [alert isKindOfClass:[UIAAlert class]]) {
            DDLogInfo(@"Alert: %@", alert);
            if ([UIATarget.localTarget.frontMostApp.bundleID isEqualToString:_executor.bundleId]) {
                AASEView *alertView = [[AASEView alloc] initWithUIAWindow:target.frontMostApp.mainWindow];
                if (![alertView hasInputElements]) {
                    [_executor saveScreenshotToCameraRoll];
                    [[[AAGenericAlertHandler alloc] init] handleAlert:alert];
                    sleep(2); // wait some time until the alert dismiss has finished
                }
            } else {
                // avoid unhandled alerts
                alertCounter++;
                if (alertCounter > 5) {
                    [[AAAlertManager sharedInstance] handleAlert:alert];
                    alertCounter = 0;
                }
                sleep(1); // wait until the none-app alert has disappeared
            }
            alert = target.frontMostApp.alertSync;
        }
        
        
        // update view variables
        prevSeView = seView;
        
        /// 3.1) detect other applications (started via last action)
        /// set seView to special view if the app has changed
        NSString *frontMostAppBundleId = target.frontMostApp.bundleID;
        DDLogInfo(@"frontMostAppBundleId: %@", frontMostAppBundleId);
        if (![frontMostAppBundleId isEqualToString:_executor.bundleId]) {
            
            /* other app data currently not needed
             tmpView = [[AASEOtherApplicationView alloc]initWithBundleId:frontMostAppBundleId];
             seView = [seViews member:tmpView];
             if (seView == nil) {
             seView = tmpView;
             [seViews addObject:seView];
             [_executionGraph addView:seView];
             [_executionGraph addEdgeFromView:prevSeView toView:seView withElement:actionElement];
             DDLogVerbose(@"-[AASmartExecutor exec]: Added new view");
             }
             */
            DDLogVerbose(@"smartExecution: App under execution is not frontmost. Trying to reactivate the app.");
            // try to reopen the application
            if (![_executor openApplication]) {
                DDLogError(@"smartExecution: Failed to reopen application %@. Aborting.", _executor.bundleId);
                [self cancel];
            }
        }
        
        /// update windows variables
        window = target.frontMostApp.mainWindow;
        
        /// 3.2) Add new view if not already known

        // 3.2.1) matching: check if window is already known
        tmpView = [[AASEView alloc] initWithUIAWindow:window];
        seView = [seViews member:tmpView];
        if (seView == nil) {
            seView = tmpView;
            [seViews addObject:seView];
            [openViews addObject:seView];
            [_executionGraph addView:seView];
            DDLogVerbose(@"-[AASmartExecutor exec]: Added new view");
        }
        
        /// 3.3) Store action details to graph
        if (actionElement != nil)
            [_executionGraph addEdgeFromView:prevSeView toView:seView withElement:actionElement];
    }
    [target popPatience];
    DDLogVerbose(@"-[AASmartExecutor exec] execution ended");
}


- (void)_executeElement:(AASEElement*)actionElement {
    DDLogVerbose(@"-[AASmartExecutor _executeElement:] element: %@", actionElement);

    UIAElement *uiaElement = actionElement.uiaElement;
    @try {
        [uiaElement scrollToVisible];
        // TODO handle some special types
        if ([uiaElement isKindOfClass:[UIAImage class]]) {
            [UIATarget.localTarget tap:uiaElement.centerpoint];
        } else {
            // try to tap via hitpoint if possible (this should make tapping more reliable)
            /// (at least for UIAlerts with active keyboard
            if (uiaElement.hitpoint != nil && ![uiaElement.hitpoint isKindOfClass:[UIAElementNil class]]) {
                [UIATarget.localTarget tap:uiaElement.hitpoint];
            }
            [uiaElement tap];
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"smartExecution: Executing the element %@ failed. Caught %@: %@", uiaElement, [exception name], [exception reason]);
    }
}

@end
