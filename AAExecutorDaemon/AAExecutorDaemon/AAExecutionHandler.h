//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAAlertManager.h"
#import "AAAppExecutor.h"

@interface AAExecutionHandler : NSObject

+ (AAExecutionHandler*)sharedInstance;

- (BOOL)startExecutionWithExecutor:(AAAppExecutor*)executor;
- (BOOL)stopExecution;

@property(assign) void (^executionFinishedBlock)(void);
@property(readonly) NSArray* bundleIds;
@property(readonly) AAAppExecutor* executor;

@end
