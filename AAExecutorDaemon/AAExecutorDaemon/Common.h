//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//


#define sleepRunloop(duration) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];


#import "DDLog.h"
#import "DDASLLogger.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;