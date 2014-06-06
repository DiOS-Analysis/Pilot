//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIAutomation/UIAWindow.h>

#import "AASmartExecution.h"
#import "AASEElement.h"

@interface AASEView : NSObject <NSCopying>

//get all data from UIAWindow
- (id)initWithUIAWindow:(UIAWindow*)window;

// try to match windows
- (BOOL)isEqualSEView:(AASEView*)other;

- (AASEElement*)nextActionElement;

- (AASEExecutionState)executionState;

- (BOOL)hasInputElements;

@property(readonly) NSArray* elements;
@end
