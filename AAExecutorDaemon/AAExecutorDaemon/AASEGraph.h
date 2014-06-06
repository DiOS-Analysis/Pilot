//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AASEView.h"

@interface AASEGraph : NSObject

- (BOOL)addView:(AASEView*)view;
- (BOOL)addEdgeFromView:(AASEView*)origin toView:(AASEView*)destination withElement:(AASEElement*)element;

- (NSArray*)pathFromView:(AASEView*)origin toView:(AASEView*)destination;

@end
