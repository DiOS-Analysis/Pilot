//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSTCycriptExecutor : NSObject

+ (NSDictionary*)run:(NSString*)application withCommand:(NSString*)commandString;

@end
