//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <UIAutomation/UIAAlert.h>
#import "AAAlertManager.h"

#define SB_BUNDLE_ID @"com.apple.springboard"

@interface AAAppExecutionException : NSException
@end

@protocol AAAppExecutionDelegate <NSObject>
@optional
- (void)appExecutionHasFinished:(NSString*)bundleId;
@end

@interface AAAppExecutor : NSObject <AAAlertHandler>

// start/stop the execution
- (BOOL)startExecution; //no default implementation! (Needs to be called with [super startExecution]!!!)
- (BOOL)stopExecution;
- (void)setExecutionFinished;

- (id)initWithBundleId:(NSString*)bundleId;
- (id)initWithBundleId:(NSString*)bundleId andExecutionTime:(NSUInteger)executionTime;

// AAAlertHandler
- (BOOL)handleAlert:(UIAAlert*)alert;

// (re-)opens the application under execution
- (BOOL)openApplication;

// return true if login/registration buttons are found
- (BOOL)isLoginRegisterView;

- (UIImage*)takeScreenshot;
- (void)saveScreenshotToCameraRoll;

@property(readonly) NSString* bundleId;
@property(readonly) NSUInteger executionTime;
@property(readonly) BOOL executionRunning;
@property(strong) NSOperationQueue *queue;
@property() id<AAAppExecutionDelegate> delegate;

@end
