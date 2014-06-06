//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "UIAutomation.h"

@implementation UIAutomation

+ (void)initialize {
	@autoreleasepool {
        // changing the path here is not enough - take a look at the readme file on how to patch the binary!
		NSString *path = @"/Library/PrivateFrameworks/UIAutomation.framework";
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		if ([bundle load]) {
			[bundle principalClass];
		}
	}
}
@end
