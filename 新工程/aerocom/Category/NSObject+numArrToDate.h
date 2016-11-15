//
//  NSObject+numArrToDate.h
//  aerocom
//
//  Created by 丁付德 on 15/7/2.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (numArrToDate)

/**
 *  时间数组 转化成 时间
 *
 *  @param anyDate 任意
 *
 *  @return 当前时区的时间
 */
- (NSDate *)getDateFromInt:(NSMutableArray *)arr;

@end
