//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIAutomation/UIAElement.h>

@interface UIAElement (Fixes)

// will always return an UIAElementArray or nil
- (UIAElementArray*)elementsArray;

- (BOOL)isVisibleBool;
- (BOOL)isEnabledBool;
- (NSValue*)centerpoint;

@end
