//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSTCydiaStoreManager : NSObject

+ (BOOL)installApplicationForBundleId:(NSString*)bundleId;

@end
