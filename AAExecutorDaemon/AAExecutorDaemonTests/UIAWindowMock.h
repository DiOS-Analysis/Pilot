//
//  UIAWindowMock.h
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import <UIAutomation/UIAWindow.h>

@interface UIAWindowMock : UIAWindow

- (id)initWithElements:(UIAElementArray*)elements;
- (UIAElementArray*)elements;

@end
