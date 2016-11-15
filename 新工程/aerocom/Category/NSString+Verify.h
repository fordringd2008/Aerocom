//
//  NSString+Verify.h
//  EShoping
//
//  Created by Seven on 14-11-29.
//  Copyright (c) 2014年 FUEGO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Verify)

-(BOOL)isEmailType;
-(BOOL)isPhone;

// 是否为中文    (要求str长度为1)
-(BOOL)isChines:(NSString *)str;

// 获取字符串的长度，中文算2个
+(NSInteger)getLength:(NSString *)str;

// 检测文本中是否含有emoji
+ (BOOL)isHaveEmoji:(NSString *)string;
@end
