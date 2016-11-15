//
//  NSObject+Delay.m
//  aerocom
//
//  Created by 丁付德 on 15/7/1.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "NSObject+Delay.h"
#import "NSDate+toString.h"

@implementation NSObject (Delay)

/**
 *  延迟执行
 *
 *  @param block 执行的block
 *  @param delay 延迟的时间：秒
 */
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

// 在主线程执行  用于非主线程中更新UI
- (void)performBlockInMain:(void(^)())block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)performBlockInMain:(void(^)())block afterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)performBlockInGlobal:(void(^)())block
{
    dispatch_queue_t centralQueue = dispatch_queue_create("com.xinyi.Coasters", DISPATCH_QUEUE_SERIAL);
    dispatch_async(centralQueue, ^{block();});
}

/**
 *  延迟执行 (在当前的线程)
 *
 *  @param block 执行的block
 *  @param delay 延迟的时间：秒
 */
- (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (CGFloat)getIOSVersion
{
    //NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];    //获取项目名称
    
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];      //获取项目版本号
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    //NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    //NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [app_Version doubleValue];
}

- (NSString *)getIOSName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return app_Name;
}


- (CGRect)getNavFrame
{
    return CGRectMake(0, 0, 25, 25);
    if (ScreenWidth == 320)
    {
        return CGRectMake(0, 0, 25, 25);
    }
}

- (NSInteger)getPreferredLanguage
{
    NSInteger langIn = [(NSNumber *)GetUserDefault(CurrentLanguage) integerValue];
    if (langIn) {
        return langIn;
    }
    
    NSArray * allLanguages = GetUserDefault(@"AppleLanguages");
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    //NSLog(@"当前语言:%@", preferredLang);
    
    NSString *pre = [preferredLang substringWithRange:NSMakeRange(0, 2)];
    if ([pre isEqualToString:@"zh"]) {
        langIn = 1;
    }
    else if([pre isEqualToString:@"en"])
    {
        langIn =  2;
    }
    else if([pre isEqualToString:@"fr"])
    {
        langIn =  3;
    }
    //SetUserDefault(CurrentLanguage, @(langIn));
    return langIn;
}

- (NSString *)getPreferredLanguageStr
{
    NSInteger lang = [self getPreferredLanguage];
    NSString *lanStr = @"";
    switch (lang) {
        case 1:
            lanStr = @"zh";
            break;
        case 2:
            lanStr = @"en";
            break;
        case 3:
            lanStr = @"fr";
            break;
            
        default:
            break;
    }
    return lanStr;
}

-(NSData *)getCountiesAndCitiesrDataFromJSON
{
    NSInteger langIndex =  [self getPreferredLanguage];
    NSString *jsonName = @"";
    switch (langIndex) {
        case 1:
        jsonName = @"city_zh";
        break;
        case 2:
        jsonName = @"city_en";
        break;
        case 3:
        jsonName = @"city_fr";
        break;
        
        default:
        break;
    }
//#warning ---------------- FIXME for Language 这里等百科数据中的英文和法文翻译后，注释
    jsonName = @"city_zh";
    NSData *data = [self getDataFromJSON:jsonName];
    return data;
}

-(NSData *)getFlowerTypeDataFromJSON
{
    NSInteger langIndex =  [self getPreferredLanguage];
    NSString *jsonName = @"";
    switch (langIndex) {
        case 1:
        jsonName = @"flowers_zh";
        break;
        case 2:
        jsonName = @"flowers_en";
        break;
        case 3:
        jsonName = @"flowers_fr";
        break;
        
        default:
        break;
    }
//#warning ----------------  FIXME for Language 这里等百科数据中的英文和法文翻译后，注释
    jsonName = @"flowers_zh";
    NSData *data = [self getDataFromJSON:jsonName];
    return data;
}

- (BOOL)isAllowedNotification
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8)
    {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types)
        {
            return YES;
        }
    }
    else
    {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type)
            return YES;
    }
    return NO;
}

-(NSData *)getDataFromXML:(NSString *)name
{
    NSString *address = [NSString stringWithFormat:@"%@", name];
    NSString *path = [[NSBundle mainBundle]  pathForResource:address ofType:@"xml"];
    //NSLog(@"path:%@",path);
    //NSData *jdata = [[NSData alloc] initWithContentsOfFile:path ];
    //NSLog(@"length:%lu",(unsigned long)[jdata length]);
    //NSError *error = nil;
    NSData * adata = [[NSData alloc] initWithContentsOfFile:path];
    return adata;
}

-(NSData *)getDataFromJSON:(NSString *)name
{
    NSString *address = [NSString stringWithFormat:@"%@", name];
    NSString *path = [[NSBundle mainBundle]  pathForResource:address ofType:@"json"];
    //NSLog(@"path:%@",path);
    NSData *jdata = [[NSData alloc] initWithContentsOfFile:path ];
    //NSLog(@"length:%lu",(unsigned long)[jdata length]);
    NSError *error = nil;
    if (jdata) {
        NSData * adata = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
        return adata;
    }
    return nil;
}

- (NSString *)typeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
        return @"image/jpeg";
        case 0x89:
        return @"image/png";
        case 0x47:
        return @"image/gif";
        case 0x49:
        case 0x4D:
        return @"image/tiff";
    }
    return nil;
}


- (NSMutableArray *)setNSDestByOrder:(NSSet *)set orderStr:(NSString *)orderStr ascending:(BOOL)ascending
{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:orderStr ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
    NSMutableArray *arrResult = [[set sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    return arrResult;
}

-(NSInteger)cTof:(NSInteger)c
{
    // 华氏度 = 32 + 摄氏度 × 1.8
    double fD = 32 + c * 1.8;
    return (int)fD;
}


-(UIImage *)getImageFromCoreData:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *imageFilePath = [path stringByAppendingPathComponent:name];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
    UIImage *img = [UIImage imageWithData:imageData];
    return img;
}


-(BOOL)saveImageToDocoment:(NSData *)imageData name:(NSString *)name
{
    NSString *norPicPath = [self dataPath:name];
    //NSLog(@"filepath: %@",norPicPath);
    
    BOOL norResult = [imageData writeToFile:norPicPath atomically:YES];
    if (norResult) {
        return YES;
    }else {
        NSLog(@"图片保存不成功");
        return NO;
    }
}

- (NSString *)dataPath:(NSString *)file
{
//    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"/"];
    NSString *path = [[self getDomentURL] stringByAppendingPathComponent:@"/"];
    //NSString *getDome = [self getDomentURL];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    BOOL bo;
//    bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    NSLog(@"%%@",bo);
    NSString *result = [path stringByAppendingPathComponent:file];
    return result;
}


-(NSString *)getCacheURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

-(NSString *)getDomentURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}


-(NSArray *)getFileNamesFromURL:(NSString *)url
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:url error:nil]];
    return tempFileList;
}


-(UIImage *)getImageFromName:(NSString *)name
{
    UIImage *img = [UIImage imageNamed:name];
    if (!img) {
        NSString *strAAA = [NSString stringWithFormat:@"%@/%@", [self getDomentURL], name];
        img = [UIImage imageNamed:strAAA];
    }
    return img;
}

// 返回年的天数
-(int)yearDay:(int)year
{
    int yearlength=0;
    if([self isLeapYear:year]){
        yearlength=366;
    }else{
        yearlength=365;
    }
    return yearlength;
}

// 判断是否是闰年
-(BOOL)isLeapYear:(int)year
{
    return ((year%4==0)&&(year%100!=0))||(year%400==0);
}


-(NSMutableArray *)getXarrList:(NSInteger)year month:(NSInteger)month;
{
    NSInteger count = [self getDaysByYearAndMonth: year month: month];

    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < count; i++)
        [arr addObject:[NSString stringWithFormat:@"%d", i + 1]];
    return arr;
}


- (NSMutableArray *)HmF2KIntToDate:(NSInteger)data
{
    int times[3];
    times[0]=2000;
    
    while ( data >= [self yearDay:times[0]])
    {
        data-= [self yearDay:times[0]];
        times[0]++;
    }
    
    times[1]=0;
    
    while ( data >= [self monthDays:times[0] month:times[1]])
    {
        data -= [self monthDays:times[0] month:times[1]];
        times[1]++;
    }
    
    times[2]=(int)data;
    NSMutableArray *arr = [NSMutableArray new];
    
    
    [arr addObject:@(times[0])];
    
    [arr addObject:@(++times[1])];
    
    [arr addObject:@(++times[2])];
    return arr;
}



-(int)HmF2KDateToInt:(NSMutableArray *)array
{
    int date= [((NSNumber *)array[2]) intValue] - 1;
    int month =  [((NSNumber *)array[1]) intValue] - 1;;
    int year = [((NSNumber *)array[0]) intValue];
    while ( --month >= 0 )
    {
        date += [self monthDays:year month:month];
    }
    while ( --year >= 2000 )
    {
        date += [self yearDay:year];
    }
    return date;
}

-(int)HmF2KNSDateToInt:(NSDate *)date
{
    NSMutableArray *arr = [NSMutableArray new];
    NSInteger year = [date getFromDate:1];
    NSInteger month = [date getFromDate:2];
    NSInteger day = [date getFromDate:3];
    
    [arr addObject:@(year)];
    [arr addObject:@(month)];
    [arr addObject:@(day)];
    
    int dateValue = [self HmF2KDateToInt:arr];
    return dateValue;
}


- (int)monthDays:(int)year month:(int)month
{
    int days = 31;
    if ( month == 1 ) 		//	feb
    {
        days=28;
        if([self isLeapYear:year]){
            days+=1;
        }
    }
    else
    {
        if ( month > 6 )		//	8月->7月	 9月->8月...
        {
            month--;
        }
        int s = month&1;
        if (s==1)
        {
            days--;			//	30天
        }
    }
    return days;
}

// 把从时间(datevalue)获取 当天的时间
-(NSDate *)getDateTimeFormDateValue:(int)timeValue
{
    NSDate *now = [NSDate date];
    NSInteger year = [now getFromDate:1];
    NSInteger month = [now getFromDate:2];
    NSInteger day = [now getFromDate:3];
    
    NSMutableArray *arrDate6 = [NSMutableArray arrayWithObjects:@(year), @(month), @(day), nil];
    NSMutableArray *arr_3 = [self getHourMinuteSecondFormDateValue:timeValue];
    [arrDate6 addObjectsFromArray:arr_3];
    NSDate *date = [self getDateFromInt:arrDate6];
    return date;
}

-(NSMutableArray *)getHourMinuteSecondFormDateValue:(int)timeValue
{
    int hour = timeValue / 1800;
    int minute = (timeValue - hour * 1800) / 30;
    int second = timeValue - hour * 1800 - minute * 30;
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@(hour), @(minute), @(second), nil];
    return arr;
}

- (NSInteger)getDaysByYearAndMonth:(NSInteger)year_ month:(NSInteger)month_
{
    NSInteger count = 0;
    if (month_ == 4 || month_ == 6 || month_ == 9 || month_ == 11)
    {
        count = 30;
    }
    else if (month_ == 2)
    {
        if ([self isLeapYear:(int)year_])
            count = 29;
        else
            count = 28;
    }
    else
        count = 31;
    return  count;
}

//  dic  -- >  str
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// 把末尾的 0 过滤掉  如果都是 0 返回空的数组
-(NSMutableArray *)filterArr:(NSMutableArray *)arr
{
    NSMutableArray *arrNew = [NSMutableArray new];
    NSMutableArray* reversedArray = [[[arr reverseObjectEnumerator] allObjects] mutableCopy];
    
    BOOL isNotFi = NO;
    for (int i = 0; i < arr.count; i++)
    {
        NSString *st = reversedArray[i];
        if ([st integerValue] || isNotFi)
        {
            [arrNew addObject:st];
            isNotFi = YES;
        }
        else
        {
            isNotFi = NO;
        }
    }
    NSMutableArray *resultArr = [[[arrNew reverseObjectEnumerator] allObjects] mutableCopy];
    return resultArr;
}

// 检查当前系统时间是否是24小时制
-(BOOL)isSysTime24
{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    return !hasAMPM;
}


-(NSString *)toJsonStringForUpload:(NSObject *)obj
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\r\n" withString : @""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\n" withString : @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\t" withString : @"" ];
    jsonString = [jsonString stringByReplacingOccurrencesOfString : @"\\" withString : @"" ];
    return jsonString;
}

-(void)clearNotification:(NSString *)name
{
    if(name)
    {
        NSArray *arrNotification =[[UIApplication sharedApplication] scheduledLocalNotifications];
        for(int i = 0; i  < arrNotification.count ; i++)
        {
            UILocalNotification *not = arrNotification[i];
            if (not.userInfo && [not.userInfo.allKeys containsObject:name])
                [[UIApplication sharedApplication] cancelLocalNotification:not];
        }
    }
    else
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)addLocalNotification:(NSDate *)date repeat:(NSCalendarUnit)repeat soundName:(NSString *)soundName alertBody:(NSString *)alertBody applicationIconBadgeNumber:(NSInteger)applicationIconBadgeNumber userInfo:(NSDictionary *)userInfo
{
    UILocalNotification *notifi = [[UILocalNotification alloc]init];
    notifi.repeatInterval = repeat ;
    //    notifi.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];   // 测试 10秒之后
    notifi.fireDate = date;
    notifi.timeZone= [NSTimeZone defaultTimeZone];
    notifi.soundName = soundName;//UILocalNotificationDefaultSoundName;
    notifi.alertBody = alertBody; //kString(@"美好的一天,从清晨的第一杯水开始");
    notifi.applicationIconBadgeNumber = applicationIconBadgeNumber;
    notifi.userInfo = userInfo;//dic;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        notifi.repeatInterval = NSCalendarUnitDay;
    } else
        notifi.repeatInterval = NSDayCalendarUnit;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notifi];
}

- (NSDate *)getDateFromInt:(NSMutableArray *)arr
{
    NSDate *date;
    if (arr.count == 3)
    {
        NSNumber *year = arr[0];
        NSNumber *month = arr[1];
        NSNumber *day = arr[2];
        NSString *strYear = [NSString stringWithFormat:@"%@", year];
        NSString *strMonth = [month integerValue] < 10 ? [NSString stringWithFormat:@"0%@", month] : [NSString stringWithFormat:@"%@", month];
        NSString *strDay = [day integerValue] < 10 ? [NSString stringWithFormat:@"0%@", day] : [NSString stringWithFormat:@"%@", day];
        
        NSString *strDate = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00 000", strYear, strMonth, strDay];
        //        date = [strDate toDate];
        date = [self toDateByString:strDate];
    }
    else if(arr.count == 6)
    {
        NSNumber *year = arr[0];
        NSNumber *month = arr[1];
        NSNumber *day = arr[2];
        NSNumber *hour = arr[3];
        NSNumber *minute = arr[4];
        NSNumber *second = arr[5];
        NSString *strYear = [NSString stringWithFormat:@"%@", year];
        NSString *strMonth = [month integerValue] < 10 ? [NSString stringWithFormat:@"0%@", month] : [NSString stringWithFormat:@"%@", month];
        NSString *strDay = [day integerValue] < 10 ? [NSString stringWithFormat:@"0%@", day] : [NSString stringWithFormat:@"%@", day];
        NSString *strHour = [hour integerValue] < 10 ? [NSString stringWithFormat:@"0%@", hour] : [NSString stringWithFormat:@"%@", hour];
        NSString *strMinute = [minute integerValue] < 10 ? [NSString stringWithFormat:@"0%@", minute] : [NSString stringWithFormat:@"%@", minute];
        NSString *strSecond = [second integerValue] < 10 ? [NSString stringWithFormat:@"0%@", second] : [NSString stringWithFormat:@"%@", second];
        
        NSString *strDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ 000", strYear, strMonth, strDay, strHour, strMinute , strSecond];
        //date = [strDate toDate];
        date = [self toDateByString:strDate];
    }
    else if(arr.count == 4)         //  小时  分  秒      这个不关心年月日
    {
        NSDate *now = [NSDate date];
        NSNumber *year = @([now getFromDate:1]);
        NSNumber *month = @([now getFromDate:2]);
        NSNumber *day = @([now getFromDate:3]);
        NSNumber *hour = arr[0];
        NSNumber *minute = arr[1];
        NSNumber *second = arr[2];
        NSString *strYear = [NSString stringWithFormat:@"%@", year];
        NSString *strMonth = [month integerValue] < 10 ? [NSString stringWithFormat:@"0%@", month] : [NSString stringWithFormat:@"%@", month];
        NSString *strDay = [day integerValue] < 10 ? [NSString stringWithFormat:@"0%@", day] : [NSString stringWithFormat:@"%@", day];
        
        NSString *strHour = ([hour integerValue] < 10) ? [NSString stringWithFormat:@"0%@", hour] : [NSString stringWithFormat:@"%@", hour];
        NSString *strMinute = [minute integerValue] < 10 ? [NSString stringWithFormat:@"0%@", minute] : [NSString stringWithFormat:@"%@", minute];
        NSString *strSecond = [second integerValue] < 10 ? [NSString stringWithFormat:@"0%@", second] : [NSString stringWithFormat:@"%@", second];
        
        NSString *strDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ 000", strYear, strMonth, strDay, strHour, strMinute , strSecond];
        //date = [strDate toDate];
        date = [self toDateByString:strDate];
    }
    return  date;
}

-(NSDate *)toDateByString:(NSString *)string
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    return [dateFormater dateFromString:string];
}



@end
