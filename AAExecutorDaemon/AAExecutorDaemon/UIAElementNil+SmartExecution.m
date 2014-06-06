//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAElementNil+SmartExecution.h"

@implementation UIAElementNil (SmartExecution)

#pragma mark UIAElement methods

- (NSString*)propertyString {
    return nil;
}


#pragma mark UIAElementArray methods

- (UIAElement*)elementForPath:(NSArray*)path {
    return nil;
}

- (UIAElementArray*)visibleElements {
    return nil;
}

- (NSArray*)elementValues {
    return nil;
}

- (NSArray*)elementClassNames {
    return nil;
}

@end
