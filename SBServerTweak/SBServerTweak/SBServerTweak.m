//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBServerTweak.h"
#import "SBSTHTTPServer.h"
#import "SBSTSpringBoardManager.h"
#import "Common.h"

#define UNLOCK_WAIT_TIME 7


@implementation SBServerTweak

+ (SBServerTweak*)sharedInstance {
    static SBServerTweak *singleton;
    
    @synchronized(self) {
        if (!singleton) {
            singleton = [[SBServerTweak alloc] init];
        }
        return singleton;
    }
}

- (void)onFinishedLaunching {
    DDLogVerbose(@"Application did finish launching!");
    @synchronized(self) {
        if(!_isInitialized) {
            _SBSTHTTPServer = [SBSTHTTPServer sharedInstance];
            [_SBSTHTTPServer startServer];
            _isInitialized = YES;
        }
    }
    
    // unlock and dismiss all alerts (missing sim warning, ...)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DDLogVerbose(@"waiting some time...");
        sleep(UNLOCK_WAIT_TIME);
        DDLogVerbose(@"unlocking...");
        [SBSTSpringBoardManager unlock];
        sleep(2);
        [SBSTSpringBoardManager dismissAlerts];
    });
}

- (id)init {
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFinishedLaunching)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}


@end
