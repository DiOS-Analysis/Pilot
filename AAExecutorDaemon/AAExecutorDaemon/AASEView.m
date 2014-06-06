//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "Common.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIImageView.h>
#import "NSArray+Random.h"

#import "UIAutomation.h"
#import "UIATarget+Fixes.h"
#import "UIAElement+SmartExecution.h"
#import "UIAElementArray+SmartExecution.h"

#import "AASEView.h"

@interface AASEView()

@property() NSMutableDictionary *elementDict;
@property() NSMutableArray *inputFieldKeys;
@property() NSMutableArray *actionElementKeys;
@property() NSMutableArray *pendingActionKeys;
@property() NSMutableArray *pausedActionKeys;

// operation queue to allow concurrent UI exploration during initialization
@property() dispatch_queue_t initDispatchQueue;
@property() dispatch_group_t initDispatchGroup;

// used to synchronise concurrent access to the above arrays during initWithWindow
// can be ignored after initialization
@property() NSLock *arrayAccessLock;

@end

@implementation AASEView

- (id)init {
    self = [super init];
    if (self) {
        _elementDict = [[NSMutableDictionary alloc] init];
        _inputFieldKeys = [[NSMutableArray alloc] init];
        _actionElementKeys = [[NSMutableArray alloc] init];
        _pendingActionKeys = [[NSMutableArray alloc] init];
        _pausedActionKeys = [[NSMutableArray alloc] init];
        _arrayAccessLock = [[NSLock alloc] init];
    }
    return self;
}

//get all data from UIAWindow
- (id)initWithUIAWindow:(UIAWindow*)window {
    DDLogVerbose(@"-[AASEView initWithUIAWindow:] started");

    self = [self init];
    if (self) {
        _initDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _initDispatchGroup = dispatch_group_create();
        dispatch_group_async(_initDispatchGroup, _initDispatchQueue, ^{
            [self _setSEDataForUIAWindow:window];
        });
        DDLogVerbose(@"-[AASEView initWithUIAWindow:] wait for all blocks to finish");
        dispatch_group_wait(_initDispatchGroup, DISPATCH_TIME_FOREVER);
        _initDispatchGroup = nil;
        _initDispatchQueue = nil;
        
        [_arrayAccessLock lock];
        [_pendingActionKeys addObjectsFromArray:_actionElementKeys];
        [_arrayAccessLock unlock];
    }
    DDLogVerbose(@"-[AASEView initWithUIAWindow:] done");
    return self;
}

#pragma mark elements stuff

- (void)_setSEDataForUIAWindow:(UIAWindow*)window {
    DDLogVerbose(@"-[AASEView _setSEDataForUIAWindow:]");
    [self _setSEDataForUIAElementChilds:window path:@[]];
}

- (void)_setSEDataForUIAElementChilds:(UIAElement*)uiElement path:(NSArray*)path {
//    DDLogVerbose(@"-[AASEView _setSEDataForUIAElementChilds:path:]: %@, %@", uiElement, path);

    UIAElementArray *elements = uiElement.elementsArray;
    assert(![elements isKindOfClass:[UIAElementNil class]]);
    for (int i = 0; i < [elements count]; ++i) {
        UIAElement *currElement = elements[i];
//        DDLogVerbose(@"-[AASEView _setSEDataForUIAElementChilds:path:]: Child %u: %@", i, currElement);

        
        // get SEElement
        AASEElement *seElement = [[AASEElement alloc] initWithUIAElement:currElement elementIndex:i];

        // save data to dict
        NSArray *childPath = [path arrayByAddingObject:@(i)];

        // put some special elements to their lists
        /// input elements
        if ([currElement isKindOfClass:[UIATextField class]] ||
            [currElement isKindOfClass:[UIASecureTextField class]] ||
            [currElement isKindOfClass:[UIASlider class]] ||
            [currElement isKindOfClass:[UIAPicker class]]) {
            // segmented controls are kind of input element too but may be used as button-bar too
            // thus UIASegmentedControl is not a input element for us
            
            [_arrayAccessLock lock];
            _elementDict[childPath] = seElement;
            [_inputFieldKeys addObject:childPath];
            [_arrayAccessLock unlock];

        /// action elements
        } else if ([currElement isKindOfClass:[UIAButton class]] ||
                   [currElement isKindOfClass:[UIASwitch class]] ||
                   [currElement isKindOfClass:[UIATableCell class]] ||
                   [currElement isKindOfClass:[UIALink class]]) {
            
            [_arrayAccessLock lock];
            _elementDict[childPath] = seElement;
            [_actionElementKeys addObject:childPath];
            [_arrayAccessLock unlock];

        /// handle some UIImageViews as action elements too
        } else if ([currElement isKindOfClass:[UIAImage class]] &&
                   [currElement.type isEqualToString:NSStringFromClass([UIImageView class])]) {
            
            CGSize size = [currElement.rect CGRectValue].size;
            // use only smaller objects as buttons
            if (size.height < 100 && size.width < 100) {
                [_arrayAccessLock lock];
                _elementDict[childPath] = seElement;
                [_actionElementKeys addObject:childPath];
                [_arrayAccessLock unlock];
            }
        } else {
            // default: just add the element to the dict
            [_arrayAccessLock lock];
            _elementDict[childPath] = seElement;
            [_arrayAccessLock unlock];
        }
        
//        // get child data (but not from Table and Collection views)
//        if (![currElement isKindOfClass:[UIATableView class]] &&
//            ![currElement isKindOfClass:[UIACollectionView class]]) {
//            //TODO ignore mapview too?
//#pragma message "TODO 'UIATableView' can't be ignored without further investigation!!!!! - settings, ..."
//            
            void (^setDataForChilds)(void) = ^{
                 [self _setSEDataForUIAElementChilds:currElement path:childPath];
            };
            if (_initDispatchGroup != nil) {
                dispatch_group_async(_initDispatchGroup, _initDispatchQueue, setDataForChilds);
            } else {
                setDataForChilds();
            }
//        }
    }
}

#pragma mark match window matich via isEqual and hash

- (BOOL)isEqualSEView:(AASEView*)other {
    return [_elementDict isEqualToDictionary:other.elementDict];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AASEView class]]) {
        return [self isEqualSEView:object];
    }
    return FALSE;
}

- (NSUInteger)hash {
    NSUInteger result = 0;
    for (UIAElement *element in _elements) {
        result += [element.uiaxElement.traitsNumber hash];
    }
    return result;
}

#pragma mark action selection
- (AASEElement*)nextActionElement {
    DDLogVerbose(@"-[AASEView nextActionElement]");
    
    UIAWindow *window = UIATarget.localTarget.frontMostApp.mainWindow;
    // check if window matches the seElements?!??
    
    UIAElementArray *elements = [window elementsArray];
    AASEElement *seElem = nil;
    UIAElement *uiaElem = nil;
    NSArray *path = nil;
    

    if ([_inputFieldKeys count] > 0) {
        /*
         2)   Any input elements detected?
         2.1) Fill input Fields?
         */
        // TODO: detect login views and set proper authentication settings
        // this has to be done prior to the element selection to avoid inactive buttons due to missing inputs
        [self _setInputFieldsForWindow:window];
    }
    
    BOOL selElementIsValid = FALSE;
    int pausedActionCounter = 0; // prevent endless looping over paused elements
    while (!selElementIsValid &&
           ([_pendingActionKeys count] > 0 || seElem == nil)) {
        
        if ([_pendingActionKeys count] > 0) {
            // i.e. UIASwitches first, special names buttons too
            path = [_pendingActionKeys randomObject];
            [_pendingActionKeys removeObject:path];

        } else if ([_pausedActionKeys count] > 0 &&
                   pausedActionCounter < [_pausedActionKeys count]) {
            pausedActionCounter++;
            // since the removed element will be re-added at the end,
            // we can always use the index 0 to get the next object every time
            path = _pausedActionKeys[0];
            [_pausedActionKeys removeObject:path];
            
        } else {
            DDLogVerbose(@"-[AASEView nextActionElement]: No pending or paused action element found.");
            seElem = nil;
            uiaElem = nil;
            break;
        }
        
        seElem = _elementDict[path];
        uiaElem = [elements elementForPath:path];
        seElem.uiaElement = uiaElem;
        

        if (uiaElem.isEnabledBool) {

            if (!uiaElem.isVisibleBool) {
                @try {
                    [uiaElem scrollToVisible];
                }
                @catch (NSException *exception) {
                    DDLogInfo(@"-[AASEView nextActionElement]: scrollToVisible failed: %@, %@ (%@)", uiaElem, exception.name, exception.reason);
                }
                sleep(1);
            }
            
            if (uiaElem.isVisibleBool ||
                [[window elementAtPoint:uiaElem.hitpoint] isEqual:uiaElem] ||
                [uiaElem isKindOfClass:[UIAImage class]]) {
                selElementIsValid = TRUE;
            }
        } else {
            [_pausedActionKeys addObject:path];
            seElem = nil;
            uiaElem = nil;
        }
    }
    DDLogInfo(@"-[AASEView nextActionElement]: UIElement for next action: %@", uiaElem);
    
    return seElem;
}

- (void)_setInputFieldsForWindow:(UIAWindow*)window {
    for (NSArray *path in _inputFieldKeys) {
        UIAElement *elem = [window.elementsArray elementForPath:path];
        if (elem.isVisibleBool && elem.isEnabledBool) {
            [self _setInputElement:elem];            
        }
    }
}

- (void)_setInputElement:(UIAElement*)element {    
    @try {
        if ([element isKindOfClass:[UIASecureTextField class]]) {
            if ([element.value isEqual:@""]) {
                [element setValue:@"$secret$password"];
            }
            
        } else if ([element isKindOfClass:[UIATextField class]]) {
            // this needs to be done to handle default values properly
            NSString *value = element.value;
            if ([value isEqual:@""]) {
                value = @"some Text";
            }
            [element setValue:value];
            
        } else if ([element isKindOfClass:[UIAPicker class]]) {
            for (UIAPickerWheel *wheel in [(UIAPicker*)element wheels]) {
                // avoid endless scrolling by not changing whells with a lot of values
                NSArray *values = wheel.values;
                DDLogVerbose(@"PickerWheel has %lu values", (unsigned long)[values count]);
                //avoid endless scrolling (e.g. year pickerwheel)
                if ([values count] < 100 && [values containsObject:wheel.value]) {
                    id value = [values randomObject];
                    if (value != nil) {
                        [wheel selectValue:value];
                    } else {
                        DDLogWarn(@"Unable to get picker-wheel values. Leaving wheel value unchanged.");
                    }                    
                } else {
                    DDLogWarn(@"To many picker-wheel values. Leaving wheel value unchanged.");
                }
            }
            /* UIASwitch is no longer an input element
             } else if ([element isKindOfClass:[UIASwitch class]]) {
             // toggle switch
             UIASwitch *sw = (UIASwitch*)element;
             [sw setValue:@(![sw.value boolValue])];
             //*/
        } else if ([element isKindOfClass:[UIASlider class]]) {
            NSNumber *value = @((float)(arc4random_uniform(100)+1)/(float)100);
            [element setValue:value];
            
        } else {
            DDLogError(@"Unknown / unhandled input field of class %@", [element class]);
        }
    } @catch (NSException *exception) {
        DDLogError(@"Exception while setting input element: %@ (%@)", exception.name, exception.reason);
    }
}

- (AASEExecutionState)executionState {
    if ([_pendingActionKeys count] > 0)
        return kSEStateOpen;
    else if ([_pausedActionKeys count] > 0)
        return kSEStatePaused;
    else
        return kSEStateDone;
}

- (BOOL)hasInputElements {
    return [_inputFieldKeys count] > 0;
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: elements: %@, pending: %@, paused: %@>", self.class, _elementDict, _pendingActionKeys, _pausedActionKeys];
}

- (NSString*)debugDescription {
    return [self description];
}

#pragma mark NSCopying implementation

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    if (copy) {
        [copy setElementDict:[_elementDict copyWithZone:zone]];
        [copy setInputFieldKeys:[_inputFieldKeys copyWithZone:zone]];
        [copy setActionElementKeys:[_actionElementKeys copyWithZone:zone]];
        [copy setPendingActionKeys:[_pendingActionKeys copyWithZone:zone]];
        [copy setPausedActionKeys:[_pausedActionKeys copyWithZone:zone]];
    }
    return copy;
}

@end
