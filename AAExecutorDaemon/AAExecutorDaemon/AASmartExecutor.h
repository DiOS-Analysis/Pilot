//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAAppExecutor.h"

@interface AASmartExecutor : AAAppExecutor

- (BOOL)handleAlert:(UIAAlert*)alert;
- (NSArray*)bundleIds;

@end
