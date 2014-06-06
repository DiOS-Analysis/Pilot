//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AARandomExecutor.h"
#import "AAAppExecutor.h"
#import "AAAlertManager.h"

#import "Common.h"
#import "AAClientLib.h"
#import "NSData+Base64.h"
#import "NSArray+Random.h"

#import <Foundation/NSTask.h>

#import "UIAutomation.h"
#import <UIKit/UIAccessibility.h>

#pragma mark AARandomExecutionOperation declaration

@interface AARandomExecutionOperation : NSOperation
- (id)initWithExecutor:(AARandomExecutor*)executor;
@property(readonly)AARandomExecutor* executor;
@end


#pragma mark AARandomExecutor

#define DEFAULT_EXECUTION_TIMEOUT 3*60

static NSDictionary *uiEvents;
static NSMutableArray *uiEventsWeighted;
static UIATarget *localTarget;

@implementation AARandomExecutor

+ (NSValue*)randomScreenPointValue {
    CGSize screenSize = [localTarget.rect CGRectValue].size;
    CGPoint randPoint;
    randPoint.x = arc4random_uniform(screenSize.width);
    randPoint.y = arc4random_uniform(screenSize.height);
    return [NSValue valueWithCGPoint:randPoint];
}

+ (void)initialize {
    localTarget = UIATarget.localTarget;
    
    uiEvents = @{
                 // Syntax: block : weight

                 /// deactivate / reactivate
                 ^{
                     DDLogVerbose(@"Event: deactivate / reactivate");
                     
                     UIAApplication *app = [localTarget frontMostApp];

                     [localTarget deactivateAppForDuration:@"4"];                     
                     // check the reactivation was successfull
                     if ([app.bundleID compare:[localTarget frontMostApp].bundleID] != NSOrderedSame) {
                         DDLogError(@"Execution aborted! - Unable to make app frontmost again!");

                         @throw([[AAAppExecutionException alloc] initWithName:@"AAAppExecutionException"
                                                                      reason:@"Unable to make app frontmost again" 
                                                                    userInfo:nil]);
                     }
                     sleep(1);
                 }: @1,
                 
                 /// set random UIDeviceOrientation
                 ^{
                     DDLogVerbose(@"Event: set random UIDeviceOrientation");
                     // choose between UIDeviceOrientationPortrait, UIDeviceOrientationPortraitUpsideDown, UIDeviceOrientationLandscapeLeft and UIDeviceOrientationLandscapeRight
                     UIDeviceOrientation orientation = (UIDeviceOrientation)(arc4random_uniform((int)UIDeviceOrientationLandscapeLeft + 1));
//                     DDLogVerbose(@"DeviceOrientation: %i", orientation);
                     [localTarget setDeviceOrientation:@(orientation)];
                     sleep(1);
                 }: @4,

                 /// change the location
                 ^{
                     DDLogVerbose(@"Event: change location");
                     NSArray *locations = @[
                                            @{@"latitude":@"37.332", @"longitude":@"-122.030" },
                                            @{@"latitude":@"78.396", @"longitude":@"147.851" },
                                            @{@"latitude":@"27.984", @"longitude":@"86.923" },
                                            @{@"latitude":@"0", @"longitude":@"0" }
                                            ];
                     [localTarget setLocation:[locations randomObject]];
                 }: @5,

#pragma mark device controls
                 ^{
                     DDLogVerbose(@"Event: volume down");
                     [localTarget clickVolumeDown];
                 }: @1,
                 ^{
                     DDLogVerbose(@"Event: volume up");
                     [localTarget clickVolumeUp];
                 }: @1,
                 ^{
                     DDLogVerbose(@"Event: shake");
                     [localTarget shake];
                 }: @1,
                 
                 /// tap a random button
                 ^{
                     DDLogVerbose(@"Event: random button");
                     //TODO include subviews / tab- and toolbars?
                     NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
                     [localTarget pushPatience:1.5];
                     NSArray *buttonSources = @[
                                [localTarget frontMostApp].mainWindow.buttons,
                                [localTarget frontMostApp].mainWindow.tabBar.buttons,
                                [localTarget frontMostApp].mainWindow.navigationBar.buttons];
                     [localTarget popPatience];
                     
                     for (id buttons in buttonSources) {
                         if ([buttons isKindOfClass:[UIAElementArray class]]) {
                             [buttonArray addObjectsFromArray:(UIAElementArray*)buttons];
                         }
                     }
                     UIAButton *button = [buttonArray randomObject];
                     for (int i = 0; i < 5; i++) {
                         if ([button isKindOfClass:[UIAButton class]] &&
                             [button isVisibleBool] &&
                             [button isEnabledBool]) {

                             [button tap];
                             usleep(500);
                             break;
                         }
                         button = [buttonArray randomObject];
                     }
                 }: @20,
    
                 /// tap random point
                 ^{
                     NSValue *point = [self randomScreenPointValue];
                     DDLogVerbose(@"Event: tap %@", point);
                     [localTarget tap:point];
                 }: @40,

                  
                  /// tap random point with options
                  ^{
                      NSUInteger tapCount = arc4random_uniform(3) + 1; //[1 3] taps possible
                      NSUInteger touchCount = arc4random_uniform(4) + 1; //[1 4] fingers allowed
                      float duration = (arc4random() / ((pow(2, 32)-1)) * 4) + 0.5; // [0.5 60[
                      NSValue *point = [self randomScreenPointValue];
                      NSDictionary *options = @{
                                                @"tapCount": [NSString stringWithFormat:@"%lu", (unsigned long)tapCount],
                                                @"touchCount": [NSString stringWithFormat:@"%lu", (unsigned long)touchCount],
                                                @"duration": [NSString stringWithFormat:@"%.2f", duration]
                                                };
                      DDLogVerbose(@"Event: tap: %@ withOptions: %@", point, options);
                      [localTarget tap:point withOptions:options];
                  }: @20,

                  /// flickFromTo
                  ^{
                      NSValue *fromPoint = [self randomScreenPointValue];
                      // try to prevent NotificationCenter activation by swiping down from statusbar
                      while ([[localTarget elementAtPoint:fromPoint] isKindOfClass:[UIAStatusBar class]]) {
                          fromPoint = [self randomScreenPointValue];
                      }
                      NSValue *toPoint = [self randomScreenPointValue];
                      DDLogVerbose(@"Event: flickFrom: %@ To: %@", fromPoint, toPoint);
                      [localTarget flickFrom:fromPoint to:toPoint];
                  }: @15,
                  
                  /// pinchOpenFromToForDuration
                  ^{
                      float duration = (arc4random() / ((pow(2, 32)-1)) * 4) + 0.5; // [0.5 60[
                      NSValue *fromPoint = [self randomScreenPointValue];
                      NSValue *toPoint = [self randomScreenPointValue];
                      DDLogVerbose(@"Event: pinchOpenFrom: %@ To: %@ ForDuration: %.2f", fromPoint, toPoint, duration);
                      [localTarget pinchOpenFrom:fromPoint
                                               to:toPoint
                                      forDuration:[NSString stringWithFormat:@"%.2f", duration]];
                  }: @4,
                  
                  /// pinchCloseFromToForDuration
                  ^{
                      float duration = (arc4random() / ((pow(2, 32)-1)) * 4) + 0.5; // [0.5 60[
                      NSValue *fromPoint = [self randomScreenPointValue];
                      NSValue *toPoint = [self randomScreenPointValue];
                      DDLogVerbose(@"Event: pinchCloseFrom: %@ To: %@ ForDuration: %.2f", fromPoint, toPoint, duration);
                      [localTarget pinchCloseFrom:fromPoint
                                               to:toPoint
                                      forDuration:[NSString stringWithFormat:@"%.2f", duration]];
                  }: @4,
                  
                  
                  /// rotateWithOptions
                  ^{
                      float duration = (arc4random() / ((pow(2, 32)-1)) * 4) + 0.5; // [0.5 60[
                      NSUInteger radius = arc4random_uniform(30) + 20;
                      float rotation = arc4random() / ((pow(2, 32)-1)) * M_PI*2;
                      NSUInteger touchCount = arc4random_uniform(5) + 1;
                      NSValue *centerPoint = [self randomScreenPointValue];
                      NSDictionary *options = @{
                                                @"duration": [NSString stringWithFormat:@"%.2f", duration],
                                                @"radius": [NSString stringWithFormat:@"%lu", (unsigned long)radius],
                                                @"rotation": [NSString stringWithFormat:@"%.2f", rotation],
                                                @"touchCount": [NSString stringWithFormat:@"%lu", (unsigned long)touchCount],
                                                };

                      DDLogVerbose(@"Event: rotate: %@ withOptions: %@", centerPoint, options);
                      [localTarget rotate:centerPoint withOptions:options];
                  }: @4,
                 
    };
    
    // add the events to the array as often as it's weight
    uiEventsWeighted = [[NSMutableArray alloc] initWithCapacity:100];
    [uiEvents enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        int weight = [(NSNumber*)obj intValue];
            for (int i = 0; i < weight; i++) {
                [uiEventsWeighted addObject:key];
            }
    }];
}

- (BOOL)startExecution {
    BOOL result = [super startExecution];
    if (result) {
        
        NSUInteger executionTimeout = DEFAULT_EXECUTION_TIMEOUT;
        if (self.executionTime > 0) {
            executionTimeout = 60*self.executionTime;
        }
        
        [self.queue addOperation:[[AARandomExecutionOperation alloc] initWithExecutor:self]];
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
    DDLogVerbose(@"Alert: %@", alert);
    //TODO "random" Alert handling?
    return [super handleAlert:alert];
}


@end


#pragma mark AARandomExecutionOperation implementation

@implementation AARandomExecutionOperation

- (id)initWithExecutor:(AARandomExecutor*)executor {
    self = [super init];
    if (self) {
        self->_executor = executor;
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
    
    DDLogInfo(@"starting random execution of UI events.");
    while (!self.isCancelled) {
        void(^eventBlock)(void)  = (void(^)(void))[uiEventsWeighted randomObject];
        @try {
            eventBlock();

            usleep(500);

            //check for accediently enabled voiceOver
            if (UIAccessibilityIsVoiceOverRunning()) {
                //disable voiceOver
                DDLogError(@"VoiceOver is active!!! - try to diable it now via home-button tripple-tap!");
                [localTarget clickMenu];
                [localTarget clickMenu];
                [localTarget clickMenu];
                sleep(3);
                if (UIAccessibilityIsVoiceOverRunning()) {
#pragma message "TODO: Improve error handling!"
                    // this is very very ugly! - But it seems there is no easy way to disable VoiceOver otherwise
                    DDLogError(@"VoiceOver is still running!!! - killing SpringBoard now!");
                    NSTask *killSBTask = [[NSTask alloc] init];
                    [killSBTask setLaunchPath: @"/bin/killall"];
                    [killSBTask setArguments: @[@"SpringBoard"]];
                    [killSBTask launch];
                    [killSBTask waitUntilExit];
                    DDLogError(@"SpringBoard should restart now. Executor will exit now!");
                    sleep(10);
                    exit(1);
                }
            }
            
            [localTarget pushPatience:1];
            //check for alerts and wait until dismissed
            int counter = 0;
            while (![localTarget.frontMostApp.alert isKindOfClass:[UIAElementNil class]]) {
                DDLogVerbose(@"Waiting for alert being handled...");
                if (counter == 5) {
                    // it seems alert handling needs to be requested again
                    DDLogVerbose(@"Requesting alert handling again...");
                    [[AAAlertManager sharedInstance] handleAlert:localTarget.frontMostApp.alert];
                    counter = 0;
                }
                counter++;
                sleep(1);
            }
            
            // check for active notification center
            NSValue *point = [NSValue valueWithCGPoint:CGPointMake(100, 100)];
            if ([localTarget isEqual:[localTarget elementAtPoint:point]]) {
                //dismiss NC
                [_executor saveScreenshotToCameraRoll];
                DDLogError(@"NotificationCenter is active! Dismissing now.");
                [localTarget clickMenu];
                [_executor saveScreenshotToCameraRoll];
                usleep(500);
            }
            [localTarget popPatience];
            
            // we need to make sure the app is still frontmost
            //  (may have changed due to several actions like tapping at links, sharing sheet, ...
            if (![_executor.bundleId isEqualToString:UIATarget.localTarget.frontMostApp.bundleID]) {
                DDLogVerbose(@"App under execution is not frontmost. Reactivating now.");
                if (![_executor openApplication]) {
                    DDLogError(@"randomExecution: Failed to reopen application %@. Aborting.", _executor.bundleId);
                    break;
                }
            }
        } @catch (AAAppExecutionException *exception) {
            DDLogError(@"randomExecution: Caught %@: %@. Aborting execution. %@", [exception name], [exception reason], [exception callStackSymbols]);
            break;
        } @catch (NSException *exception) {
            DDLogError(@"randomExecution: Caught %@: %@ : %@", [exception name], [exception reason], [exception callStackSymbols]);
        }
    }
    DDLogVerbose(@"random execution was canceled.");
    
}

@end
