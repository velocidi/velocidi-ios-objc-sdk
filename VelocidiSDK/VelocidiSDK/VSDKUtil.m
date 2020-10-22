#import <AdSupport/ASIdentifierManager.h>
#import <AFNetworking/AFNetworking.h>
#import "VSDKGlobalVariables.h"
#import "VSDKUtil.h"

// only import/link framework when we are in a supported environment
#if defined(__IPHONE_14_0) || defined(__MAC_10_16) || defined(__TVOS_14_0) || defined(__WATCHOS_7_0)
@import AppTrackingTransparency; // NOTICE: linking happens automatically when using Modules or "semantic import".
#endif

@implementation VSDKUtil

NSString * const trackingNotAllowedErrordomain = @"com.velocidi.VSDKTrackingNotAllowedError";
NSString * const trackingNotAllowedDescKey = @"Operation cannot be completed. Tracking is not allowed";

+ (NSString *)getVersionedUserAgent {
    NSString *userAgentPrefix = [NSString stringWithFormat:@"%@/%@ %@/%@",
                                 [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey],
                                 [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey],
                                 @"VelocidiSDK",
                                 [[NSBundle bundleWithIdentifier: @"com.velocidi.VelocidiSDK"] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle bundleWithIdentifier: @"com.velocidi.VelocidiSDK"] infoDictionary][(__bridge NSString *)kCFBundleVersionKey]];
    NSString *userAgent = nil;
#if TARGET_OS_IOS
    userAgent = [userAgentPrefix stringByAppendingFormat:@" (%@; iOS %@; Scale/%0.2f)",
                 [[UIDevice currentDevice] model],
                 [[UIDevice currentDevice] systemVersion],
                 [[UIScreen mainScreen] scale]];
#elif TARGET_OS_WATCH
    userAgent = [userAgentPrefix stringByAppendingFormat:@" (%@; watchOS %@; Scale/%0.2f)",
                 [[WKInterfaceDevice currentDevice] model],
                 [[WKInterfaceDevice currentDevice] systemVersion],
                 [[WKInterfaceDevice currentDevice] screenScale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [userAgentPrefix stringByAppendingFormat:@" (Mac OS X %@)",
                 [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
    }
    return userAgent;

}

+ (void) setAcceptAllResponses: (AFHTTPSessionManager *)sessionManager {
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = nil;
}

+ (nullable NSString *) tryGetIDFA :(NSError **)error {
    
    bool trackingIsAllowed = false;
    if (@available(iOS 14, *)) {
        // this rather convoluted way to call `ATTrackingManager.trackingAuthorizationStatus` is required while keeping support for older build platforms (xcode < 12.0)
        if (NSClassFromString(@"ATTrackingManager")){
            Class manager = NSClassFromString(@"ATTrackingManager");
            NSString *keyAuthorization = @"trackingAuthorizationStatus";
            SEL selAuthorization = NSSelectorFromString(keyAuthorization);
            if ([manager respondsToSelector:selAuthorization]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                trackingIsAllowed = ((int)[manager performSelector:selAuthorization] == 3);
#pragma clang diagnostic pop
            }
        }
        
    } else {
        trackingIsAllowed = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
    
    if (trackingIsAllowed) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        
    } else if (error) {
        
        NSString *trackingNotAllowedReasonKey = nil;
        if (@available(iOS 14, *)) {
            trackingNotAllowedReasonKey = NSLocalizedString(@"The user has not opted-in to tracking or it has not yet been prompted.", nil);
        } else {
            trackingNotAllowedReasonKey = NSLocalizedString(@"The user has opted-out of tracking (Limited Ad Tracking is enabled in the user's device)", nil);
        }
        
        *error = [NSError errorWithDomain: trackingNotAllowedErrordomain
                                        code: 1
                                    userInfo: @{
                                                NSLocalizedDescriptionKey: NSLocalizedString(trackingNotAllowedDescKey, nil),
                                                NSLocalizedFailureReasonErrorKey: trackingNotAllowedReasonKey}];
        return nil;
    } else {
        return nil;
    }
}

@end
