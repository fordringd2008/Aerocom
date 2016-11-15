//
//  BLEManager+Helper.h
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager.h"

@interface BLEManager (Helper)


// 验证数据是否正确
-(BOOL)checkData:(NSData *)data;

// 拼装204数据
-(NSArray *)set204Data:(NSMutableArray *)array uuid:(NSString *)uuid;

//int数组 拼写字符串
-(NSString *)intArrayToString:(int[])arr length:(int)length;

// int数组， 返回非0的平均值
-(int)intArrayToAVG:(int[])arr length:(int)length;

// 同上
-(int)intArrayToAVGByStr:(NSString *)str;

-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;

// 验证 屏蔽标示符，返回屏蔽的天数的索引的集合
-(NSMutableArray *)isAllShield:(NSData *)data;

// 同步结束后， 根据昨天的数据 写入提醒表
-(void)writeDataInRemind:(NSString *)uuid;

// 获取这个植物那天的得分
-(NSNumber *)getScore:(SyncDate *)syn;

// 获取在数组中最大的那个值的索引  （数组中为NSNumber）
-(NSInteger)getBiggestIndexInArray:(NSMutableArray *)array;

@end
