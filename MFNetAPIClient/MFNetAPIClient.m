//
//  MFNetAPIClient.m
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/28/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//


#define BASE_URL @"www.baidu.com"

#import "MFNetAPIClient.h"
#import "Reachability.h"
#import "MFJSONResponseSerializer.h"

@implementation MFNetResponseConfig

- (instancetype)initWithCodeName:(NSString *)codeName msgNmae:(NSString *)msgName {
    self = [super init];
    if (self) {
        self.resultCodeName = codeName;
        self.resultMsgName = msgName;
    }
    return self;
}

@end

@interface MFNetAPIClient ()

@property (strong, nonatomic) NSURL *realBaseURL;
@end

@implementation MFNetAPIClient

static MFNetAPIClient *_sharedClient = nil;
static dispatch_once_t onceToken;

+ (MFNetAPIClient *)sharedClientWithBaseURL:(NSURL *)url {
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MFNetAPIClient alloc] initWithBaseURL:url];
    
    });
    
    return _sharedClient;
}

- (void)startReachabilityMonitor {
    
//    if (self.baseURL) {
//        return;
//    }
    
    // Allocate a reachability object
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        self.currentNetworkReachabilityStatus = status;
        /*
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
//                _realBaseURL = [NSURL URLWithString:WAN_URL];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
//                _realBaseURL = [NSURL URLWithString:WAN_URL];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
//                _realBaseURL = [NSURL URLWithString:LAN_URL];
                break;
            default:
                break;
        }
         */
    }];
    
    [manager startMonitoring];
    
    
}

- (NSURL *)baseURL {
    return _realBaseURL;
}

- (id)initWithBaseURL:(NSURL *)url {
    
    
    //TODO: 如果responseSerializer设置成AFJSONResponseSerializer，在json不规范的情况下，AFNETWORKING直接就报json数据不规范了
    
    self = [super initWithBaseURL:url];
    
    if (self) {
        
        self.realBaseURL = url;
        [self startReachabilityMonitor];
        self.cachePolicy = MFHTTPCachedEveryRequest;  //默认缓存策略
        
        
        self.responseSerializer = [MFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
        [self.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.requestSerializer.timeoutInterval = 15.f;
        [self.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        
        //    self.requestSerializer.removesKeysWithNullValues = YES;
        
        
        
        self.securityPolicy.allowInvalidCertificates = YES;
        
    }
    
    return self;
}


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                   successBlock:(void (^)(id data))successBlock
                      failBlock:(void (^)(id data, NSError *error))failBlock
                   defaultBlock:(void (^)())defaultBlock {
    
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method responseConfig:self.responseConfig successBlock:successBlock failBlock:failBlock defaultBlock:defaultBlock];
    
}


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                 responseConfig:(MFNetResponseConfig *)responseConfig
                   successBlock:(void (^)(id data))successBlock
                      failBlock:(void (^)(id data, NSError *error))failBlock
                   defaultBlock:(void (^)())defaultBlock {
    
    if (!aPath || aPath.length <= 0) {
        return;
    }
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    发起请求
    switch (method) {
        case Get: {
            
            [self GET:self.cachePolicy url:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSError *error = nil;
                
                id realResponseObject = [[MFURLSessionDataTaskManager sharedInstance] fetchResponseWithTaskId:task.taskIdentifier responseObject:responseObject];
                
                if (responseConfig) {
                    if ([realResponseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *data = (NSDictionary *)realResponseObject;
                        int resCode = [data[responseConfig.resultCodeName] intValue];
                        if (resCode == 1) {
                            error = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:[NSDictionary dictionaryWithObject:[data valueForKey:responseConfig.resultMsgName]                                                                      forKey:NSLocalizedDescriptionKey]];
                        }
                    }
                }
                
                if (error) {
                    failBlock(responseObject, error);
                } else {
                    successBlock(responseObject);
                }
                
                defaultBlock();
                
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError *error) {
                
                NSError *failError = error;
                
                id realResponseObject = [[MFURLSessionDataTaskManager sharedInstance] fetchResponseWithTaskId:task.taskIdentifier responseObject:nil];
                
                if (realResponseObject) {
                    if (responseConfig) {
                        if ([realResponseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *data = (NSDictionary *)realResponseObject;
                            int resCode = [data[responseConfig.resultCodeName] intValue];
                            if (resCode == 1) {
                                failError = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:[NSDictionary dictionaryWithObject:[data valueForKey:responseConfig.resultMsgName]                                                                      forKey:NSLocalizedDescriptionKey]];
                            } else if (resCode == 0) {
                                successBlock(realResponseObject);
                                return;
                            }
                        }
                    }
                }
                
                failBlock(realResponseObject, failError);
                
                defaultBlock();
            
            }];
            
            break;
        }
        case Post: {
            
            [self POST:aPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSError *error = nil;
                
                if (responseConfig) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *data = (NSDictionary *)responseObject;
                        int resCode = [data[responseConfig.resultCodeName] intValue];
                        if (resCode == 1) {
                            error = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:[NSDictionary dictionaryWithObject:[data valueForKey:responseConfig.resultMsgName]                                                                      forKey:NSLocalizedDescriptionKey]];
                            
                        }
                    }
                }
                
                
                if (error) {
                    failBlock(responseObject, error);
                } else {
                    successBlock(responseObject);
                }
                
                
                defaultBlock();
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failBlock(nil,error);
                
                defaultBlock();
            }];
            
            
            break;
        }
        case Put: {
            
            [self PUT:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                successBlock(responseObject);
                defaultBlock();
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failBlock(nil,error);
                defaultBlock();
            }];
            
            
            break;
        }
        case Delete: {
            
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                successBlock(responseObject);
                defaultBlock();
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failBlock(nil,error);
                defaultBlock();
            }];
            
            
            break;
        }
        default:
            break;
    }
    
}


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block {
    
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method responseConfig:self.responseConfig andBlock:block];
    
}


- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                 responseConfig:(MFNetResponseConfig *)responseConfig
                       andBlock:(void (^)(id data, NSError *error))block{
    if (!aPath || aPath.length <= 0) {
        return;
    }
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    发起请求
    switch (method) {
        case Get: {
            
            [self GET:self.cachePolicy url:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                block([task fetchDataWithResponse:responseObject], nil);
                
                NSError *error = nil;
                
                if (responseConfig) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *data = (NSDictionary *)responseObject;
                        int resCode = [data[responseConfig.resultCodeName] intValue];
                        if (resCode == 1) {
                            error = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:@{@"info":data[responseConfig.resultMsgName]}];
                        }
                    }
                }
                
                block([[MFURLSessionDataTaskManager sharedInstance] fetchResponseWithTaskId:task.taskIdentifier responseObject:responseObject], error);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError *error) {
                block([[MFURLSessionDataTaskManager sharedInstance] fetchResponseWithTaskId:task.taskIdentifier responseObject:nil], error);
            }];
            
            break;
        }
        case Post: {
            
            [self POST:aPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSError *error = nil;
                
                if (responseConfig) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *data = (NSDictionary *)responseObject;
                        int resCode = [data[responseConfig.resultCodeName] intValue];
                        if (resCode == 1) {
                            error = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:@{@"info":data[responseConfig.resultMsgName]}];
                        }
                    }
                }
                
                block(responseObject, error);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSLog(@"%@",error);
                block(nil,error);
            }];
            
            
            break;
        }
        case Put: {
            
            [self PUT:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                block(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
                block(nil,error);
            }];
            
            
            break;
        }
        case Delete: {
            
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                block(responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
                block(nil,error);
            }];
            
            
            break;
        }
        default:
            break;
    }
    
}

/*
- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary*)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void (^)(id data, NSError *error))block {
    
    
}
 */


- (void)downloadFileWithPath:(NSString*)aPath
                   savedPath:(NSString*)savedPath
             downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
             downloadFailure:(void (^)(NSError *error))failure
                    progress:(void (^)(NSProgress *downloadProgress))progress {
    
    //沙盒路径    //NSString *savedPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/xxx.zip"];
    //    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    //    NSMutableURLRequest *request =[serializer requestWithMethod:@"GET" URLString:aPath parameters:params error:nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [serializer setValue:@"application/zip" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = serializer;
    
    NSURL *url = [NSURL URLWithString:aPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        return [NSURL fileURLWithPath:savedPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSLog(@"下载失败");
            failure(error);
        } else {
            NSLog(@"下载成功");
            success(response, filePath);
        }
        
    }];
    
    [downloadTask resume];
    
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
    }];
    
    
}


- (void)uploadImage:(NSArray<UIImage *> *)images
               path:(NSString *)path
               name:(NSString *)name
               withParams:(NSDictionary*)params
               successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
               progerssBlock:(void (^)(NSProgress *uploadProgress))progress {
    
    [self POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (UIImage *image in images) {
            
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            if ((float)data.length/1024 > 1000) {
                data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
            
        }

    
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(nil, error);
        }
    }];

    
}


- (void)uploadImage:(NSArray<UIImage *> *)images
               path:(NSString *)path
               name:(NSString *)name
         withParams:(NSDictionary*)params
       successBlock:(void (^)(id data))successBlock
          failBlock:(void (^)(id data, NSError *error))failBlock
      progerssBlock:(void (^)(NSProgress *uploadProgress))progress
       defaultBlock:(void (^)())defaultBlock {
    
    [self POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (UIImage *image in images) {
            
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            if ((float)data.length/1024 > 1000) {
                data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
            
        }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        
        if (self.responseConfig) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = (NSDictionary *)responseObject;
                int resCode = [data[self.responseConfig.resultCodeName] intValue];
                if (resCode == 1) {
                    error = [NSError errorWithDomain:@"www.MF.com" code:-1111111 userInfo:@{@"info":data[self.responseConfig.resultMsgName]}];
                }
            }
        }
        
        if (error) {
            failBlock(responseObject, error);
        } else {
            successBlock(responseObject);
        }
        
        defaultBlock();
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failBlock) {
            failBlock(nil, error);
        }
        
        defaultBlock();
        
    }];
    
    
}


- (void)uploadVoice:(NSString *)file
           withPath:(NSString *)path
         withParams:(NSDictionary*)params
           andBlock:(void (^)(id data, NSError *error))block {
    
}

@end



static MFNetAPIClientManager *_clientManager = nil;
static dispatch_once_t onceTokenn;

@implementation MFNetAPIClientManager {
    NSMutableDictionary *_clientMap;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _clientMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (MFNetAPIClient *)clientWithBaseURL:(NSURL *)url {
    
    dispatch_once(&onceTokenn, ^{
        _clientManager = [[MFNetAPIClientManager alloc] init];
        
    });
    
    MFNetAPIClient *client = [_clientManager p__fetchClientWithBaseURL:url];
    
    return client;
}

+ (void)clearClients {
    if (_clientManager) {
        [_clientManager p__clear];
    }
}

- (MFNetAPIClient *)p__fetchClientWithBaseURL:(NSURL *)url {
    
    MFNetAPIClient *client = [_clientMap objectForKey:[url absoluteString]];
    if (!client) {
        client = [MFNetAPIClient sharedClientWithBaseURL:url];
    }
    
    return client;
}

- (void)p__clear {
    [_clientMap removeAllObjects];
}

@end
