//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

-(id)randomObject {
    NSUInteger count = [self count];
    if (count > 0) {
        uint32_t rnd = arc4random_uniform((uint32_t)count);
        return self[rnd];
    } else {
        return nil;
    }
}

@end