//
//  SEUIAElementArrayTest.m
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import "SEUIAElementArrayTest.h"
#import "UIAElementArray+SmartExecution.h"

#import "UIAElementMock.h"
#import "UIAWindowMock.h"

@implementation SEUIAElementArrayTest

- (void)testElementForPath {
    
    UIAWindow *window = [UIAElementMock scrollViewElementTree];
    
    UIAElementArray *array = window.elementsArray;
    
    XCTAssertTrue([array count] == 1, @"Array under test has 1 root element!");
    XCTAssertTrue([[array[0] elementsArray] count] == 3, @"Array under test has 3 child elements!");
    
    id res = [array elementForPath:@[@0,@0]];
    XCTAssertNotNil(res, @"Element should not be nil");
    res = [array elementForPath:@[@0,@1]];
    XCTAssertNotNil(res, @"Element should not be nil");
    res = [array elementForPath:@[@0,@2]];
    XCTAssertNotNil(res, @"Element should not be nil");
    

}


@end
