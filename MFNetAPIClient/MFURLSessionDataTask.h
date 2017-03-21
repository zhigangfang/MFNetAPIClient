//
//  MFURLSessionDataTask.h
//  UtilLib
//
//  Created by 房志刚 on 6/12/16.
//  Copyright © 2016 bjdv. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MFHTTPCachePolicy) {
    MFHTTPCacheProtocolCache = 0,  //默认策略，本地缓存过时则用采用返回对象作为新缓存，本地无缓存则返回对象保存到本地缓存，304本地缓存为最新则用本地缓存
    MFHTTPCacheNoCache = 1,        //不采用缓存，始终从server获取，也不进行缓存
    MFHTTPCacheDataDontLoad = 2,   //始终采用本地本地缓存，不从server获取
    MFHTTPCacheWitchTimeout = 3,    //设置缓存失效时间，超过时效期则从server获取，本地无缓存则直接server取
    MFHTTPCachedEveryRequest = 4   //每个请求返回数据都进行缓存，请求前不与本地缓存进行对比，忽略304, 未请求到数据则用本地缓存
};


@interface MFURLSessionDataTask : NSObject

//本地缓存对应的key，与requestOperation相关联
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSString *cacheKey;
@property (assign, nonatomic) MFHTTPCachePolicy cachePolicy;
@property (assign, nonatomic) NSTimeInterval invalidInterval;  //缓存失效间隔

- (instancetype)initWithTask:(NSURLSessionDataTask *)task cachePolicy:(MFHTTPCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey invalidInterval:(NSTimeInterval)invalidInterval;
- (id)fetchDataWithResponse:(id)responseObject;

@end
