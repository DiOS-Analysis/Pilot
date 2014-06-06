//
//  UIAElementMock.h
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import "UIAElement+Fixes.h"
#import "UIAWindowMock.h"

@interface UIAElementMock : UIAElement

+ (UIAElement*)randomUIAElement;
+ (UIAWindow*)scrollViewElementTree;

@property NSDictionary *properties;

@end
