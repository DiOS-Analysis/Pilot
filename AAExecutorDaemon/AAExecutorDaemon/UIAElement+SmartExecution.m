//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAElement+SmartExecution.h"
#import "UIAutomation.h"


@implementation UIAElement (SmartExecution)

- (NSString*)propertyString {
/*
possible unique properties:
 - className (UIAutomation)
 - uiaxElement.traitsNumber (equals className?)
 - type (UIKit)

 - parentElement
 - elements (not working for some tableviews)
 
probably variable:
 - attributeKeys ???

 variable:
 - name - (eg. TableCell)
 - value - (eg. UIASwitch, ...)
 */
    return [NSString stringWithFormat:@"%@|%@|%@|%@",
            self.className,
            self.type,
            [self.uiaxElement traitsNumber],
//            self.name,
            /*self.value,*/
            /*[self.elements count],*/
            self.parentElement.className];
}

@end
