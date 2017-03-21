//
//  MFURLSessionDataTaskManager.m
//  UtilLib
//
//  Created by 房志刚 on 6/12/16.
//  Copyright © 2016 bjdv. All rights reserved.
//

#import "MFURLSessionDataTaskManager.h"

static NSMutableDictionary *taskDictionary;

@implementation MFURLSessionDataTaskManager    //存储task

+ (MFURLSessionDataTaskManager *)sharedInstance {
    
    static MFURLSessionDataTaskManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
        taskDictionary = [[NSMutableDictionary alloc] init];
    });
    return instance;
    
}

- (void)addTask:(NSURLSessionDataTask *)task cachePolicy:(MFHTTPCachePolicy)cachePolicy cacheKey:(NSString *)cacheKey invalidInterval:(NSTimeInterval)invalidInterval {
    
    MFURLSessionDataTask *mfTask = [[MFURLSessionDataTask alloc] initWithTask:task cachePolicy:cachePolicy cacheKey:cacheKey invalidInterval:invalidInterval];
    if (mfTask) {
        [taskDictionary setObject:mfTask forKey:@(task.taskIdentifier)];
    }
    
}

- (id)fetchResponseWithTaskId:(NSUInteger)taskId responseObject:(id)responseObject {
    
    MFURLSessionDataTask *mfTask = (MFURLSessionDataTask *)[taskDictionary objectForKey:@(taskId)];
    
    if (!mfTask) {
        return nil;
    }
    
    return [mfTask fetchDataWithResponse:responseObject];
    
}

@end
