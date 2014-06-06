//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "SBSTCycriptExecutor.h"
#import "Common.h"
#import <Foundation/NSTask.h>

@implementation SBSTCycriptExecutor

+ (NSDictionary*)run:(NSString*)application withCommand:(NSString*)commandString {

    NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"commands.cy"];

    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];

    if (commandString!=nil) {
        NSError *error;
        if([commandString writeToFile:tmpFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            
            
            NSTask *task;
            task = [[NSTask alloc] init];
            [task setLaunchPath: @"/usr/bin/cycript"];
            [task setArguments: @[@"-p", application, tmpFilePath]];
            
            NSPipe *pipe = [NSPipe pipe];
            [task setStandardOutput: pipe];
            
            NSFileHandle *file = [pipe fileHandleForReading];
            
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            [task waitUntilExit];
            
            result[@"output"] = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            result[@"terminationStatus"] = @([task terminationStatus]);

        } else {
            DDLogError(@"Error writing file at %@\n%@", tmpFilePath, [error localizedFailureReason]);
        }
    }

    return result;
}

@end
