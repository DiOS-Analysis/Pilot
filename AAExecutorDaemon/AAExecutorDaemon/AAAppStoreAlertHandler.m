//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAAppStoreAlertHandler.h"
#import "AAClientLib.h"
#import "Common.h"


@implementation AAAppStoreAlertHandler

static NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

- (id)init {
    self = [super init];
    if (self) {
        _bundleIds = @[@"com.apple.springboard", @"com.apple.AppStore"];
    }
    return self;
}


- (BOOL)handleAlert:(UIAAlert*)alert {
    DDLogVerbose(@"-[%@ handleAlert:]", self.class);
    BOOL alertHandlingDone = NO;
    
    UIAElementArray *texts = [alert.scrollViews[0] staticTexts];
    if ([texts count] >= 1) {
        DDLogVerbose(@"Searching for iTunes authentication promt");
        NSString *title = [texts objectAtIndex:0].value;
        NSString *message = [texts objectAtIndex:1].value;
        if ([title rangeOfString:@"iTunes"].location != NSNotFound &&
            [message rangeOfString:@"ID"].location != NSNotFound) {
            DDLogVerbose(@"Detected iTunesStore login promt");
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            NSTextCheckingResult *firstMatch = [regex firstMatchInString:message
                                                                 options:0
                                                                   range:NSMakeRange(0, [message length])];
            
            if (firstMatch != nil) {
                NSString *appleId = [message substringWithRange:firstMatch.range];
                DDLogVerbose(@"Discovered AppleID within alert: %@", appleId);
                NSString *password = [self _passwordForAppleId:appleId];
                if (password != nil) {
                    UIAElement *elem = [alert.scrollViews objectAtIndex:0];
                    elem = elem.tableViews[0];
                    elem = elem.elements[0];
                    UIASecureTextField *passwordField = elem.secureTextFields[0];
                    [passwordField setValue:password];
                    sleep(1);
                    
                    [alert.defaultButton tap];
                    alertHandlingDone = YES;
                }
                
            } else {
                DDLogError(@"Failed to extract AppleID from alert");
            }
        } else if ([title rangeOfString:@"Zahlungsdaten"].location != NSNotFound) {
            DDLogError(@"Detected iTunesStore error. (missing payment details): %@", title);
            [alert.cancelButton tap];
            alertHandlingDone = YES;
            
        } else if ([title rangeOfString:@"iTunes"].location != NSNotFound &&
                   [alert.buttons count] == 1) {
            DDLogError(@"Detected iTunesStore error: %@", title);
            [alert.defaultButton tap];
            alertHandlingDone = YES;
        } else if ([title rangeOfString:@"Verif" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            DDLogError(@"Detected iTunesStore error: %@ (account verification is missing)", title);
            [alert.cancelButton tap];
            alertHandlingDone = YES;
        }
    }
    return alertHandlingDone;
}

- (NSString*)_passwordForAppleId:(NSString*)appleId {
    NSString *password = nil;
    DDLogVerbose(@"try to get password for Apple-ID %@", appleId);
    NSDictionary* taskInfo = [[AAClientLib sharedInstance] taskInfo];
    NSString* backendURL = taskInfo[@"backendUrl"];
    if (backendURL) {
        NSError* error;
        NSURL *url = [NSURL URLWithString:[backendURL stringByAppendingFormat:@"/accounts/appleid/%@", appleId]];
        if (url != nil) {
            NSData* data = [NSData dataWithContentsOfURL:url options:kNilOptions error:&error];
            if (data != nil) {
                NSError* error;
                NSDictionary* account = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                //            DDLogVerbose(@"Received data from backend: %@", account);
                if (account != nil) {
                    id pw = account[@"password"];
                    if ([pw isKindOfClass:[NSString class]]) {
                        password = pw;
                        DDLogInfo(@"password found for Apple-ID %@", appleId);
                    } else {
                        DDLogWarn(@"Unable to get password: No password set!");
                    }
                } else {
                    DDLogWarn(@"Unable to get password: Account not found!");
                }
            } else {
                DDLogWarn(@"Unable to get password: No data received!");
            }
        } else {
            DDLogWarn(@"Unable to get password: Invalid backendUrl!");
        }
    } else {
        DDLogWarn(@"Unable to get password: No backendUrl available!");
    }
    return password;
}


@end
