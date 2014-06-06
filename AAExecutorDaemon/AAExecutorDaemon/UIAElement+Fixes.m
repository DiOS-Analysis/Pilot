//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAElement+Fixes.h"
#import <UIAutomation/UIAElementNil.h>

@implementation UIAElement (Fixes)

- (UIAElementArray*)elementsArray {

    static UIAElementArray *emptyArray;
    if (emptyArray == nil)
        emptyArray = [[UIAElementArray alloc] init];

    id elements = [self elements];
    if (elements == nil || [elements isKindOfClass:[UIAElementNil class]])
        return emptyArray;
    return elements;
}

- (BOOL)isVisibleBool {
    CFBooleanRef value = self.isVisible;
    if (value != nil) {
        return CFBooleanGetValue(value);
    }
    return false;
}

- (BOOL)isEnabledBool {
    CFBooleanRef value = self.isEnabled;
    if (value != nil) {
        return CFBooleanGetValue(value);
    }
    return false;
}

- (NSValue*)centerpoint {
    CGRect rect = [[self rect] CGRectValue];
    CGPoint point = rect.origin;
    point.x += rect.size.width/2;
    point.y += rect.size.height/2;
    return [NSValue valueWithCGPoint:point];
}

@end
