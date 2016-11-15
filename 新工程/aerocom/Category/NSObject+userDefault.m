//
//  NSObject+userDefault.m
//  aerocom
//
//  Created by 丁付德 on 15/6/30.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "NSObject+userDefault.h"

@implementation NSObject (userDefault)



/**
 *  保存到userDefault
 *
 *  @param value 保存的值
 *  @param key   键
 */
-(void)setUserDefault:(id)value key:(NSString *)key
{
    NSUserDefaults *userDefafault = [NSUserDefaults standardUserDefaults];
    [userDefafault setObject:value forKey:key];
    [userDefafault synchronize];
    
}

/**
 *  从userDefault取值
 *
 *  @param key 键
 *
 *  @return 保存的值
 */
-(id)getUserDefalut:(NSString *)key
{
    NSUserDefaults *userDefafault = [NSUserDefaults standardUserDefaults];
    id value = [userDefafault objectForKey:key];
    return value;
}

-(void)removeUserDefault:(NSString *)key
{
    NSUserDefaults *userDefafault = [NSUserDefaults standardUserDefaults];
    [userDefafault removeObjectForKey:key];
    [userDefafault synchronize];
}


@end
