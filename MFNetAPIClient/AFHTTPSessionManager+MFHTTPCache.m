//
//  AFHTTPSessionManager+MFHTTPCache.m
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/29/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import <objc/runtime.h>
#import "AFHTTPSessionManager+MFHTTPCache.h"
#import "NSDictionary+MFJSONFormat.h"
#import "NSString+MFEncryption.h"
#import "TMCache.h"

#import "MFCacheEntity.h"

// MFHTTPCacheProtocolCache 策略下  server端 判断请求参数中是否有cacheAnchor字段，如有则进行判断，相同则返回304，不同正常返回数据并且根据cacheKey更新本地缓存。

@implementation AFHTTPSessionManager (MFHTTPCache)


- (NSURLSessionDataTask *)GET:(MFHTTPCachePolicy)cachePolicy
                          url:(NSString *)URLString
                   parameters:(__kindof NSDictionary *)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    __block NSURLSessionDataTask *task = nil;
    NSString *cacheKey = [self __generateCacheKey:self.baseURL methodStr:URLString parameters:parameters];
    
    switch (cachePolicy) {
        case MFHTTPCacheDataDontLoad: {
            //始终采用本地缓存
            [[TMCache sharedCache] objectForKey:cacheKey block:^(TMCache *cache, NSString *key, __kindof MFCacheEntity *cacheEntity) {
                if (cacheEntity) {
                    success(task, cacheEntity.cacheContent);
                } else {
                    //报错，不存在缓存
                    NSError *error = [[NSError alloc] initWithDomain:URLString code:0 userInfo:[NSDictionary dictionaryWithObject:@"本地无缓存，也不进行请求。"                                                                      forKey:NSLocalizedDescriptionKey]];
                    failure(nil, error);
                }
            }];
            break;
        }
        case MFHTTPCacheWitchTimeout: {
            //有效期内用本地缓存，超期请求server
            [[TMCache sharedCache] objectForKey:cacheKey block:^(TMCache *cache, NSString *key, __kindof MFCacheEntity *cacheEntity) {
                
                if ((cacheEntity == nil) || ([cacheEntity.invalidDate compare:[NSDate date]] == NSOrderedDescending) || (cacheEntity.invalidDate == [NSDate dateWithTimeIntervalSince1970:0])) {
                    //请求时间晚于失效事件 或者本地无缓存，请求server
                    
                    task = [self GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:success failure:failure];
                    
//                    task.cacheKey = cacheKey;
//                    task.cachePolicy = cachePolicy;
//                    task.invalidInterval = self.cacheInvalidInterval;
                    
                    [[MFURLSessionDataTaskManager sharedInstance] addTask:task cachePolicy:cachePolicy cacheKey:cacheKey invalidInterval:self.cacheInvalidInterval];
                    
                } else {
                    success(nil, cacheEntity.cacheContent);
                }
                
            }];
            break;
        }
        case MFHTTPCacheProtocolCache: {
            
            //获取本地缓存cacheAnchor
            MFCacheEntity *entity = [[TMCache sharedCache] objectForKey:cacheKey];
            
            NSMutableDictionary *newParameters = parameters.mutableCopy;
            
            if (entity) {
                [newParameters setObject:entity.cacheAnchor forKey:@"cacheAnchor"];
            }
            
            task = [self GET:URLString parameters:newParameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:success failure:failure];
            
//            task.cacheKey = cacheKey;
//            task.cachePolicy = cachePolicy;
             [[MFURLSessionDataTaskManager sharedInstance] addTask:task cachePolicy:cachePolicy cacheKey:cacheKey invalidInterval:self.cacheInvalidInterval];
            
            break;
        }
        case MFHTTPCacheNoCache: {
            
            task = [self GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:success failure:failure];
            
//            operation.cacheKey = cacheKey;
//            operation.cachePolicy = cachePolicy;
            break;
        }
        case MFHTTPCachedEveryRequest: {
            
            task = [self GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:success failure:failure];
            
            [[MFURLSessionDataTaskManager sharedInstance] addTask:task cachePolicy:cachePolicy cacheKey:cacheKey invalidInterval:self.cacheInvalidInterval];
            
//            NSLog(@"task class : %@", [task class]);
            
//            task.cacheKey = cacheKey;
//            task.cachePolicy = cachePolicy;
            break;
        }
            
        default:
            break;
    }
    
    
    return task;
    
}

- (NSString *)__generateCacheKey:(NSURL *)baseURL methodStr:(NSString *)method parameters:(NSDictionary *)parameters {
    
#ifdef P_HAS_ANCHOR
    //parameters 去除 cacheAnchor 后加密压缩生成字符串作为key, 字段"cacheKey"
    NSMutableDictionary *keyDict = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    if ([keyDict valueForKey:@"cacheAnchor"]) {
        [keyDict removeObjectForKey:@"cacheAnchor"];
    }
#endif
    
    return [[baseURL absoluteString] mf_encryptWithItems:method, [parameters mf_jsonString], nil];
}

- (BOOL)__hasCache:(NSString *)cacheKey {
    return NO;
}

- (NSTimeInterval)cacheInvalidInterval {
    return [objc_getAssociatedObject(self, _cmd) timeInterval];
}

- (void)setCacheInvalidInterval:(NSTimeInterval)cacheInvalidInterval {
    objc_setAssociatedObject(self, @selector(cacheInvalidInterval), @(cacheInvalidInterval), OBJC_ASSOCIATION_ASSIGN);
}

@end
