//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAAppExecutor.h"

@interface AARandomExecutor : AAAppExecutor

- (BOOL)startExecution;
- (BOOL)handleAlert:(UIAAlert*)alert;

@end
