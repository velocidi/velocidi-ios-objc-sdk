@import Foundation;
#import "VSDKRequest.h"
#import "VSDKUtil.h"

@implementation VSDKRequest

- (instancetype)initWithHTTPSessionManager:(AFHTTPSessionManager *)manager{
    if (self = [self init]) {
        _manager = manager;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _manager = [AFHTTPSessionManager manager];
        _util = [[VSDKUtil alloc] init] ;
        [VSDKUtil setAcceptAllResponses:_manager];
    }
    return self;
}

- (void)performRequest: (void (^)(NSURLResponse *response, id responseObject))onSuccessBlock
        :(void (^)(NSError *error))onFailureBlock {
    if (![self.util isAdvertisingTrackingEnabled]) {
        return;
    }

    NSUUID * advertisingIdentifier = [self.util getAdvertisingIdentifier];

    NSURLComponents * url = [self buildURLWithQueryParameters: [advertisingIdentifier UUIDString]];

    NSMutableURLRequest * request = [[AFJSONRequestSerializer serializer]
                                     requestWithMethod: @"POST"
                                     URLString: [url string]
                                     parameters: self.data.toDictionary error:nil];
    [request setValue:[self.util getVersionedUserAgent] forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *dataTask = [self.manager
            dataTaskWithRequest:request
            uploadProgress:nil
            downloadProgress:nil
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    onFailureBlock(error);
                } else {
                    onSuccessBlock(response, responseObject);
                }
            }];
    [dataTask resume];
}

- (NSURLComponents *)buildURLWithQueryParameters:(NSString *) advertisingIdentifier {
    NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithURL: self.url resolvingAgainstBaseURL: true];
    NSMutableArray<NSURLQueryItem *> * queryParams = [[NSMutableArray alloc] init];

    [queryParams addObject: [[NSURLQueryItem alloc] initWithName:@"id_idfa" value:advertisingIdentifier]];
    [queryParams addObject: [[NSURLQueryItem alloc] initWithName:@"cookies" value:false]];

    urlComponents.queryItems = queryParams;
    return urlComponents;
}

@end
