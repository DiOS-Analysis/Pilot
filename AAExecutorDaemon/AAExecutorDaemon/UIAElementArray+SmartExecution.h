//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIAutomation/UIAElementArray.h>

@interface UIAElementArray (SmartExecution)

- (UIAElement*)elementForPath:(NSArray*)path;
- (UIAElementArray*)visibleElements;
- (NSArray*)elementValues;
- (NSArray*)elementClassNames;

#ifdef DEBUG
// this method is for debugging/testing only - it may cause memory leaks
- (NSArray*)elementAttributeValues:(NSString*)attribute;
#endif

@end
