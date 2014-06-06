//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIGeometry.h>

#import <UIAutomation/UIAXElement.h>
#import <UIAutomation/UIAElementArray.h>

@class UIATarget, UIAToolbar, UIATabBar, UIAActionSheet, UIAPopover, UIAActivityView, UIAKeyboard, UIANavigationBar;

@interface UIAElement : NSObject <NSCopying>
{
    UIAXElement *_uiaxElement;
    UIAElement *_parentElement;
    NSInvocation *_selfPatienceInvocation;
    double _createdTime;
    double _lastAccessedTime;
    _Bool _isValid;
    UIAElementArray *_elements;
    NSDictionary *_elementClassIndexSets;
}

+ (id)_predicateForPredicateOrString:(id)arg1;
+ (id)elementAtPosition:(NSValue*)point;
+ (id)elementForUIAXElement:(id)arg1;
+ (Class)_classForSimpleUIAXElement:(id)arg1;
+ (Class)_uiaClassForClassName:(id)arg1;
+ (id)_jsStringForUIAElement:(id)arg1;
+ (id)_jsStringForInvocationPath:(id)arg1;
+ (id)_jsMethodCallStringForInvoker:(id)arg1 selector:(SEL)arg2;
+ (id)_jsStringForInvocation:(id)arg1;
+ (id)_jsStringForObject:(id)arg1;
+ (id)_jsStringForValue:(id)arg1;
+ (id)_jsStringForRect:(struct CGRect)arg1;
+ (id)_jsStringForPoint:(struct CGPoint)arg1;
+ (id)_jsStringForDictionary:(id)arg1;
+ (id)_jsStringForString:(id)arg1;
+ (id)_jsEscapedStringForString:(id)arg1;
+ (id)_jsMethodNameForSelector:(SEL)arg1;
+ (id)_setPatienceInvocation:(id)arg1 forUIAObject:(id)arg2;
+ (id)_waitForInvocationPath:(id)arg1;
+ (id)_performInvocationPath:(id)arg1;
+ (id)_patienceInvocationPathForUIAObject:(id)arg1;
+ (id)_invocationForInvoker:(id)arg1 selector:(SEL)arg2 arguments:(char *)arg3;
+ (double)popPatience;
+ (void)pushPatience:(double)arg1;
+ (void)setPatience:(double)arg1;
+ (double)patience;
+ (void)_setPatienceRetryInterval:(double)arg1;
+ (double)_patienceRetryInterval;
+ (id)_rectFromDictionary:(id)arg1;
+ (id)_hitPointForObject:(id)arg1;
+ (id)_hitPointFromDictionary:(id)arg1;
+ (id)_valueForAXElement:(id)arg1;
+ (id)_nameForAXElement:(id)arg1;
+ (struct CGPoint)_convertPointToCurrentInterfaceOrientation:(struct CGPoint)arg1;
+ (struct CGPoint)_convertPointFromCurrentInterfaceOrientation:(struct CGPoint)arg1;
+ (struct CGRect)_convertRectFromCurrentInterfaceOrientation:(struct CGRect)arg1;
+ (struct CGRect)_convertRectToCurrentInterfaceOrientation:(struct CGRect)arg1;
+ (NSArray*)allKeys;
+ (NSDictionary*)toManyRelationshipKeys;
+ (NSDictionary*)toOneRelationshipKeys;
+ (NSArray*)attributeKeys;
+ (struct CGAffineTransform)_transformToRotateToInterfaceOrientation:(long long)arg1;
+ (struct CGAffineTransform)_transformToRotateFromInterfaceOrientation:(long long)arg1;
+ (id)_elementWithUIAXElement:(id)arg1 parent:(id)arg2;
+ (id)_countsString;
+ (long long)_maxCount;
+ (long long)_liveCount;
+ (void)_logVerbosity:(unsigned long long)arg1 format:(id)arg2;
+ (_Bool)_delayForTimeInterval:(double)arg1;
+ (void)initialize;
- (UIAElementArray*)webViews;
- (UIAElementArray*)textViews;
- (UIAToolbar*)toolbar;
- (UIAElementArray*)toolbars;
- (UIATabBar*)tabBar;
- (UIAElementArray*)tabBars;
- (UIAElementArray*)searchBars;
- (UIAElementArray*)secureTextFields;
- (UIAElementArray*)textFields;
- (UIAElementArray*)tableViews;
- (UIAElementArray*)staticTexts;
- (UIAElementArray*)switches;
- (UIAElementArray*)sliders;
- (UIAElementArray*)segmentedControls;
- (UIAElementArray*)scrollViews;
- (UIAElementArray*)progressIndicators;
- (UIAPopover*)popover;
- (UIAElementArray*)popovers;
- (UIAElementArray*)pickers;
- (UIAElementArray*)pageIndicators;
- (UIANavigationBar*)navigationBar;
- (UIAElementArray*)navigationBars;
- (UIAElementArray*)mapViews;
- (UIAElementArray*)links;
- (UIAElementArray*)keys;
- (UIAKeyboard*)keyboard;
- (UIAElementArray*)keyboards;
- (UIAElementArray*)images;
- (UIAElementArray*)editingMenus;
- (UIAElementArray*)collectionViews;
- (UIAElementArray*)buttons;
- (UIAElementArray*)activityIndicators;
- (UIAActivityView*)activityView;
- (UIAElementArray*)activityViews;
- (UIAActionSheet*)actionSheet;
- (UIAElementArray*)actionSheets;
- (id)_elementsOfClass:(Class)arg1 forSelector:(SEL)arg2;
- (UIAElementArray*)elements;
- (id)withPredicate:(id)arg1;
- (id)withValue:(id)arg1 forKey:(id)arg2;
- (id)withName:(id)arg1;
- (id)responder;
- (id)elementAtPoint:(NSValue*)point;
- (id)_elementAtPosition:(struct CGPoint)arg1;
- (id)_elementForUIAXElement:(id)arg1;
- (id)_inspectedElementForAXAncestry:(id)arg1 index:(unsigned long long *)arg2 triedKeys:(id)arg3;
- (id)_inspectedToManyRelationship:(id)arg1 forAXAncestry:(id)arg2 index:(unsigned long long *)arg3;
- (id)_inspectedToOneRelationship:(id)arg1 forAXAncestry:(id)arg2 index:(unsigned long long *)arg3;
- (_Bool)_inspectConfirmElement:(id)arg1 forAXAncestry:(id)arg2 index:(unsigned long long *)arg3;
- (id)_elementsForUIAXElements:(id)arg1;
- (id)_elementsForUIAXElements:(id)arg1 axFilter:(SEL)arg2;
- (id)_elementForSimpleUIAXElement:(id)arg1;
- (id)scriptingSynonymFullExpressionString;
- (id)scriptingSynonymStrings;
- (id)scriptingSynonyms;
- (id)scriptingFavoredSynonymString;
- (id)_scriptingSynonymsForSubElement:(id)arg1 maxCount:(unsigned long long)arg2;
- (id)scriptingInvocationFullExpressionString;
- (id)scriptingInvocationString;
- (id)scriptingActionExpressionShouldFavorTapOffset;
- (id)_patienceForAttribute:(SEL)arg1 value:(id)arg2;
- (id)_objectWithPatienceInvocationFromUIAObject:(id)arg1 selector:(SEL)arg2;
- (void)chopPatience;
- (void)_setSelfPatienceInvocation:(id)arg1;
- (id)_selfPatienceInvocation;
- (id)scrollToElementWithValue:(id)arg1 forKey:(id)arg2;
- (id)scrollToElementWithPredicate:(id)arg1;
- (id)scrollToElementWithName:(id)arg1;
- (id)scrollToVisible;
- (void)scrollRight;
- (void)scrollLeft;
- (void)scrollDown;
- (void)scrollUp;
- (void)rotateWithOptions:(id)arg1;
- (void)_rotateWithOptions:(id)arg1;
- (void)flickInsideWithOptions:(id)arg1;
- (void)dragInsideWithOptions:(id)arg1;
- (void)_dragInsideWithOptions:(id)arg1 withFlick:(_Bool)arg2;
- (void)touchAndHold:(id)arg1;
- (void)tapWithOptions:(id)arg1;
- (void)twoFingerTap;
- (void)doubleTap;
- (void)tap;
- (_Bool)_prepareForAction:(SEL)arg1;
- (void)_delayForAnimationsInProgress;
- (void)redo;
- (void)undo;
- (NSString*)type; //UIKit classname
- (NSString*)className; //just the current objects classname
- (id)dom;
- (id)url;
- (void)setValue:(id)arg1;
- (_Bool)_shouldAllowSettingValue;
- (NSString*)value;
- (NSString*)name;
- (UIATarget*)target;
- (CFBooleanRef)isSelected;
- (CFBooleanRef)isVisible;
- (CFBooleanRef)hasRemoteFocus;
- (CFBooleanRef)hasKeyboardFocus;
- (CFBooleanRef)isEnabled;
- (id)_uiaHitpoint;
- (NSValue*)hitpoint;
- (id)_hitpoint;
- (id)_uiaRect;
- (NSValue*)rect;
- (NSString*)label;
- (id)hint;
- (NSNumber*)pid;
- (void)logAXTree;
- (void)logAXInfo;
- (void)logElementTree;
- (void)logElement;
- (id)_logInfoWithChildren;
- (id)_logInfo;
- (NSArray*)ancestry;
- (UIAElement*)parentElement;
- (UIAXElement*)uiaxElement;
- (NSDictionary*)toManyRelationships;
- (NSDictionary*)toOneRelationships;
- (NSDictionary*)attributes;
- (id)valueForUndefinedKey:(NSString*)key;
- (id)_synonymToManyRelationshipKeys;
- (NSArray*)allKeys;
- (NSArray*)toManyRelationshipKeys;
- (NSArray*)toOneRelationshipKeys;
- (NSArray*)attributeKeys;
- (_Bool)waitForInvalid;
- (_Bool)checkIsValid;
- (_Bool)isValid;
- (void)_setLastAccessedTime:(double)arg1;
- (double)_lastAccessedTime;
- (double)_createdTime;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (NSString*)description;
- (unsigned long long)hash;
- (_Bool)isEqual:(id)arg1;
- (void)_invalidate;
- (void)_emptyCaches;
- (void)dealloc;
- (id)_initWithUIAXElement:(id)arg1 parent:(id)arg2;
- (id)init;

@end

