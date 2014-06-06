//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSTHTTPServer.h"

@interface SBServerTweak : NSObject {
    BOOL _isInitialized;
}

@property SBSTHTTPServer *SBSTHTTPServer;

+ (SBServerTweak*)sharedInstance;

@end
