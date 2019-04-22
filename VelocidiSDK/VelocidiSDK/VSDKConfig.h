#import <Foundation/Foundation.h>


@interface VSDKConfig : NSObject

/**
  URL used to make track requests
 */
@property NSString *trackingHost;

/**
  URL used to make match requests
 */
@property NSString *matchHost;

/**
  Initialize an instance of VSDKConfig.
  @param trackingHost URL used to make track requests
  @param matchHost URL used to make match requests
  @returns VSDKConfig instance
 */
- (instancetype)initWithHosts: (NSString *)trackingHost :(NSString *)matchHost;

@end
