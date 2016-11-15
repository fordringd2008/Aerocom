//
//  NSObject+Delay.h
//  aerocom
//
//  Created by 丁付德 on 15/7/1.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Delay)

#pragma mark  延迟执行 延迟的时间：秒
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;

#pragma mark  在主线程执行  用于非主线程中更新UI
- (void)performBlockInMain:(void(^)())block;

- (void)performBlockInMain:(void(^)())block afterDelay:(NSTimeInterval)delay;

#pragma mark  转入全局非主线程执行
- (void)performBlockInGlobal:(void(^)())block;

#pragma mark  获取系统版本
- (CGFloat)getIOSVersion;

#pragma mark  获取app名称
- (NSString *)getIOSName;

#pragma mark  延迟执行 (在当前的线程) 延迟的时间：秒
- (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay;

#pragma mark  获取导航栏 左右按钮 frame
- (CGRect)getNavFrame;

#pragma mark  获取当前语言环境   1： 中文  2 ： 英文  3：  法文
- (NSInteger)getPreferredLanguage;

#pragma mark  获取当前语言环境   zh： 中文  en ： 英文  fr：  法文
- (NSString *)getPreferredLanguageStr;

#pragma mark  从json文件读取数据  花草类别数据
-(NSData *)getFlowerTypeDataFromJSON;

#pragma mark 获取是否允许通知
- (BOOL)isAllowedNotification;

#pragma mark   从json文件读取国家地区数据
-(NSData *)getCountiesAndCitiesrDataFromJSON;


#pragma mark  获取图片数据的图片格式
- (NSString *)typeForImageData:(NSData *)data;

#pragma mark  对NSSet进行排序
- (NSMutableArray *)setNSDestByOrder:(NSSet *)set orderStr:(NSString *)orderStr ascending:(BOOL)ascending;

#pragma mark  摄氏温度转化成华氏温度
-(NSInteger)cTof:(NSInteger)c;

#pragma mark  从coreData中获取读片 （  ）
-(UIImage *)getImageFromCoreData:(NSString *)name;


-(BOOL)saveImageToDocoment:(NSData *)imageData name:(NSString *)name;

#pragma mark   获取Cache目录
-(NSString *)getCacheURL;

#pragma mark  获取document目录
-(NSString *)getDomentURL;

#pragma mark  取得指定目录下的所有文件名
-(NSArray *)getFileNamesFromURL:(NSString *)url;

-(UIImage *)getImageFromName:(NSString *)name;

#pragma mark   返回年的天数
-(int)yearDay:(int)year;

// 判断是否是闰年
-(BOOL)isLeapYear:(int)year;

// 根据月份获得这个月的所有天的集合
-(NSMutableArray *)getXarrList:(NSInteger)year month:(NSInteger)month;

// 把时间间隔转化成日期数组
- (NSMutableArray *)HmF2KIntToDate:(NSInteger)data;

// 把日期数组转化成时间间隔
-(int)HmF2KDateToInt:(NSMutableArray *)array;

#pragma mark  把从时间(datevalue)获取 当天的时间
-(NSDate *)getDateTimeFormDateValue:(int)timeValue;

// 把日期数组转化成时间间隔
-(int)HmF2KNSDateToInt:(NSDate *)date;

// 获得具体的月 的有多少天
- (NSInteger)getDaysByYearAndMonth:(NSInteger)year_ month:(NSInteger)month_;

//  dic  -- >  str
- (NSString*)dictionaryToJson:(NSDictionary *)dic;

// 把末尾的 0 过滤掉  如果都是 0 返回空的数组
-(NSMutableArray *)filterArr:(NSMutableArray *)arr;

// 检查当前系统时间是否是24小时制
-(BOOL)isSysTime24;

// 把复杂的数据集合 转化成json字符串  为上传使用
-(NSString *)toJsonStringForUpload:(NSObject *)obj;

#pragma mark  删除本地通知 根据userinfo中是否还有 name    name为nil时 删除所有
-(void)clearNotification:(NSString *)name;

-(void)addLocalNotification:(NSDate *)date repeat:(NSCalendarUnit)repeat soundName:(NSString *)soundName alertBody:(NSString *)alertBody applicationIconBadgeNumber:(NSInteger)applicationIconBadgeNumber userInfo:(NSDictionary *)userInfo;

@end
