//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIAutomation/UIAElement.h>
#import <UIAutomation/UIAWindow.h>

@interface AASEElement : NSObject <NSCopying>

// initializes a AASEElement with the given UIAElement
- (id)initWithUIAElement:(UIAElement*)element elementIndex:(int)index;


@property(readonly)int index;
@property()UIAElement *uiaElement; //this field may be nil or contain invalid UIAElements

@end
