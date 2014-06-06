//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "SBSTCydiaStoreManager.h"
#import "SBSTShellExecutor.h"
#import "Common.h"

#define installCmd @"BUNDLEID=\"%@\";\
apt-cache show \"$BUNDLEID\" >/dev/null;\
if [ $? -ne 0 ]; then echo 'Invalid bundleId'; exit 2;fi;\
sudo apt-get install \"$BUNDLEID\" >/dev/null;\
if [ $? -ne 0 ]; then echo 'Install failed'; exit 1;fi;\
echo \"$BUNDLEID successfully installed.\"; exit 0;"

@implementation SBSTCydiaStoreManager

+ (BOOL)installApplicationForBundleId:(NSString*)bundleId {

    NSString *cmd = [NSString stringWithFormat:installCmd, bundleId];
    NSDictionary *result = [SBSTShellExecutor runCommand:cmd];
    
    BOOL returnValue = false;
    NSNumber *terminationStatus = result[@"terminationStatus"];
    if (terminationStatus != nil) {
        returnValue = [terminationStatus isEqualToNumber:@0];
    }
    
    if (!returnValue) {
        DDLogError(@"<CydiaStoreManager> install failed: %@", result[@"output"]);
    }
    
    return returnValue;
}

@end
