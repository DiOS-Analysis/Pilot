//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "Common.h"
#import "AASEGraph.h"

#import <CCGraphT/CCDefaultEdge.h>
#import <CCGraphT/CCDirectedMultigraph.h>
#import <CCGraphT/CCDijkstraShortestPath.h>

#import "AASEElement.h"


#pragma mark A special edge class

@interface AASEElementEdge : CCDefaultEdge

- (id)initWithElement:(AASEElement*)element;

@property() AASEElement *seElement;

@end

@implementation AASEElementEdge

- (id)initWithElement:(AASEElement*)seElement {
    self = [self init];
    if (self) {
        _seElement = seElement;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [_seElement isEqual:[object seElement]];
    }
    return FALSE;
}

- (NSUInteger)hash {
    return 5 * [_seElement hash];
}

@end

#pragma mark The graph

@interface AASEGraph()

@property() CCDirectedMultigraph *graph;

@end

@implementation AASEGraph

- (id)init {
    self = [super init];
    if (self) {
        _graph = [[CCDirectedMultigraph alloc] initWithEdgeClass:[AASEElementEdge class]];
    }
    return self;
}

- (BOOL)addView:(AASEView*)view {
    // add vertext will check for already existing vertex
    return [_graph addVertex:view];
}

- (BOOL)addEdgeFromView:(AASEView*)origin toView:(AASEView*)destination withElement:(AASEElement*)element {
    AASEElementEdge *edge = [[AASEElementEdge alloc] initWithElement:element];
    if (![_graph containsEdge:edge])
        return [_graph addEdge:origin to:destination with:edge];
    return FALSE;
}

- (NSArray*)pathFromView:(AASEView*)origin toView:(AASEView*)destination {
    CCDijkstraShortestPath *path = [[CCDijkstraShortestPath alloc] initWith:_graph withOrigin:origin andDesitination:destination withRadius:50];
    @try {
        [path execute];
    }
    @catch (NSException *exception) {
        DDLogError(@"Unable to calculate path from %@ to %@: %@ (%@)", origin, destination, exception.name, exception.reason);
    }
    
    NSArray *edgeList = [path pathEdgeList];
    NSMutableArray *pathList;
    if ([edgeList count] > 0) {
        pathList = [[NSMutableArray alloc] init];
        
        for (AASEElementEdge *edge in edgeList) {
            [pathList addObject:edge.seElement];
        }
    }
    return pathList;
}

@end
