//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIACustomElementArray.h"

@interface UIACustomElementArray ()

@property NSArray *dataArray;

@end

@implementation UIACustomElementArray

- (id)initWithArray:(NSArray*)array {
    
    self = [super init];
    if (self) {
        _dataArray = array;
    }
    return self;
}

- (NSUInteger)count {
    return [_dataArray count];
}

- (UIAElement*)objectAtIndex:(NSUInteger)index {
    return _dataArray[index];
}

@end
