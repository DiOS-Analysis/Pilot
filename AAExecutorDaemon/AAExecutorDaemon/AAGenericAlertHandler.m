//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAGenericAlertHandler.h"
#import "UIAutomation.h"
#import "Common.h"
#import "UIATarget+Fixes.h"

#define buttonKeywords @[@"OK", @"Allow", @"erlauben", @"zulassen"]
#define buttonDefaultBlacklist @[@"try", @"versuchen", @"ausprobieren", @"store", @"version", @"rate", @"bewerten", @"load", @"laden", @"upgrade", @"anrufen", @"call"]

@implementation AAGenericAlertHandler

- (id)init {
    self = [super init];
    if (self) {
        _bundleIds = @[GENERIC_HANDLER_BUNDLEID];
    }
    return self;
}

- (BOOL)handleAlert:(UIAAlert *)alert {
    DDLogVerbose(@"-[%@ handleAlert:]", self.class);
    BOOL alertHandlingDone = false;
    
    NSString *alertAppBundleId = UIATarget.localTarget.frontMostApp.bundleID;
    
    // try to choose the "best" button
    UIAButton *bestButton = nil;
    
    NSString *staticTexts = @"";
    for (UIAStaticText *text in [alert staticTexts]) {
        [staticTexts stringByAppendingFormat:@"%@, ", text.value];
    }
    for (UIAScrollView *scrollView in alert.scrollViews) {
        for (UIAStaticText *text in [scrollView staticTexts]) {
            [staticTexts stringByAppendingFormat:@"%@, ", text.value];
        }
    }
    DDLogInfo(@"Generic handling for alert: (%@) %@ - %@", alertAppBundleId, alert.name, staticTexts);
    NSArray *buttons = [alert buttons];
    DDLogVerbose(@"%lu buttons available:", (unsigned long)[buttons count]);
    for (UIAButton *button in buttons) {
        NSString *buttonName = [button name];
        
        if (bestButton == nil && [button isEnabledBool]) {
            for (NSString *keyword in buttonKeywords) {
                if ([buttonName rangeOfString:keyword
                                      options:NSCaseInsensitiveSearch].length > 0) {
                    bestButton = button;
                    break;
                }
            }
        }
        DDLogVerbose(@"%@", buttonName);
    }
    
    // use the default button if available
    if (alert.defaultButton != nil &&
        [alert.defaultButton isKindOfClass:[UIAButton class]] &&
        alert.defaultButton.isEnabledBool) {

        BOOL blacklisted = false;
        NSString *buttonName = [alert.defaultButton name];
        for (NSString *keyword in buttonDefaultBlacklist) {
            if ([buttonName rangeOfString:keyword
                                  options:NSCaseInsensitiveSearch].length > 0) {
                blacklisted = true;
                break;
            }
        }
        if (!blacklisted) {
            bestButton = [alert defaultButton];
            DDLogInfo(@"Using the default button: %@", [[alert defaultButton] name]);
        }
    }
    
    // if no button was found - just take the first one...
    if (bestButton == nil) {
        for (UIAButton *button in buttons) {
            if (button.isEnabledBool) {
                bestButton = button;
                DDLogInfo(@"No preferred button detected. Using the first enabled button: %@", [bestButton name]);
                break;
            }
        }
    }
    
    // fallback to cancel button
    if (bestButton == nil &&
        alert.cancelButton != nil &&
        [alert.cancelButton isKindOfClass:[UIAButton class]]) {
        
        bestButton = [alert cancelButton];
        DDLogInfo(@"Just using the cancel button: %@", [[alert cancelButton] name]);
    }
    
    // fallback to default Button - even if not enabled and visible
    // we just try to finally get the alert dismissed somehow
    if (bestButton == nil &&
        alert.defaultButton != nil &&
        [alert.defaultButton isKindOfClass:[UIAButton class]]) {
        
        bestButton = [alert cancelButton];
        DDLogInfo(@"Using the default button '%@' as fallback (The button may not be visible or enabled)", [[alert defaultButton] name]);
    }
    
    
    // finally tap the best button
    if (bestButton != nil && [bestButton isKindOfClass:[UIAButton class]] && bestButton.isVisibleBool && [alert isVisibleBool]) {
        DDLogInfo(@"Tapping button %@", [bestButton name]);
        [UIATarget.localTarget pushPatience:5];
        @try {
            [bestButton tap];
            sleep(2);
        }
        @catch (NSException *ex) {
            DDLogWarn(@"Unable to tap button: %@", ex);
        }
        alertHandlingDone = ![alert isVisibleBool];
        [UIATarget.localTarget popPatience];
    }
    if (!alertHandlingDone && bestButton != nil && [bestButton isKindOfClass:[UIAButton class]]) {
        DDLogInfo(@"Tapping button %@ failed. Try to tap it via point now", bestButton.name);
        if (bestButton.hitpoint != NULL) {
            DDLogVerbose(@"Try to tap button %@ via tap at %@", bestButton, bestButton.hitpoint);
            [UIATarget.localTarget tap:bestButton.hitpoint];
            alertHandlingDone = ![alert isVisibleBool];
        } else {
            DDLogError(@"Tapping button %@ via point failed!!! Hitpoint was NULL", bestButton.name);
        }
    }
    
    if (alertHandlingDone) {
        // reopen the app if necessary
        NSString *frontMostBundleId = UIATarget.localTarget.frontMostApp.bundleID;
        if (![alertAppBundleId isEqualToString:SB_BUNDLE_ID] && ![alertAppBundleId isEqualToString:frontMostBundleId]) {
            DDLogVerbose(@"Alert handling done. Will reactivate the application now.");
            [UIATarget.localTarget openApplication:alertAppBundleId];
        }
    } else {
        DDLogError(@"[AAGenericAlertHandler] Unable to handle Alert!");
    }
    return alertHandlingDone;
}

@end
