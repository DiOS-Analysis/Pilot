//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAElementNil+Fixes.h"

@implementation UIAElementNil (Fixes)

- (UIAElementArray*)elementsArray {
    return nil;
}

- (BOOL)isVisibleBool {
    return NO;
}

- (BOOL)isEnabledBool {
    return NO;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

@end
