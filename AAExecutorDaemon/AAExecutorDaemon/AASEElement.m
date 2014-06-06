//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AASEElement.h"
#import "UIAElement+SmartExecution.h"

@interface AASEElement()

@property() NSString *propertyString;

@end

@implementation AASEElement

- (id)initWithUIAElement:(UIAElement*)element elementIndex:(int)index {
    self = [self init];
    if (self) {
        _index = index;
        _propertyString = [element propertyString];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AASEElement class]]) {
        AASEElement *other = object;
        return [_propertyString isEqualToString:other.propertyString];
    }
    return FALSE;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %@>", self.class, _propertyString];
}

#pragma mark NSCopying implementation

- (id)copyWithZone:(NSZone *)zone {
    AASEElement* copy = [[[self class] alloc] init];
    if (copy) {
        [copy setPropertyString:_propertyString];
        copy->_index = _index;
    }
    return copy;
}

@end
