//
//  AFHTTPSessionManager+MFHTTPCache.h
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/29/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "MFURLSessionDataTask.h"
#import "MFURLSessionDataTaskManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AFHTTPSessionManager (MFHTTPCache)

@property (assign, nonatomic) NSTimeInterval cacheInvalidInterval;

//http://www.cocoachina.com/ios/20150603/11989.html
- (NSURLSessionDataTask *)GET:(MFHTTPCachePolicy)cachePolicy
                                   url:(NSString *)URLString
                            parameters:(__kindof NSDictionary *)parameters
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
