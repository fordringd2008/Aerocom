//
//  NSObject+userInfo.h
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (userInfo)

// 获取当前用户
- (id)getUserInfo;

// 清除当前用户，退出时使用
+(void)returnUserNil;

@end
