//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIAutomation/UIAElementNil.h>
#import <UIAutomation/UIAElementArray.h>

@interface UIAElementNil (Fixes)

- (UIAElementArray*)elementsArray;

- (BOOL)isVisibleBool;
- (BOOL)isEnabledBool;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end
