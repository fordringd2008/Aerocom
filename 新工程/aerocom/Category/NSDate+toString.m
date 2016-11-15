//
//  NSDate+toString.m
//  FitTu
//
//  Created by apple on 15/4/11.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "NSDate+toString.h"


@implementation NSDate (toString)

/**
 *  时间格式转化  把时间转化成需要的格式
 *
 *  @param stringType 格式  例如： @“YYYY-MM-DD”
 *
 *  @return 字符串
 */
- (NSString *)toString:(NSString *)stringType
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:stringType];
    NSString *locationString=[dateformatter stringFromDate:self];
    return locationString;
}

- (NSString *)toString
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:self];
    return locationString;
}

/**
 *  从日期中抽取 需要的 年，月，日，小时，分钟，秒，星期
 *
 *  @param type 1年 2月  3日   4小时 5分钟 6秒  7星期
 *
 *  @return int
 */
-(NSInteger)getFromDate:(int)type
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:self];
    switch (type) {
        case 1:
            return [comps year];
            break;
        case 2:
            return [comps month];
            break;
        case 3:
            return [comps day];
            break;
        case 4:
            return [comps hour];
            break;
        case 5:
            return [comps minute];
            break;
        case 6:
            return [comps second];
            break;
        case 7:
            return ([comps weekday] - 1);
            break;
        default:
            break;
    }
    return 0;
}

/**
 *  把任意时区的日期转换为现在的时区
 *
 *  @param anyDate 任意
 *
 *  @return 当前时区的时间
 */
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate] ;
    return destinationDateNow;
}



@end
