#import "VSDKProductFeedback.h"

@implementation VSDKProductFeedback

- (instancetype)init {
    if(self = [super init]){
        self.type = @"productFeedback";
    }
    return self;
}

@end