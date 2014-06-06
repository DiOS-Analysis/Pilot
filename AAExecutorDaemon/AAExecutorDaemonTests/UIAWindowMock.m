//
//  UIAWindowMock.m
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import "UIAWindowMock.h"

@implementation UIAWindowMock

- (id)initWithElements:(UIAElementArray*)elements {
    self = [super init];
    if (self) {
        self->_elements = elements;
    }
    return self;
}

- (UIAElementArray*)elements {
    return self->_elements;
}

@end
