//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

#import "AASEView.h"

@interface AASEOtherApplicationView : AASEView

- (id)initWithBundleId:(NSString*)bundleId;

@property(readonly) NSString* bundleId;

@end
