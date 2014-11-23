//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <StoreServices/SSPurchase.h>
#import <StoreServices/SSPurchaseRequest.h>
#import <StoreServices/SSAccountStore.h>
#import <StoreServices/SSNotifications.h>
#import <StoreServices/SSDownloadProperties.h>

#import "SBSTAppStoreManager.h"
#import "SBSTSpringBoardManager.h"
#import "Common.h"

#define SU_PROP_ITEM_TYPE @"1"
#define SU_PROP_ITEM_TITLE @"2"
#define SU_PROP_ITEM_ID @"7"
#define SU_PROP_BUNDLE_ID @"c"
#define SU_PROP_ARTIST_NAME @"d"
#define SU_PROP_ARTWORK_URL @"G"


@interface SBSTAppStoreManager()
@property NSCondition *requestLock;
@property BOOL requestFinished;
@end

@implementation SBSTAppStoreManager {
    void (^requestFinishedBlock)(NSString *error);
}

- (id)init {
    self = [super init];
    if(self) {
        _requestLock = [[NSCondition alloc] init];
        _requestFinished = NO;
    }
    return self;
}

- (void)setRequestFinishedBlock:(void (^)(NSString *error))block {
    requestFinishedBlock = block;
}

- (BOOL)initiateAppPurchase:(NSDictionary *)appInfo withAccount:(SSAccount *)account {
    
    if (!account.isAuthenticated) {
        DDLogWarn(@"Account is not authenticated: %@", account.accountName);
    } else {
        DDLogVerbose(@"Account is authenticated! (%@)", account);
    }
    
    NSArray *keys = @[SU_PROP_ITEM_TYPE, SU_PROP_ITEM_TITLE, SU_PROP_ITEM_ID, SU_PROP_BUNDLE_ID, SU_PROP_ARTIST_NAME, SU_PROP_ARTWORK_URL];
    
    NSDictionary *keyMapping = @{
        SU_PROP_ITEM_TYPE:@"item-type",
        SSDownloadPropertyThumbnailImageURL:@"artwork-url",
        SSDownloadPropertyBundleIdentifier:@"bundle-id",
        SSDownloadPropertyArtistName:@"artist-name",
        SSDownloadPropertyStoreItemIdentifier:@"item-id",
        SSDownloadPropertyTitle:@"item-title"
    };

    SSPurchase *purchase = [[SSPurchase alloc] init];
    [purchase setAccountIdentifier: account.uniqueIdentifier];
    
    NSString *buyParam = appInfo[@"action-params"];
    if (buyParam == nil) {
        DDLogError(@"AppInfo does not conatain buyParameters (action-params)");
        return false;
    }
    DDLogVerbose(@"buyParameters: %@", buyParam);
    [purchase setBuyParameters: buyParam];

    for (NSString *key in keys) {
        id value = appInfo[keyMapping[key]];
        if (value == nil) {
            DDLogError(@"AppInfo does not conatain a neccessary key: %@", key);
            return false;
        }
        [purchase setValue:value forDownloadProperty:key];
    }
    [purchase setIgnoresForcedPasswordRestriction:true];
    
    DDLogVerbose(@"purchase: %@", purchase);
    
    SSPurchaseRequest *purchaseReq = [[SSPurchaseRequest alloc] initWithPurchases: @[purchase]];
    
    // disable authentification-promt as long as the password is cached locally
    [purchaseReq setNeedsAuthentication:false];

    [purchaseReq setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SBInstalledApplicationsDidChangeNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        DDLogVerbose(@"SBInstalledApplicationsDidChangeNotification: %@", note);
        [self _installFinished:nil];
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_requestLock lock];
        _requestFinished = NO;
        [_requestLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:120]];
        if (!_requestFinished) {
            [purchaseReq cancel];
            sleep(5);
            if (!_requestFinished) {
                [self _installFinished:@"request timeout"];
            }
        }
        [_requestLock unlock];
    });
    
    return [purchaseReq start];

}

- (BOOL)initiateAppPurchase:(NSDictionary*)appInfo withAccountForUniqueIdentifier:(NSNumber*)uniqueIdentifier {
    SSAccount *account = [[SSAccountStore defaultStore] accountWithUniqueIdentifier:uniqueIdentifier];
    DDLogVerbose(@"initiateAppPurchase: %@ withAccountForUniqueIdentifier: %@", appInfo, account);
    if (account != nil) {
        return [self initiateAppPurchase:appInfo withAccount:account];
    } else {
        return false;
    }
}

- (NSArray*)accounts {
    return [[SSAccountStore defaultStore] accounts];
}

- (void)_installFinished:(NSString*)errorMsg {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (requestFinishedBlock != nil) {
        requestFinishedBlock(errorMsg);
    }
}

#pragma mark SSPurchaseRequestDelegate

- (void)purchaseRequest:(id)request purchaseDidSucceed:(id)purchase {
    DDLogVerbose(@"purchaseRequest:purchaseDidSucceed: waiting for installation to finish. Purchase: %@", purchase);
    [_requestLock lock];
    _requestFinished = YES;
    [_requestLock signal];
    [_requestLock unlock];
}

- (void)purchaseRequest:(id)request purchaseDidFail:(id)purchase withError:(id)error {
    DDLogVerbose(@"purchaseRequest:purchaseDidFail:withError: %@", error);
    [_requestLock lock];
    _requestFinished = YES;
    [_requestLock signal];
    [_requestLock unlock];
    [self _installFinished:@"Request failed"];
}

@end


