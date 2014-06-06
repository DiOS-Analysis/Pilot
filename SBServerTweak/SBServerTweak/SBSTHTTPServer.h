//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutingHTTPServer.h"


@interface SBSTHTTPServer : NSObject {
    BOOL isCmdRunning;
}

@property (strong) RoutingHTTPServer* http;

+ (SBSTHTTPServer*)sharedInstance;
- (void)startServer;
- (void)stopServer;
- (void)setupRoutes;

@end
