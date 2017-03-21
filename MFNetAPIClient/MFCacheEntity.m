//
//  MFCacheEntity.m
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/29/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import "MFCacheEntity.h"
#import "CocoaSecurity.h"
#import "NSObject+MFJSONFormat.h"

@implementation MFCacheEntity

- (instancetype)initWithKey:(NSString *)key content:(id)content invalidInterval:(NSTimeInterval)interval {
    
    self = [super init];
    if (self) {
        
        self.cacheKey = key;
        self.cacheContent = content;
        
        if (interval == 0) {
            self.invalidDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        } else {
            self.invalidDate = [[NSDate alloc] initWithTimeIntervalSinceNow:interval]; 
        }
        
        /**
         *  cacheAnchor 采用摘要算法
         */
        CocoaSecurityResult *md5 = [CocoaSecurity md5:[content mf_jsonString]];
        self.cacheAnchor = md5.hexLower;
        
    }

    return self;
    
}

//http://www.cnblogs.com/Travis990/articles/5152956.html
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.cacheKey forKey:@"cacheKey"];
    [aCoder encodeObject:self.cacheAnchor forKey:@"cacheAnchor"];
    [aCoder encodeObject:self.cacheContent forKey:@"cacheContent"];
    [aCoder encodeObject:self.invalidDate forKey:@"invalidDate"];
}

/*
@property (strong, nonatomic) NSString *cacheKey;
@property (strong, nonatomic) NSString *cacheAnchor;    //最终由anchor 在server端进行对比 是否返回304
@property (weak, nonatomic) id cacheContent;            //真正缓存的内存，一般为model对象实例
@property (strong, nonatomic) NSDate *invalidDate;
*/


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        
        self.cacheKey = [aDecoder decodeObjectForKey:@"cacheKey"];
        self.cacheAnchor = [aDecoder decodeObjectForKey:@"cacheAnchor"];
        self.cacheContent = [aDecoder decodeObjectForKey:@"cacheContent"];
        self.invalidDate = [aDecoder decodeObjectForKey:@"invalidDate"];
        
    }
    return self;
    
}


@end
