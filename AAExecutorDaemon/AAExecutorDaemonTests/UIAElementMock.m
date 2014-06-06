//
//  UIAElementMock.m
//  AAExecutorDaemon
//
//  Created by Andreas Weinlein on 15.04.13.
//
//

#import "UIAElementMock.h"
#import "UIACustomElementArray.h"
#import "NSArray+Random.h"

@interface UIAXElementMock : UIAXElement

- (id)initWithProperties:(NSDictionary*)properties;

@property NSDictionary *properties;
@property(readonly,getter = traitsNumber) NSNumber *traitsNumber;

@end

@implementation UIAElementMock

static NSMutableArray *uiaElements;

+ (void)initialize {
    uiaElements = [[NSMutableArray alloc] init];
    [uiaElements addObject:@{
     @"className": @"UIAStaticText",
     @"type": @"UILabel",
     @"name": @"First View",
     @"value": @"First View",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934656}]
     }];
    
    [uiaElements addObject:@{
     @"className": @"UIATextView",
     @"type": @"UITextView",
     @"name": @"Some long text stuff",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @140883517505792}]
     }];

    [uiaElements addObject:@{
     @"className": @"UIAButton",
     @"type": @"UIRoundedRectButton",
     @"name": @"Button",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934593}]
     }];
    
    NSMutableArray *uiaElements = [[NSMutableArray alloc] init];
    
    [uiaElements addObject:@{
     @"className": @"UIAScrollView",
     @"type": @"UIScrollView",
     @"name": @"Some long text stuff",
     @"elements": @[
     @{
     @"className": @"UIAStaticText",
     @"type": @"UILabel",
     @"name": @"Some text",
     @"value": @"Some text",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934656}]
     },
     @{
     @"className": @"UIAStaticText",
     @"type": @"UILabel",
     @"name": @"Some other text",
     @"value": @"Some other text",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934656}]
     },
     @{
     @"className": @"UIAButton",
     @"type": @"UIRoundedRectButton",
     @"name": @"Button",
     @"elements": @[],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934593}]
     }
     ],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @140883517505792}]
     }];
}

+ (UIAElement*)randomUIAElement {
    return [[UIAElementMock alloc] init];
}

+ (UIAWindow*)scrollViewElementTree {
    static NSDictionary *uiaElementTreeProps;
    if (uiaElementTreeProps == nil) {

    uiaElementTreeProps = @{
     @"className": @"UIAScrollView",
     @"type": @"UIScrollView",
     @"name": @"Some long text stuff",
     @"elements": [[UIACustomElementArray alloc] initWithArray:@[
        @{
            @"className": @"UIAStaticText",
            @"type": @"UILabel",
            @"name": @"Some text",
            @"value": @"Some text",
            @"elements": @[],
            @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934656}]
        },
        @{
            @"className": @"UIAStaticText",
            @"type": @"UILabel",
            @"name": @"Some other text",
            @"value": @"Some other text",
            @"elements": @[],
            @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934656}]
        },
        @{
            @"className": @"UIAButton",
            @"type": @"UIRoundedRectButton",
            @"name": @"Button",
            @"elements": @[],
            @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @8589934593}]
     }
     ]],
     @"uiaxElement": [[UIAXElementMock alloc] initWithProperties:@{@"traitsNumber": @140883517505792}]
     };
    }
    
    UIAElement *element = [[UIAElementMock alloc] initWithProperties:uiaElementTreeProps];
    UIAElementArray *array = [[UIACustomElementArray alloc] initWithArray:@[element]];
    return [[UIAWindowMock alloc] initWithElements:array];
}

- (id)init {
    self = [super init];
    if (self) {
        self.properties = [uiaElements randomObject];
    }
    return self;
}

- (id)initWithProperties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _properties = properties;
    }
    return self;
}

//self.className,
//self.type,
//self.uiaxElement.traitsNumber,
//self.name,
///*self.value,*/
//[self.elements count],
//self.parentElement.className

- (NSString*)className {
    return [_properties objectForKey:@"className"];
}

- (NSString*)type {
    return [_properties objectForKey:@"type"];
}

- (NSString*)name {
    return [_properties objectForKey:@"name"];
}

- (NSString*)value {
    return [_properties objectForKey:@"value"];
}

- (UIAElementArray*)elements {
    return [_properties objectForKey:@"elements"];
}

- (UIAElement*)parentElement {
    return [_properties objectForKey:@"parentElement"];
}

- (UIAXElement*)uiaxElement {
    return [_properties objectForKey:@"uiaxElement"];
}

@end


@implementation UIAXElementMock

- (id)initWithProperties:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        _properties = properties;
        
    }
    return self;
}

- (NSNumber*)traitsNumber {
    return [_properties objectForKey:@"traitsNumber"];
}

@end
