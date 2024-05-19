#import <UIKit/UIKit.h>

@interface zxUpdateManager : NSObject
+ (void)validityCheck;
+ (void)getAppInfoWithBundleId:(NSString *)bundleId currentVersion:(NSString *)cVersion;
+ (void)markInvalidWithMsg:(NSString *)msg text:(NSString *)text;
+ (void)notifyWithMsg:(NSString *)msg buttonText:(NSString *)bText handler:(void (^)(UIAlertAction *action))handler;
@end
