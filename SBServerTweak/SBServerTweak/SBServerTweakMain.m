//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CaptainHook.h"
#import "SBServerTweak.h"
#import "Common.h"

CHDeclareClass(UIApplication);
CHMethod(1, void, UIApplication, setDelegate, id, delegate) {
    @autoreleasepool {
        [SBServerTweak sharedInstance];
    }
    CHSuper(1, UIApplication, setDelegate, delegate);
}

CHConstructor {
    @autoreleasepool {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        DDLogCInfo(@"SBServerTweak started: %@", bundleIdentifier);
        CHLoadLateClass(UIApplication);
        CHHook(1, UIApplication, setDelegate);
    }
}
