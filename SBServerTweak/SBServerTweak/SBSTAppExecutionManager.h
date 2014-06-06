//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSTAppExecutionManager : NSObject

- (void)executeAppWithBundleId:(NSString*)bundleId;
//async version of -(void)executeAppWithBundleId:(NSString*)bundleId
- (void)executeAppWithBundleId:(NSString*)bundleId onExecutionFinished:(void (^)(void))block;

@end
