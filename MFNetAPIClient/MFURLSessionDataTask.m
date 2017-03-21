//
//  MFURLSessionDataTask.m
//  UtilLib
//
//  Created by 房志刚 on 6/12/16.
//  Copyright © 2016 bjdv. All rights reserved.
//

#import "MFURLSessionDataTask.h"
#import "TMCache.h"
#import "CocoaSecurity.h"
#import <objc/runtime.h>
#import "MFCacheEntity.h"

typedef NS_ENUM(NSInteger, MFHTTPStatus) {
    MFHTTPStatusOk = 200,
    MFHTTPStatusNotModified = 304,
    MFHTTPStatusError =500,
    MFHTTPStatusNotFound = 0
    
};



@implementation MFURLSessionDataTask


- (instancetype)initWithTask:(NSURLSessionDataTask *)task cachePolicy:(MFHTTPCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey invalidInterval:(NSTimeInterval)invalidInterval {
    self = [super init];
    if (self) {
        self.task = task;
        self.cacheKey = cacheKey;
        self.cachePolicy = cachePolicy;
        self.invalidInterval = invalidInterval;
    }
    return self;
}

- (NSInteger)p__getStatusCode:(NSURLSessionDataTask *)task {
    
    NSInteger statusCode = MFHTTPStatusNotFound;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = httpResponse.statusCode;
    }
    
    return statusCode;
}

- (id)fetchDataWithResponse:(id)responseObject {
    //GET 请求才采用缓存策略
    
    id responseCacheObject = nil;
    
    if ([self.task.originalRequest.HTTPMethod isEqualToString:@"GET"]) {
        
        //根据http status code 决定是否采用本地缓存
        switch ([self p__getStatusCode:self.task]) {
            case MFHTTPStatusOk: {
                //根据request path 和 参数 生成 key  (request http body)
                //                NSString *key = [CocoaSecurity md5WithData:self.request.HTTPBody].base64;
                //此前没有缓存，此时进行本地缓存
                if ((self.cachePolicy == MFHTTPCacheProtocolCache) || (self.cachePolicy == MFHTTPCacheWitchTimeout) || (self.cachePolicy == MFHTTPCachedEveryRequest)) {
                    
                    MFCacheEntity *entity = [[MFCacheEntity alloc] initWithKey:self.cacheKey content:responseObject invalidInterval:self.invalidInterval];
                    
                    [[TMCache sharedCache] setObject:entity forKey:self.cacheKey block:^(TMCache *cache, NSString *key, id object) {
                        NSLog(@"cache %@ cached", key);
                    }];
                    
                }
                
                responseCacheObject = responseObject;
                break;
            }
            case MFHTTPStatusNotModified: {
                
                //采用缓存
                //根据request path 和 参数 生成 key  (request http body)
                //                NSString *key = [CocoaSecurity md5WithData:self.request.HTTPBody].base64;
                //根据key 获取本地缓存
                if (self.cachePolicy == MFHTTPCacheProtocolCache) {
                    
                    responseCacheObject =  [[TMCache sharedCache] objectForKey:self.cacheKey];
                }
                
                break;
            }
            case MFHTTPStatusError: {
                
                /**
                 *  报错后，如果有本地缓存，则取本地缓存
                 */
                if (self.cachePolicy != MFHTTPCacheNoCache) {
                    MFCacheEntity *entity = [[TMCache sharedCache] objectForKey:self.cacheKey];
                    if (entity) {
                        responseCacheObject = entity.cacheContent;
                    }
                } else {
                    responseCacheObject = responseObject;
                }
                break;
            }
            case MFHTTPStatusNotFound: {
                responseCacheObject = responseObject;
                break;
            }
                
        }
        
    } else {
        responseCacheObject = responseObject;
    }
    
    return responseCacheObject;
    
}



@end
