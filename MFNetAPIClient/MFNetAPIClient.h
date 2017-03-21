//
//  MFNetAPIClient.h
//  MFNetAPIClient
//
//  Created by 房志刚 on 16/3/2017.
//  Copyright © 2017 bjdv. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MFNetAPIClient.
FOUNDATION_EXPORT double MFNetAPIClientVersionNumber;

//! Project version string for MFNetAPIClient.
FOUNDATION_EXPORT const unsigned char MFNetAPIClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MFNetAPIClient/PublicHeader.h>




#import "AFNetworking.h"
#import "AFHTTPSessionManager+MFHTTPCache.h"
#import "MFURLSessionDataTaskManager.h"

@interface MFNetResponseConfig : NSObject

- (instancetype)initWithCodeName:(NSString *)codeName msgNmae:(NSString *)msgName;

@property (strong, nonatomic) NSString *resultCodeName;
@property (strong, nonatomic) NSString *resultMsgName;

@end


typedef NS_ENUM(NSInteger, NetworkMethod) {
    Get = 0,
    Post,
    Put,
    Delete
};


@interface MFNetAPIClient : AFHTTPSessionManager

@property (assign, nonatomic) MFHTTPCachePolicy cachePolicy;
@property (strong, nonatomic) MFNetResponseConfig *responseConfig;

@property (assign, nonatomic) AFNetworkReachabilityStatus currentNetworkReachabilityStatus;

+ (MFNetAPIClient *)sharedClientWithBaseURL:(NSURL *)url;

- (void)startReachabilityMonitor;


/*******根据resultCode 调用 success or fail block*****涉及业务层*********/
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                   successBlock:(void (^)(id data))successBlock
                      failBlock:(void (^)(id data, NSError *error))failBlock
                   defaultBlock:(void (^)())defaultBlock;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                 responseConfig:(MFNetResponseConfig *)responseConfig
                   successBlock:(void (^)(id data))successBlock
                      failBlock:(void (^)(id data, NSError *error))failBlock
                   defaultBlock:(void (^)())defaultBlock;





/******网络层***********/
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                 responseConfig:(MFNetResponseConfig *)responseConfig
                       andBlock:(void (^)(id data, NSError *error))block;


/*
 - (void)requestJsonDataWithPath:(NSString *)aPath
 file:(NSDictionary *)file
 withParams:(NSDictionary*)params
 withMethodType:(NetworkMethod)method
 andBlock:(void (^)(id data, NSError *error))block;
 */

//下载文件
- (void)downloadFileWithPath:(NSString*)aPath
                   savedPath:(NSString*)savedPath
             downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
             downloadFailure:(void (^)(NSError *error))failure
                    progress:(void (^)(NSProgress *downloadProgress))progress;


//上传多个图片(内部有压缩)
//TODO:压缩算法可配置
- (void)uploadImage:(NSArray<UIImage *> *)images
               path:(NSString *)path
               name:(NSString *)name
         withParams:(NSDictionary*)params
       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
      progerssBlock:(void (^)(NSProgress *uploadProgress))progress;


- (void)uploadImage:(NSArray<UIImage *> *)images
               path:(NSString *)path
               name:(NSString *)name
         withParams:(NSDictionary*)params
       successBlock:(void (^)(id data))successBlock
          failBlock:(void (^)(id data, NSError *error))failBlock
      progerssBlock:(void (^)(NSProgress *uploadProgress))progress
       defaultBlock:(void (^)())defaultBlock;

//上传语音
- (void)uploadVoice:(NSString *)file
           withPath:(NSString *)path
         withParams:(NSDictionary*)params
           andBlock:(void (^)(id data, NSError *error))block;


@end


@interface MFNetAPIClientManager : NSObject

+ (MFNetAPIClient *)clientWithBaseURL:(NSURL *)url;

+ (void)clearClients;

@end


