/*	NSDistributedNotificationCenter.h
 Copyright (c) 1996-2012, Apple Inc. All rights reserved.
 */

#import <Foundation/NSNotification.h>

#if TARGET_IPHONE_SIMULATOR
#define NSDistributedNotificationCenter NSNotificationCenter
#else


@class NSString, NSDictionary;

FOUNDATION_EXPORT NSString * const NSLocalNotificationCenterType;
// Distributes notifications to all tasks on the sender's machine.

@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (NSDistributedNotificationCenter *)notificationCenterForType:(NSString *)notificationCenterType;
// Currently there is only one type.

+ (id)defaultCenter;
// Returns the default distributed notification center - cover for [NSDistributedNotificationCenter notificationCenterForType:NSLocalNotificationCenterType]

//- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(NSString *)object suspensionBehavior:(NSNotificationSuspensionBehavior)suspensionBehavior;
// All other registration methods are covers of this one, with the default for suspensionBehavior = NSNotificationSuspensionBehaviorCoalesce.

- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo deliverImmediately:(BOOL)deliverImmediately;
// All other posting methods are covers of this one.  The deliverImmediately argument causes the notification to be received in the same manner as if matching registrants had registered with suspension
// behavior NSNotificationSuspensionBehaviorDeliverImmediately.  The default in covers is deliverImmediately = NO (respect suspension behavior of registrants).

enum {
    NSNotificationDeliverImmediately = (1UL << 0),
    NSNotificationPostToAllSessions = (1UL << 1)
};

- (void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo options:(NSUInteger)options;


- (void)setSuspended:(BOOL)suspended;
// Called with suspended = YES, enables the variety of suspension behaviors enumerated above.  Called with suspended = NO disables them (immediate delivery of notifications is resumed).

- (BOOL)suspended;

// Methods from NSNotificationCenter that are re-declared in part because the anObject argument is typed to be an NSString.
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(NSString *)anObject;

- (void)postNotificationName:(NSString *)aName object:(NSString *)anObject;
- (void)postNotificationName:(NSString *)aName object:(NSString *)anObject userInfo:(NSDictionary *)aUserInfo;
- (void)removeObserver:(id)observer name:(NSString *)aName object:(NSString *)anObject;

@end

#endif
