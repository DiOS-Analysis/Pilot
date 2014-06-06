//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIAutomation/UIATarget.h>

#define SB_BUNDLE_ID @"com.apple.springboard"

@interface UIATarget (Fixes)

//fix broken reactivation for many apps
- (BOOL)reactivateApp;
- (BOOL)reactivateApp:(UIAApplication*)app;
- (BOOL)deactivateAppForDuration:(NSString*)duration;

// enhancements
- (BOOL)openApplication:(NSString*)bundleId;

@end
