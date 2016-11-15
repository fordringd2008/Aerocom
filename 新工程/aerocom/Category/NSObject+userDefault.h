//
//  NSObject+userDefault.h
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (userDefault)

/**
 *  保存到userDefault
 *
 *  @param value 保存的值
 *  @param key   键
 */
-(void)setUserDefault:(id)value key:(NSString *)key;

/**
 *  从userDefault取值
 *
 *  @param key 键
 *
 *  @return 保存的值
 */
-(id)getUserDefalut:(NSString *)key;

// 移除
-(void)removeUserDefault:(NSString *)key;

@end
