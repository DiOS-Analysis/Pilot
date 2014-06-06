//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAClientLibTests.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import "AAClientLib.h"


@implementation AAClientLibTests

static NSMutableArray *receicedNotifications = nil;
static NSTimer *timer = nil;

- (void)setUp
{
    [super setUp];
    receicedNotifications = [[NSMutableArray alloc]init];
    timer = [[NSTimer alloc]init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

+ (void)sendNotification:(NSString*)notification {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

- (void)testRequestExecution {
    __block BOOL requestExecutionCalled = FALSE;
    AAClientLib *client = [AAClientLib sharedInstance];

    [client registerForAppExecutionRequestStartNotificationWithBlock:^(NSString *bundleId) {
        requestExecutionCalled = TRUE;
        NSLog(@"requestStartCalled: %@", bundleId);
    }];
    
    [client requestAppExecution:@"de.fau.cs.test"];
    
    for (int i = 0; i < 5; ++i) {
        if (requestExecutionCalled)
            break;
        sleep(1);
    }
    XCTAssertTrue(requestExecutionCalled, @"requestExecution not called");
}

- (void)notificationsTestHelper {

    AAClientLib *client = [AAClientLib sharedInstance];
    
    NSMutableArray *notifications = [[NSMutableArray alloc] initWithArray:@[
                               AAPilotAppWillStart,
                               AAPilotAppStarted,
                               AAPilotAppWillExit,
                               AAPilotAppExited,
                               AAPilotAppExecutionRequestStart,
                               AAPilotAppExecutionStarted,
                               AAPilotAppExecutionRunning,
                               AAPilotAppExecutionRequestFinish,
                               AAPilotAppExecutionFinished
                            ]];
    
    for (NSString *notification in notifications) {
        [client registerForNotification:notification withBlock:^{
            NSLog(@"notification received: %@", notification);
            [notifications removeObject:notification];

            if ([notification isEqualToString:AAPilotAppWillStart]) {
                [AAClientLibTests sendNotification:AAPilotAppStarted];
                
            } else if ([notification isEqualToString:AAPilotAppStarted]) {
                [client requestAppExecution:@"de.fau.cs.test"];

            } else if ([notification isEqualToString:AAPilotAppExecutionRequestStart]) {
                [client setAppExecutionHasStartedAndAutoScheduleSetRunning:TRUE];

            } else if ([notification isEqualToString:AAPilotAppExecutionStarted]) {
                [client setAppExecutionRunning];

            } else if ([notification isEqualToString:AAPilotAppExecutionRunning]) {
                [AAClientLibTests sendNotification:AAPilotAppExecutionRequestFinish];

            } else if ([notification isEqualToString:AAPilotAppExecutionRequestFinish]) {
                [client setAppExecutionHasFinished];

            } else if ([notification isEqualToString:AAPilotAppExecutionFinished]) {
                [AAClientLibTests sendNotification:AAPilotAppWillExit];
                
            } else if ([notification isEqualToString:AAPilotAppWillExit]) {
                [AAClientLibTests sendNotification:AAPilotAppExited];
            
            }
        }];
    }
    [AAClientLibTests sendNotification:AAPilotAppWillStart];
    

    for (int i = 0; i < 5; ++i) {
        if ([notifications count] == 0)
            break;
        sleep(1);
    }
    
    XCTAssertTrue([notifications count] == 0, @"some notifications have not be received");    
}

- (void)testNotifications {
    [self notificationsTestHelper];
    [self notificationsTestHelper];
}

@end