//
//  SSNotifications.h
//  SBServerTweak
//
//  Created by Andreas Weinlein on 04.12.12.
//  Copyright (c) 2012 Andreas Weinlein. All rights reserved.
//

#ifndef SBServerTweak_SSNotifications_h
#define SBServerTweak_SSNotifications_h


NSString *const SSNotificationDownloadsAdded = @"SSNotificationDownloadsAdded";
NSString *const SSNotificationDownloadsChanged = @"SSNotificationDownloadsChanged";
NSString *const SSNotificationDownloadsRemoved = @"SSNotificationDownloadsRemoved";
NSString *const SSNotificationDownloadReplaced = @"SSNotificationDownloadReplaced";
NSString *const SSNotificationDownloadStatusChanged = @"SSNotificationDownloadStatusChanged";

// SSPurchaseRequest failed
NSString *const SSNotificationPurchaseFailed = @"SSNotificationPurchaseFailed";

// SSPurchaseRequest succeeded
NSString *const SSNotificationPurchaseFinished = @"SSNotificationPurchaseFinished";

// SSRequest failed
NSString *const SSNotificationRequestFailed = @"SSNotificationRequestFailed";

// SSRequest succeeded
NSString *const SSNotificationRequestFinished = @"SSNotificationRequestFinished";


#endif
