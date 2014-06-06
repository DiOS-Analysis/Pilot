//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAutomation.h"

__used
static NSString* GENERIC_HANDLER_BUNDLEID = @"de.fau.cs.dios.pilot.aaexecutordaemon.alert.generic";

@protocol AAAlertHandler <NSObject>

/*
 * tries to handle the given alert.
 * returns true if the alert was handled, false otherwise
 */
- (BOOL)handleAlert:(UIAAlert*)alert;

@property(readonly) NSArray* bundleIds;

@end


@interface AAAlertManager : NSObject

+ (AAAlertManager*)sharedInstance;

/*
 * Add/remove an alert handler.
 * It's possible to register multiple handlers for one bundleId.
 * The last added handler will be called first.
 * The alert handling will be aborted after the first successfull handling.
 */
- (void)addAlertHandler:(id<AAAlertHandler>)handler;
- (void)removeAlertHandler:(id<AAAlertHandler>)handler;

/*
 * This method will try to find a suitable AAAlertHandler to handle the given alert.
 * Returns true if the alert was handled, false otherwise.
 */
- (BOOL)handleAlert:(UIAAlert*)alert;

/*
 * This method will try to find a suitable AAAlertHandler to handle the given alert.
 * Returns true if the alert was handled, false otherwise.
 */
- (BOOL)handleAlert:(UIAAlert*)alert forBundleId:(NSString*)bundleId;


@end
