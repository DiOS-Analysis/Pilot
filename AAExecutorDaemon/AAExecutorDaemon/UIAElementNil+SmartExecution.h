//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <UIAutomation/UIAElementNil.h>
#import "UIAElement+SmartExecution.h"
#import "UIAElementArray+SmartExecution.h"

@interface UIAElementNil (SmartExecution) 

#pragma mark UIAElement methods

- (NSString*)propertyString;

#pragma mark UIAElementArray methods
- (UIAElement*)elementForPath:(NSArray*)path;
- (UIAElementArray*)visibleElements;
- (NSArray*)elementValues;
- (NSArray*)elementClassNames;

@end
