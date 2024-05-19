#import "zxUpdateManager.h"

%ctor {
    NSLog(@"[zxUpdateNotifier] calling validityCheck");
    dispatch_async(dispatch_get_main_queue(), ^{
        [zxUpdateManager validityCheck];
    });
}
