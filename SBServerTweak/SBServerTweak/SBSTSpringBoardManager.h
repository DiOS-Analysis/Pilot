//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpringBoard/SBApplication.h>

@interface SBSTSpringBoardManager : NSObject

+ (BOOL)unlock;
+ (NSDictionary*)applicationInfo;
+ (BOOL)openApplicationForBundleId:(NSString*)bundleId;
+ (void)pressHomeButton;
+ (void)killApplicationForBundleId:(NSString*)bundleId;
+ (SBApplication*)applicationForBundleId:(NSString*)bundleId;
+ (void)dismissAlerts;

@end
