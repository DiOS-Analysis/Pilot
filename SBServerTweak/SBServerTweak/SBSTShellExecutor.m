//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "SBSTShellExecutor.h"
#import "Common.h"
#import <Foundation/NSTask.h>

@implementation SBSTShellExecutor

+ (NSDictionary*)runCommand:(NSString*)commandString {

    NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"commands.sh"];

    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];

    if (commandString!=nil) {
        NSError *error;
        if([commandString writeToFile:tmpFilePath
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:&error]) {
            
            NSTask *task;
            task = [[NSTask alloc] init];
            [task setLaunchPath: @"/bin/bash"];
            [task setArguments: @[tmpFilePath]];
            
            NSPipe *pipe = [NSPipe pipe];
            [task setStandardOutput: pipe];
            
            NSFileHandle *file = [pipe fileHandleForReading];
            
            [task launch];
            
            NSData *data = [file readDataToEndOfFile];

            [task waitUntilExit];
            
            [result setValue:[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] forKey:@"output"];
            [result setValue:@([task terminationStatus]) forKey:@"terminationStatus"];

        } else {
            DDLogError(@"Error writing file at %@\n%@", tmpFilePath, [error localizedFailureReason]);
        }
    }

    return result;
}

@end
