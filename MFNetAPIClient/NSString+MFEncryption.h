//
//  NSString+MFEncryption.h
//  MFProjectTemplate
//
//  Created by 房志刚 on 1/28/16.
//  Copyright © 2016 COM.MEIGAN.MFProjectTemplate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MFEncryption)

- (NSString *)mf_encryptWithItems:(NSString *)firstItem, ... NS_REQUIRES_NIL_TERMINATION;

@end
