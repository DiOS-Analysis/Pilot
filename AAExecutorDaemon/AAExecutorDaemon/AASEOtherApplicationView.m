//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AASEOtherApplicationView.h"

@implementation AASEOtherApplicationView

- (id)initWithBundleId:(NSString*)bundleId {
    self = [super init];
    if (self) {
        _bundleId = bundleId;
    }
    return self;
}

#pragma mark overwrite some AASEView methods

- (id)initWithUIAWindow:(UIAWindow *)window {
    return nil;
}

- (BOOL)isEqualSEView:(AASEView*)other {
    if([other isKindOfClass:[AASEOtherApplicationView class]]) {
        AASEOtherApplicationView *otherAppView = (AASEOtherApplicationView*)other;
        if ([_bundleId isEqualToString:otherAppView.bundleId])
            return true;
    }
    return false;
}

- (UIAElement*)nextActionElement {
    return nil;
}

- (AASEExecutionState)executionState {
    return kSEStateDone;
}

#pragma mark NSCopying implementation

- (id)copyWithZone:(NSZone *)zone {
    AASEOtherApplicationView* copy = [super copyWithZone:zone];
    if (copy) {
        copy->_bundleId = _bundleId;
    }
    return copy;
}


@end
