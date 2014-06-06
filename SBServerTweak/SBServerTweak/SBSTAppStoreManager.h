//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreServices/SSAccount.h>
#import <StoreServices/SSPurchaseRequest.h>

@interface SBSTAppStoreManager : NSObject <SSRequestDelegate>
- (void)setRequestFinishedBlock:(void (^)(NSString *error))block;
- (BOOL)initiateAppPurchase:(NSDictionary*)appInfo withAccount:(SSAccount*)account;
- (BOOL)initiateAppPurchase:(NSDictionary*)appInfo withAccountForUniqueIdentifier:(NSNumber*)uniqueIdentifier;
- (NSArray*)accounts;


@end
