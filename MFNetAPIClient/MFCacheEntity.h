//
//  MFCacheEntity.h
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/29/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import <Foundation/Foundation.h>

//本地缓存结构
//key
//cacheAnchor
//cacheContent
//invalidDate

@interface MFCacheEntity : NSObject <NSCoding>

@property (strong, nonatomic) NSString *cacheKey;
@property (strong, nonatomic) NSString *cacheAnchor;    //最终由anchor 在server端进行对比 是否返回304
@property (strong, nonatomic) NSObject *cacheContent;            //真正缓存的内存，一般为model对象实例
@property (strong, nonatomic) NSDate *invalidDate;      //缓存失效时间

- (instancetype)initWithKey:(NSString *)key content:(id)content invalidInterval:(NSTimeInterval)interval;
/**
 *  TMCache 磁盘存储 实现NSCoding协议
 */

@end
