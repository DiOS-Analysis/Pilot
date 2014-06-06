//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAAlertManager.h"

// handle iTunes account login/password and other store/purchase related alerts
@interface AAAppStoreAlertHandler : NSObject <AAAlertHandler>

- (BOOL)handleAlert:(UIAAlert*)alert;

@property(readonly) NSArray* bundleIds;

@end
