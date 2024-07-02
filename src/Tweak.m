#import "zxUpdateManager.h"

__attribute__((constructor)) static void init() {
    @autoreleasepool {
        NSLog(@"[zxUpdateNotifier] calling validityCheck");
        dispatch_async(dispatch_get_main_queue(), ^{
            [zxUpdateManager validityCheck];
        });
    }
}
