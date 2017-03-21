//
//  NSString+MFCommon.m
//  Pods
//
//  Created by 房志刚 on 21/3/2017.
//
//

#import "NSString+MFCommon.h"

@implementation NSString (MFCommon)

- (NSString *)mf_removeUnescapedCharacter {
    //http://nshipster.cn/nscharacterset/
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];//获取那些特殊字符
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    NSRange range = [mutableString rangeOfCharacterFromSet:controlChars];//寻找字符串中有没有这些特殊字符\
    
    while (range.location != NSNotFound) {
        
        [mutableString deleteCharactersInRange:range];
        range = [mutableString rangeOfCharacterFromSet:controlChars];
        
    }
    
    return mutableString;
    
}

@end
