//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAutomation.h"
#import "UIATarget+Fixes.h"

#import "Common.h"

@implementation UIATarget (Fixes)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"


#pragma mark App reactivation
- (BOOL)reactivateApp {
    
    // check if springboard is active
    UIAApplication *sb = self.frontMostApp;
    if ([sb.bundleID compare:SB_BUNDLE_ID] == NSOrderedSame) {
        
        // activate switcher by double-tapping the home button
        usleep(500);
        [self clickMenu];
        [self clickMenu];
        sleep(1);
        // find the apps icon
        [self pushPatience:5];
        UIAElementArray *scrollViews = sb.appItemScrollView.scrollViews;
        [self popPatience];
        [scrollViews[1] tap];
        
        // check the reactivation was successfull
        for (int i = 0; i < 5; i++) {
            if ([SB_BUNDLE_ID compare:self.frontMostApp.bundleID] != NSOrderedSame) {
                sleep(3);
                return TRUE;
            }
            sleep(1);
        }
    }
    return FALSE;
}

- (BOOL)reactivateApp:(UIAApplication*)app {
    
    // check if springboard is active
    UIAApplication *sb = self.frontMostApp;
    if ([sb.bundleID compare:SB_BUNDLE_ID] == NSOrderedSame) {
        
        if (app == nil) {
            DDLogInfo(@"-[UIATarget reactivateApp:] app is nil - reactivating the first app now");
            return [self reactivateApp];
        }
        
        // activate switcher by double-tapping the home button
        [self clickMenu];
        [self clickMenu];
        sleep(1);

        [self pushPatience:5];
        for (int i = 0; i < 5; i++) {
            if (![sb.appItemScrollView isKindOfClass:[UIAElementNil class]]) {
                break;
            }
            sleep(1);
        }
        [self popPatience];
        
        if ([sb.appItemScrollView isKindOfClass:[UIAElementNil class]]) {
            DDLogWarn(@"-[UIATarget reactivateApp:] Unable to activate the appItemScrollView - reactivating the first app now");
            [self clickMenu];
            sleep(1);
            return [self reactivateApp];
        }
        
        // find the apps icon
        [self pushPatience:5]; //ensure there is enough time to identify the button
        UIAElementArray *scrollViews = sb.appItemScrollView.scrollViews;
        [self popPatience];

        UIAScrollView *appScrollView = nil;
        for (UIAScrollView *scrollView in scrollViews) {
            if (!scrollView.isVisibleBool) {
                [scrollView scrollToVisible];
            }
            if (scrollView.isVisibleBool) {
                UIAElement *elem = scrollView.elements[0];
                if ([elem.name compare:app.name] == NSOrderedSame) {
                    appScrollView = scrollView;
                    break;
                }
            }
        }
        
        // tap the icon
        if ([appScrollView isKindOfClass:[UIAElementNil class]]) {
            DDLogVerbose(@"appItemScrollViewVisible?: %u", sb.appItemScrollView.isVisibleBool);
            if (sb.appItemScrollView.isVisibleBool) {
                DDLogVerbose(@"-[UIATarget reactivateApp:] Unable to find the apps button - second try");
                [self pushPatience:10];
                UIAElementArray *scrollViews = sb.appItemScrollView.scrollViews;
                [self popPatience];
                for (UIAScrollView *scrollView in scrollViews) {
                    if (!scrollView.isVisibleBool) {
                        [scrollView scrollToVisible];
                    }
                    if (scrollView.isVisibleBool) {
                        UIAElement *elem = scrollView.elements[0];
                        if ([elem.name compare:app.name] == NSOrderedSame) {
                            appScrollView = scrollView;
                            break;
                        }
                    }

                }
                if ([appScrollView isKindOfClass:[UIAElementNil class]]) {
                    DDLogWarn(@"-[UIATarget reactivateApp:] Unable to find the apps button - reactivating the first app now");
                    [self clickMenu];
                    sleep(1);
                    return [self reactivateApp];
                }
            }
        }
        [appScrollView tap];

        // check the reactivation was successfull
        for (int i = 0; i < 5; i++) {
            if ([app.bundleID compare:self.frontMostApp.bundleID] == NSOrderedSame) {
                sleep(3);
                return TRUE;
            }
            sleep(1);
        }
    }
    return FALSE;
}


 - (BOOL)deactivateAppForDuration:(NSString*)duration {
     
     UIAApplication *app = self.frontMostApp;
     [self deactivateApp];
     sleep(2);
     if ([app.bundleID isEqualToString:self.frontMostApp.bundleID]) {
         [self clickMenu];
         sleep(1);
         if ([app.bundleID isEqualToString:self.frontMostApp.bundleID]) {
             DDLogWarn(@"Unable to deactivate app: %@", app.bundleID);
         }
     }
     sleep(duration.intValue);
     return [self reactivateApp:app];
}

#pragma clang diagnostic pop


- (BOOL)openApplication:(NSString*)bundleId {
    
    // check for alert and wait until handling has finished
    UIAAlert *alert = self.frontMostApp.alert;
    while ([alert isKindOfClass:[UIAAlert class]]) {
        DDLogInfo(@"-[UIATarget openApplication:] waiting for alert handling.");
        sleep(1);
        alert = self.frontMostApp.alert;
    }
    
    if ([bundleId compare:[self frontMostApp].bundleID] == NSOrderedSame) {
        return true;
    }
    
    [self deactivateApp];
    UIAApplication *sb = [self frontMostApp];
    for (int i = 0; i < 5; i++) {
        if ([sb.bundleID compare:SB_BUNDLE_ID] == NSOrderedSame) {
            break;
        }
        if (i == 2) {
            DDLogWarn(@"Unable to make SpringBoard frontmost! (Try to click menu button again).");
            [self clickMenu];
        }
        sleep(1);
        sb = [self frontMostApp];
    }
    if ([sb.bundleID compare:SB_BUNDLE_ID] != NSOrderedSame) {
        DDLogError(@"Unable to open application! (Unable to make SpringBoard frontmost).");
        return false;
    }
    
    UIAApplication *app = nil;
    // loop over all apps to find the apps name
    for (UIAApplication *application in self.applications) {
        if ([application.bundleID compare:bundleId] == NSOrderedSame) {
            app = application;
            break;
        }
    }
    if (app == nil) {
        DDLogError(@"Unable to open application! Unable to find app under execution.");
        return false;
    }
    
    return [self reactivateApp:app];
}


@end
