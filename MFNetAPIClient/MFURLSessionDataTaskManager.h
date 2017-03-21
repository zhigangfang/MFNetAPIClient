//
//  MFURLSessionDataTaskManager.h
//  UtilLib
//
//  Created by 房志刚 on 6/12/16.
//  Copyright © 2016 bjdv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFURLSessionDataTask.h"

@interface MFURLSessionDataTaskManager : NSObject

+ (MFURLSessionDataTaskManager *)sharedInstance;

- (void)addTask:(NSURLSessionDataTask *)task cachePolicy:(MFHTTPCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey invalidInterval:(NSTimeInterval)invalidInterval;

- (id)fetchResponseWithTaskId:(NSUInteger)taskId responseObject:(id)responseObject;

@end
