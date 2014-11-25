//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAApplication+Fixes.h"

@implementation UIAApplication (Fixes)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (UIAAlert*)alertSync {
    __block UIAAlert *alert = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        alert = [self alert];
    });
    return alert;
}

#pragma clang diagnostic pop

@end