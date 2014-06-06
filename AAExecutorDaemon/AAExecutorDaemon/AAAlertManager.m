//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAAlertManager.h"
#import "AAExecutionHandler.h"
#import "UIAutomation.h"
#import <UIKit/UIDevice.h>

@interface AAAlertManager()
@property() NSMutableDictionary* handlerDict;
@end


@implementation AAAlertManager

+ (AAAlertManager*)sharedInstance {
    static AAAlertManager *singleton;
    
    @synchronized(self) {
        if (!singleton) {
            singleton = [[AAAlertManager alloc] init];
        }
        return singleton;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        _handlerDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}



#pragma mark add/remove alertHandler:

- (void)addAlertHandler:(id<AAAlertHandler>)handler {

    @synchronized(_handlerDict) {
        for (NSString *bundleId in handler.bundleIds) {
            NSMutableArray *bundleArray = _handlerDict[bundleId];
            if (!bundleArray) {
                bundleArray = [[NSMutableArray alloc] initWithCapacity:1];
                _handlerDict[bundleId] = bundleArray;
            }
            // prepend newer handlers
            [bundleArray insertObject:handler atIndex:0];
        }
    }
}

- (void)removeAlertHandler:(id<AAAlertHandler>)handler {
    @synchronized(_handlerDict) {
        for (NSString *bundleId in handler.bundleIds) {
            NSMutableArray *bundleArray = _handlerDict[bundleId];
            if (bundleArray) {
                [bundleArray removeObject:handler];
            }
        }
    }
}


#pragma mark handleAlert:

- (BOOL)handleAlert:(UIAAlert*)alert {
    // force alert handling to portrait orientation if possible to avoid hidden buttons if the keyboard is visible too   
    [UIATarget.localTarget setDeviceOrientation:@(UIDeviceOrientationPortrait)];
    return [self handleAlert:alert forBundleId:[UIATarget.localTarget frontMostApp].bundleID];
}

- (BOOL)handleAlert:(UIAAlert*)alert forBundleId:(NSString*)bundleId {
    NSArray *alertHandlers = nil;
    @synchronized(_handlerDict) {
        alertHandlers = _handlerDict[bundleId];
    }

    BOOL alertHandled = false;
    if (alertHandlers) {
        for (id<AAAlertHandler> handler in alertHandlers) {
            @synchronized(self) {
                alertHandled = [handler handleAlert:alert];
            }
            if (alertHandled || ![alert isKindOfClass:[UIAAlert class]] || !alert.isVisibleBool)
                break;
        }
    }
    // if no matching handlers found and not already tried the generic handlers:
    //  try generic handlers
    if (!alertHandled && ![bundleId isEqualToString:GENERIC_HANDLER_BUNDLEID]) {
        alertHandled = [self handleAlert:alert forBundleId:GENERIC_HANDLER_BUNDLEID];
    }
    return alertHandled;
}


@end
