//
//  NSString+toDate.m
//  aerocom
//
//  Created by 丁付德 on 15/7/1.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "NSString+toDate.h"
#import "NSObject+numArrToDate.h"

@implementation NSString (toDate)


- (NSDate *)toDate
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSDate *currentDate = [dateFormater dateFromString:self];
    return currentDate;
}

- (NSDate *)toDate: (NSString *)intString
{
    int year = [[intString substringWithRange:NSMakeRange(0, 4)] intValue];
    int month = [[intString substringWithRange:NSMakeRange(4, 2)] intValue];
    int day = [[intString substringWithRange:NSMakeRange(6, 2)] intValue];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:year], [NSNumber numberWithInt:month], [NSNumber numberWithInt:day], nil];
    
    NSDate *date = [self getDateFromInt:arr];
    if (!date) {
        NSLog(@"尼玛  日期错误啦 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        return [NSDate date];
    }
    return  date;
}

@end
