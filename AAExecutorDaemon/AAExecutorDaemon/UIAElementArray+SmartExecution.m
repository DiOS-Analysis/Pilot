//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAElementArray+SmartExecution.h"
#import "UIAElement+Fixes.h"
#import <Foundation/NSObjCRuntime.h>

@implementation UIAElementArray (SmartExecution)

#pragma mark helper methods

- (UIAElement*)elementForPath:(NSArray*)path {

    NSUInteger pathLength = [path count];
    NSAssert(pathLength > 0, @"An empty path array is invaild!");
    int index = [path[0] intValue];
    NSAssert(index >= 0 && index < [self count], @"Object index out of range!");
    UIAElement *element = self[index];
    
    if (pathLength > 1) {
        return [element.elements elementForPath:[path subarrayWithRange:NSMakeRange(1, pathLength-1)]];
    } else {
        return element;
    }
}

- (UIAElementArray*)visibleElements {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (UIAElement* e in self) {
        if (e.isVisibleBool) {
            [results addObject:e];
        }
    }
    return [[UIAElementArray alloc] initWithArray:results];
}

- (NSArray*)elementValues {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (UIAElement* e in self) {
        if (e.value != NULL) {
            [result addObject:e.value];
        } else {
            [result addObject:[NSString stringWithFormat:@"[%@]", e.className]];
        }
    }
    return result;
}

- (NSArray*)elementClassNames {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (UIAElement* e in self) {
        [result addObject:e.className];
    }
    return result;
}

// Use this method with care - it may cause leaks
- (NSArray*)elementAttributeValues:(NSString*)attribute {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (UIAElement* e in self) {
        if (e.value != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [result addObject:[e performSelector:NSSelectorFromString(attribute)]];
#pragma clang diagnostic pop
        } else {
            [result addObject:[NSString stringWithFormat:@"[%@]", e.className]];
        }
    }
    return result;
}

@end
