//
//  AASEViewTest.m
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import "AASEViewTest.h"

#import "UIAElementMock.h"
#import "UIAWindowMock.h"

#import "AASEView.h"


@implementation AASEViewTest

- (void)toestEquals1 {
    
    UIAElementArray *elements1 = (UIAElementArray*)@[
                                  [UIAElementMock randomUIAElement]
                                  ];
    UIAElementArray *elements2 = (UIAElementArray*)@[
                                  [UIAElementMock randomUIAElement],
                                  [UIAElementMock randomUIAElement]
                                  ];
    
    UIAWindowMock *window10 = [[UIAWindowMock alloc] initWithElements:elements1];
    UIAWindowMock *window11 = [[UIAWindowMock alloc] initWithElements:elements1];
    UIAWindowMock *window20 = [[UIAWindowMock alloc] initWithElements:elements2];
    
    XCTAssertTrue([elements1 count] > 0, @"Array empty!");
    XCTAssertTrue([elements2 count] > 0, @"Array empty!");
    XCTAssertTrue([window10.elements count] > 0, @"Array empty!");
    XCTAssertTrue([window11.elements count] > 0, @"Array empty!");
    XCTAssertTrue([window20.elements count] > 0, @"Array empty!");

    AASEView *view10 = [[AASEView alloc] initWithUIAWindow:window10];
    AASEView *view11 = [[AASEView alloc] initWithUIAWindow:window11];
    AASEView *view12 = [[AASEView alloc] initWithUIAWindow:window10];
    AASEView *view20 = [[AASEView alloc] initWithUIAWindow:window20];
    
    XCTAssertTrue([view10 isEqual:view12], @"Views with same windows are not equal");
    XCTAssertTrue([view10 isEqual:view11], @"Views with different windows but same elements are not equal");

    XCTAssertFalse([view10 isEqual:view20], @"Views with different windows and elements are equal");
    
}


@end
