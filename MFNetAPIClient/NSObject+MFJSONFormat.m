//
//  NSObject+MFJSONFormat.m
//  Pods
//
//  Created by 房志刚 on 21/3/2017.
//
//

#import "NSObject+MFJSONFormat.h"

@implementation NSObject (MFJSONFormat)

- (NSString *)mf_jsonString {
    
    if ([self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSDictionary class]]) {
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    return nil;
    
}

@end
