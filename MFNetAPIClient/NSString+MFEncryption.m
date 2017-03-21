//
//  NSString+MFEncryption.m
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/28/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import "NSString+MFEncryption.h"
#import "CocoaSecurity.h"

@implementation NSString (MFEncryption)

- (NSString *)mf_encryptWithItems:(NSString *)firstItem, ... {
    
    va_list args;
    va_start(args, firstItem); // scan for arguments after firstItem.
    
    // get rest of the objects until nil is found
    NSMutableString *allStr = [[NSMutableString alloc] initWithCapacity:16];
    for (NSString *item = firstItem; item != nil; item = va_arg(args, NSString*)) {
        //用"-"分割
        [allStr appendFormat:@"-%@",item];
    }
    
    va_end(args);
    
    CocoaSecurityResult *aesDefault = [CocoaSecurity aesEncrypt:allStr key:@"key"];
    
    return aesDefault.base64;
    
}

@end
