//
//  NSDictionary+MFJSONFormat.m
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/30/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import "NSDictionary+MFJSONFormat.h"

@implementation NSDictionary (MFJSONFormat)

- (NSString *)mf_jsonString {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
