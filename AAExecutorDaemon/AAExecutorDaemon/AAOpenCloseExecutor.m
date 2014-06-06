//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AAOpenCloseExecutor.h"
#import "UIAutomation.h"
#import "Common.h"

@implementation AAOpenCloseExecutor

- (BOOL)startExecution {
    BOOL result = [super startExecution];
    if (result) {
        if (self.executionTime > 0) {
            DDLogWarn(@"AAOpenCloseExecutor does not support custom execution times!!! (Will be ignored)");
        }
        
        [self.queue addOperationWithBlock:^{
            

            DDLogVerbose(@"waiting 15sec to get the app started.");
            sleep(15);

            DDLogInfo(@"deactivating the app for 5 seconds.");
            if ([[UIATarget localTarget] deactivateAppForDuration:@"5"]) {
                sleep(5);
            } else {
                DDLogError(@"Execution aborted! - Unable to make app frontmost again!");
            }
            [self setExecutionFinished];
        }];
    }
    return result;
}


@end
