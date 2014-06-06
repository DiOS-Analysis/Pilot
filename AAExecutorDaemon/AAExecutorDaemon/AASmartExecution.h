//
//  Copyright (c) 2014 Andreas Weinlein <dev@weinlein.info>, Andreas Kurtz <mail@andreas-kurtz.de>. All rights reserved.
//

typedef enum {
    kSEStateOpen,   // there are unexecuted actions
    kSEStatePaused, // there may be unexecuted actions - but currently blocked (like disabled buttons)
    kSEStateDone,   // all actions have been executed
} AASEExecutionState;

