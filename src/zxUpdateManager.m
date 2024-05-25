#import "zxUpdateManager.h"
#import "KSJSON.h"

@implementation zxUpdateManager
+ (void)validityCheck {
    // iirc some apps dont have CFBundleShortVersionString
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zxAvoidUpdates"]) return;

    NSString *version = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (version == nil) return
        [self markInvalidWithMsg:@"this app does not contain CFBundleShortVersionString and is incompatible with zxUpdateManager."
                            text:@"okay"];

    // avoid prompting twice
    NSDictionary *latestInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"zxAppInfo"];
    if (latestInfo == nil || ![latestInfo[@"lastSeen"] isEqualToString:version]) {
        NSLog(@"[zxUpdateManager] checking for updates with version: %@", version);
        [self getAppInfoWithBundleId:NSBundle.mainBundle.bundleIdentifier currentVersion:version];
    }
}

+ (void)getAppInfoWithBundleId:(NSString *)bundleId currentVersion:(NSString *)cVersion {
    // a random param (`hi`) is needed to avoid getting a cached response
    NSString *reqURL =
        [NSString stringWithFormat:@"https://itunes.apple.com/lookup?limit=1&hi=%@&bundleId=%@", NSUUID.UUID, bundleId];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, id httpResp, NSError *error) {
        if (error) return
            [self notifyWithMsg:[NSString stringWithFormat:@"error checking for updates:\n%@", error]
                     buttonText:@"strange"
                        handler:nil];

        // KSJSON is the tiniest bit faster than NSJSONSerialization, i just want an excuse to use it :P
        NSString *jsstr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *resp = [KSJSON deserializeString:jsstr error:nil];

        if ([resp[@"resultCount"] isEqual:@0]) return
            [self markInvalidWithMsg:@"this app was not found on the app store.\n\np.s. did you change the bundle id?"
                                text:@"okay"];

        NSDictionary *latestInfo = @{
            @"id": resp[@"results"][0][@"trackId"],
            @"version": resp[@"results"][0][@"version"],
            @"lastSeen": cVersion  // used for preventing dupe notifs
        };

        NSLog(@"[zxUpdateManager] latestInfo: %@", latestInfo);
        if (![latestInfo[@"version"] isEqualToString:cVersion]) {
            [[NSUserDefaults standardUserDefaults] setObject:latestInfo forKey:@"zxAppInfo"];

            NSString
                *updMsg =
                    [NSString stringWithFormat:@"an update is available!\n\nv%@ -> v%@", cVersion, latestInfo[@"version"]],
                *storeLink =
                    [NSString stringWithFormat:@"https://apps.apple.com/app/id%@", latestInfo[@"id"]];

            [self notifyWithMsg:updMsg
                     buttonText:@"let me see!"
                        handler:^(UIAlertAction *action) {
                                  [[UIApplication sharedApplication]
                                      openURL:[NSURL URLWithString:storeLink]
                                      options:@{}
                            completionHandler:nil];
                        }];
        }
    }] resume];
}

+ (void)markInvalidWithMsg:(NSString *)msg text:(NSString *)text {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zxAvoidUpdates"];
    return [self notifyWithMsg:msg
                    buttonText:text
                       handler:nil];
}

+ (void)notifyWithMsg:(NSString *)msg buttonText:(NSString *)bText handler:(void (^)(UIAlertAction *action))handler {
    NSLog(@"[zxUpdateManager] making popup with msg: %@", msg);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"zxUpdateNotifier"
                                                message:msg
                                         preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *act =
            [UIAlertAction actionWithTitle:bText
                                     style:UIAlertActionStyleDefault
                                   handler:handler];

        [alert addAction:act];

        UIViewController *rvc = UIApplication.sharedApplication.keyWindow.rootViewController;
        while (rvc.presentedViewController) rvc = rvc.presentedViewController;
        [rvc presentViewController:alert animated:YES completion:nil];
    });
}
@end
