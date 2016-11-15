//
//  BLEManager+Helper.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager+Helper.h"

@implementation BLEManager (Helper)


// 验证数据是否正确
-(BOOL)checkData:(NSData *)data
{
    if (!data) {
        return  NO;
    }
    NSUInteger count = data.length;
    Byte *bytes = (Byte *)data.bytes;
    int sum = 0;
    
    for (int i = 1; i < count - 1; i++) {
        sum += (bytes[i]) ^ i;
    }
    BOOL isTrue = (sum & 0xFF) == bytes[count - 1];
    return isTrue;
}

// 拼装204数据
-(NSArray *)set204Data:(NSMutableArray *)array uuid:(NSString *)uuid
{
    NSData *data;
    char bytes[19];
    bytes[0] = DataFirst;
    bytes[1] = DataOOOO;
    
    //NSMutableArray *arrShield = [NSMutableArray new];
    
    NSMutableArray *arr = array[0];
    NSMutableArray *arrCount = array[2];
    
    for (int i = 0; i < arr.count; i++)
    {
        NSNumber *fl_ID = ((FlowerData *)[FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bind_device_mac == %@ and access == %@", uuid, myUserInfo.access] inContext:DBefaultContext]).my_plant_id;
        
        NSArray *arrFromLoacal = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@ and sub = 5 and my_plant_id == %@", myUserInfo.access,  arr[i], fl_ID] inContext:DBefaultContext];
        // 默认是读取
        NSUInteger dateValue = [((NSNumber *)arr[i]) integerValue];
        char byte_low = dateValue & 0xFF;
        char byte_hight = ( dateValue >> 8 ) & 0xFF;
        
        if (arrFromLoacal.count > 0)
        {
            SyncDate *syn = arrFromLoacal[0];
            NSUInteger dataCountFromBL = [((NSNumber *)arrCount[i]) integerValue];
            NSUInteger dataCountFromLocal =  [syn.count integerValue];
            if (dataCountFromBL == dataCountFromLocal)
            {
                byte_low = byte_hight = DataOOOO;
            }
        }
        
        bytes[i * 2 + 2] = byte_low;
        bytes[i * 2 + 3] = byte_hight;
    }
    
    
    int sum = 0;
    for (int i = 1; i < 18; i++) {
        sum += (bytes[i]) ^ i;
    }
    bytes[18] = sum & 0xFF;
    
    data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    NSArray *arrResult = [[NSArray alloc] initWithObjects:data, nil];
    
    return arrResult;
}



-(NSString *)intArrayToString:(int[])arr length:(int)length;
{
    NSMutableString *strResult = [NSMutableString new];
    for (int i = 0; i < length; i++) {
        NSString *str = [NSString stringWithFormat:@"%d", arr[i]];
        [strResult appendString:str];
        if (i != length - 1) {
            [strResult appendString:@","];
        }
    }
    return strResult;
}

-(int)intArrayToAVG:(int[])arr length:(int)length
{
    int sum = 0;
    int count = 0;
    for (int i = 0; i < length; i++) {
        if (arr[i] != 0) {
            count++;
            sum += arr[i];
        }
    }
    int avg = sum / count;
    return avg;
}

-(int)intArrayToAVGByStr:(NSString *)str
{
    if (!str)return 0;
    int sum = 0;
    int count = 0;
    NSArray *arr = [str componentsSeparatedByString:NSLocalizedString(@",", nil)];
    for (int i = 0; i < arr.count; i++) {
        if (arr[i] != 0) {
            count++;
            sum += [arr[i] intValue];
        }
    }
    
    int avg = sum / count;
    return avg;
}


-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;
{
    BOOL isHas = NO;
    for (int i = 0; i < length; i++) {
        if (arr[i] == value) {
            isHas = YES;
            break;
        }
    }
    return isHas;
}

-(NSMutableArray *)isAllShield:(NSData *)data;
{
    NSInteger length = data.length;
    Byte *byte = (Byte *)data.bytes;
    NSMutableArray *arr = [NSMutableArray new];
    for(int i = 2; i < length - 1; i = i + 2)
    {
        if (byte[i] == 0x00 && byte[i] == 0x00)
        {
            [arr addObject:@( i / 2 - 1)];
        }
    }
    return arr;
}

-(void)writeDataInRemind:(NSString *)uuid
{
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
//    {
//        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:- 24 * 60 * 60];
//        int dateValue = [self HmF2KNSDateToInt:yesterday];
//        SyncDate *syn = [SyncDate findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@ and sub == 5", myUserInfo.access, @(dateValue)] inContext:localContext];
//        if (!syn) {
//            return;
//        }
//        
//        // 所属的植物
//        FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and bind_device_mac == %@", myUserInfo.access, uuid] inContext:localContext];
//        // 所属的分类
//        FlowerType *ft = [FlowerType findFirstByAttribute:@"iD" withValue:fd.plant_id inContext:localContext];
//        
//        NSMutableArray *arrUpdate = [NSMutableArray new];
//        
//        NSArray *arrAlarm = [fd.alarm_set componentsSeparatedByString:@"-"];                //  1-1-1-1
//        arrAlarm = arrAlarm.count < 4 ? @[@"1",@"1",@"1",@"1"] : arrAlarm;// 坑爹的江华
//        Remind *rdLight = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '02' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:localContext];
//        if (!rdLight && [arrAlarm[0] boolValue])
//        {
//            NSInteger light_TimeLow = [ft.light_lowest_time integerValue];      // 最短 光照小时数
//            NSInteger light_TimeHight = [ft.light_highest_time integerValue];   // 最长 光照小时数
//            
//            NSInteger light_Low = ([ft.light integerValue] - 1) * 20;                 // 光照 强度 最低
//            //NSInteger light_Hight = [ft.light integerValue] * 20;                     // 光照 强度 最高
//            
//            BOOL isCreate = YES;
//            int timesOK = 0;
//            NSArray *arrLight = [syn.light componentsSeparatedByString:@","];
//            for (int i = 0; i < 24; i++)
//            {
//                NSInteger lightHour = [arrLight[i] integerValue];
//                if (lightHour > light_Low)      ///  && lightHour < light_Hight
//                    timesOK ++;
//            }
//            if (timesOK >= light_TimeLow && timesOK <= light_TimeHight)
//            {
//                isCreate = NO;
//                NSLog(@"光照正常");
//            }
//            
//            if (isCreate)
//            {
//                NSString * alarm_sub_type = @"";
//                if (timesOK < light_TimeLow)
//                    alarm_sub_type = @"00";
//                else if(timesOK > light_TimeHight)
//                    alarm_sub_type = @"01";
//                
//                rdLight = [Remind MR_createEntityInContext:localContext];
//                rdLight.access = myUserInfo.access;
//                rdLight.alarm_type = @"02";
//                rdLight.k_date = @(dateValue);
//                rdLight.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
//                rdLight.alarm_sub_type = alarm_sub_type;
//                rdLight.isUpload = @(NO);
//                DLSave
//                DBSave;
//                
//                if(![fd.my_plant_id_T integerValue])                                 //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                    [arrUpdate addObject:rdLight];
//            }
//        }
//        
//        Remind *rdTemp = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '03' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:localContext];
//        if(!rdTemp && [arrAlarm[1] boolValue])
//        {
//            NSInteger temp_lowEST = [ft.temperatureLowEST integerValue];          // 极限最低
//            NSInteger temp_low = [ft.temperatureLow integerValue];                // 低
//            NSInteger temp_hight = [ft.temperatureHeight integerValue];           // 高
//            NSInteger temp_hightEST = [ft.temperatureHeightEST integerValue];     // 极限最高
//            
//            NSString *alarm_sub_type = @"";
//            BOOL isCreate = YES;
//            NSInteger tempInt = [syn.mean_ambienttem integerValue] ? [syn.mean_ambienttem integerValue] - 50 : 0;
//            if (tempInt <= temp_lowEST)
//                alarm_sub_type = @"00";
//            else if (tempInt > temp_lowEST && tempInt < temp_low)
//                alarm_sub_type = @"01";
//            else if (tempInt > temp_hight && tempInt < temp_hightEST)
//                alarm_sub_type = @"02";
//            else if (tempInt >= temp_hightEST)
//                alarm_sub_type = @"03";
//            else
//            {
//                isCreate = NO;
//                NSLog(@"温度正常");
//            }
//            
//            if (isCreate)
//            {
//                rdTemp = [Remind MR_createEntityInContext:localContext];
//                rdTemp.access = myUserInfo.access;
//                rdTemp.alarm_type = @"03";
//                rdTemp.k_date = @(dateValue);
//                rdTemp.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
//                rdTemp.alarm_sub_type = alarm_sub_type;
//                rdTemp.isUpload = @(NO);
//                DLSave
//                DBSave;
//                
//                if(![fd.my_plant_id_T integerValue])                                 //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                    [arrUpdate addObject:rdTemp];
//            }
//        }
//        
//        Remind *rdSoil = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '04' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:localContext];
//        if(!rdSoil && [arrAlarm[3] boolValue])
//        {
//            NSInteger soil_Low = ([ft.soli integerValue] - 1) * 20;                 // 湿度 最低
//            NSInteger soil_Hight = [ft.soli integerValue] * 20;                     // 湿度 最高
//            
//            NSString *alarm_sub_type = @"";
//            BOOL isCreate = YES;
//            NSInteger soilInt = [syn.mean_solimois integerValue];
//            if (soilInt < soil_Low)
//                alarm_sub_type = @"00";
//            else if (soilInt > soil_Hight)
//                alarm_sub_type = @"01";
//            else
//            {
//                isCreate = NO;
//                NSLog(@"湿度正常");
//            }
//            
//            if (isCreate)
//            {
//                rdSoil = [Remind MR_createEntityInContext:localContext];
//                rdSoil.access = myUserInfo.access;
//                rdSoil.alarm_type = @"04";
//                rdSoil.k_date = @(dateValue);
//                rdSoil.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
//                rdSoil.alarm_sub_type = alarm_sub_type;
//                rdSoil.isUpload = @(NO);
//                DLSave
//                DBSave;
//                
//                if(![fd.my_plant_id_T integerValue])                                 //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                    [arrUpdate addObject:rdSoil];
//            }
//        }
//        [self.delegate CallBack_Data:301 uuidString:uuid obj:arrUpdate];
//    }];
    
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:- 24 * 60 * 60];
    int dateValue = [self HmF2KNSDateToInt:yesterday];
    SyncDate *syn = [SyncDate findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@ and sub == 5", myUserInfo.access, @(dateValue)] inContext:DBefaultContext];
    if (!syn) {
        return;
    }
    
    // 所属的植物
    FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and bind_device_mac == %@", myUserInfo.access, uuid] inContext:DBefaultContext];
    // 所属的分类
    FlowerType *ft = [FlowerType findFirstByAttribute:@"iD" withValue:fd.plant_id inContext:DBefaultContext];
    
    NSMutableArray *arrUpdate = [NSMutableArray new];
    
    NSArray *arrAlarm = [fd.alarm_set componentsSeparatedByString:@"-"];                //  1-1-1-1
    arrAlarm = arrAlarm.count < 4 ? @[@"1",@"1",@"1",@"1"] : arrAlarm;// 坑爹的江华
    Remind *rdLight = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '02' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:DBefaultContext];
    if (!rdLight && [arrAlarm[0] boolValue])
    {
        NSInteger light_TimeLow = [ft.light_lowest_time integerValue];      // 最短 光照小时数
        NSInteger light_TimeHight = [ft.light_highest_time integerValue];   // 最长 光照小时数
        
        NSInteger light_Low = ([ft.light integerValue] - 1) * 20;                 // 光照 强度 最低
        //NSInteger light_Hight = [ft.light integerValue] * 20;                     // 光照 强度 最高
        
        BOOL isCreate = YES;
        int timesOK = 0;
        NSArray *arrLight = [syn.light componentsSeparatedByString:@","];
        for (int i = 0; i < 24; i++)
        {
            NSInteger lightHour = [arrLight[i] integerValue];
            if (lightHour > light_Low)      ///  && lightHour < light_Hight
                timesOK ++;
        }
        if (timesOK >= light_TimeLow && timesOK <= light_TimeHight)
        {
            isCreate = NO;
            NSLog(@"光照正常");
        }
        
        if (isCreate)
        {
            NSString * alarm_sub_type = @"";
            if (timesOK < light_TimeLow)
                alarm_sub_type = @"00";
            else if(timesOK > light_TimeHight)
                alarm_sub_type = @"01";
            
            rdLight = [Remind MR_createEntityInContext:DBefaultContext];
            rdLight.access = myUserInfo.access;
            rdLight.alarm_type = @"02";
            rdLight.k_date = @(dateValue);
            rdLight.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
            rdLight.alarm_sub_type = alarm_sub_type;
            rdLight.isUpload = @(NO);
            rdLight.remindDate = [NSDate date];
            DBSave;
            
            [arrUpdate addObject:rdLight];   // 先加入， 上传的时候再判断
//            if(![fd.my_plant_id_T integerValue])    //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                [arrUpdate addObject:rdLight];
        }
    }
    
    Remind *rdTemp = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '03' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:DBefaultContext];
    if(!rdTemp && [arrAlarm[1] boolValue])
    {
        NSInteger temp_lowEST = [ft.temperatureLowEST integerValue];          // 极限最低
        NSInteger temp_low = [ft.temperatureLow integerValue];                // 低
        NSInteger temp_hight = [ft.temperatureHeight integerValue];           // 高
        NSInteger temp_hightEST = [ft.temperatureHeightEST integerValue];     // 极限最高
        
        NSString *alarm_sub_type = @"";
        BOOL isCreate = YES;
        NSInteger tempInt = [syn.mean_ambienttem integerValue] ? [syn.mean_ambienttem integerValue] - 50 : 0;
        if (tempInt <= temp_lowEST)
            alarm_sub_type = @"00";
        else if (tempInt > temp_lowEST && tempInt < temp_low)
            alarm_sub_type = @"01";
        else if (tempInt > temp_hight && tempInt < temp_hightEST)
            alarm_sub_type = @"02";
        else if (tempInt >= temp_hightEST)
            alarm_sub_type = @"03";
        else
        {
            isCreate = NO;
            NSLog(@"温度正常");
        }
        
        if (isCreate)
        {
            rdTemp = [Remind MR_createEntityInContext:DBefaultContext];
            rdTemp.access = myUserInfo.access;
            rdTemp.alarm_type = @"03";
            rdTemp.k_date = @(dateValue);
            rdTemp.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
            rdTemp.alarm_sub_type = alarm_sub_type;
            rdTemp.isUpload = @(NO);
            rdLight.remindDate = [NSDate date];
            DBSave;
            
            [arrUpdate addObject:rdTemp];
//            if(![fd.my_plant_id_T integerValue])                                 //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                [arrUpdate addObject:rdTemp];
        }
    }
    
    Remind *rdSoil = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and alarm_type == '04' and flower_Id == %@", myUserInfo.access, @(dateValue), [fd.my_plant_id integerValue] ? fd.my_plant_id : fd.my_plant_id_T] inContext:DBefaultContext];
    if(!rdSoil && [arrAlarm[3] boolValue])
    {
        NSInteger soil_Low = ([ft.soli integerValue] - 1) * 20;                 // 湿度 最低
        NSInteger soil_Hight = [ft.soli integerValue] * 20;                     // 湿度 最高
        
        NSString *alarm_sub_type = @"";
        BOOL isCreate = YES;
        NSInteger soilInt = [syn.mean_solimois integerValue];
        if (soilInt < soil_Low)
            alarm_sub_type = @"00";
        else if (soilInt > soil_Hight)
            alarm_sub_type = @"01";
        else
        {
            isCreate = NO;
            NSLog(@"湿度正常");
        }
        
        if (isCreate)
        {
            rdSoil = [Remind MR_createEntityInContext:DBefaultContext];
            rdSoil.access = myUserInfo.access;
            rdSoil.alarm_type = @"04";
            rdSoil.k_date = @(dateValue);
            rdSoil.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
            rdSoil.alarm_sub_type = alarm_sub_type;
            rdSoil.isUpload = @(NO);
            rdSoil.remindDate = [NSDate date];
            DBSave;
            
            [arrUpdate addObject:rdSoil];
//            if(![fd.my_plant_id_T integerValue])                                 //  如果是本地的数据， 就不上传 等待植物上传了再上传
//                [arrUpdate addObject:rdSoil];
        }
    }
    [self.delegate CallBack_Data:301 uuidString:uuid obj:arrUpdate];
}


// 获取这个植物那天的得分
-(NSNumber *)getScore:(SyncDate *)syn
{
    NSInteger scoreTemp = 0;
    NSInteger scoreLight = 0;
    NSInteger scoreSoil = 0;
    
    NSArray *arrLight = [syn.light componentsSeparatedByString:@","];
    //NSArray *arrSoil = [syn.soil_moisture componentsSeparatedByString:@","];
    NSArray *arrTemp = [syn.ambient_temperature componentsSeparatedByString:@","];
    
    
    FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and my_plant_id == %@", syn.access, syn.my_plant_id] inContext:DBefaultContext];
    FlowerType *ft = [FlowerType findFirstByAttribute:@"iD" withValue:fd.plant_id inContext:DBefaultContext];
    
    //  ------------------------ 光照得分 -------------------------
    
    NSInteger light_TimeLow = [ft.light_lowest_time integerValue];      // 最短 光照小时数
    NSInteger light_TimeHight = [ft.light_highest_time integerValue];   // 最长 光照小时数
    //NSInteger light_avg = (light_TimeLow + light_TimeHight) / 2;      // 正常的光照小时数
    
    NSInteger light_Low = ([ft.light integerValue] - 1) * 20;                 // 光照 强度 最低
    NSInteger light_Hight = [ft.light integerValue] * 20;                     // 光照 强度 最高
    
    int timesOK = 0;
    for (int i = 0; i < 24; i++)
    {
        NSInteger lightHour = [arrLight[i] integerValue];
        if (lightHour > light_Low) //  && lightHour < light_Hight
            timesOK ++;
    }
    if (timesOK >= light_TimeLow && timesOK <= light_TimeHight)
        scoreLight = 13;
    else if(timesOK < light_TimeLow)
        scoreLight = 13 * (double)timesOK / (double)light_TimeLow;
    else if (timesOK > light_TimeHight) // 33*(7-(9-7))/7
        scoreLight = 13 * (double)(light_Hight * 2 - timesOK) / (double)light_TimeHight;
    
    
    //  ------------------------ 温度得分 -------------------------
    
    double temp_lowEST = [ft.temperatureLowEST doubleValue];          // 极限最低
    double temp_low = [ft.temperatureLow doubleValue];                // 低
    double temp_hight = [ft.temperatureHeight doubleValue];           // 高
    double temp_hightEST = [ft.temperatureHeightEST doubleValue];     // 极限最高
    
    BOOL isContinue = YES;
    int subTem = 0;
    for (int i = 0; i < arrTemp.count; i++)
    {
        NSInteger temp = [arrTemp[i] integerValue];
        temp = temp == 0 ? 0 : temp - 50;
        subTem += temp;
    }
    subTem = subTem / 24.0;
    if(subTem<= temp_lowEST || subTem >= temp_hightEST)
    {
        isContinue = NO;        //  如果触及到极限温度，这分项得分直接为 0；
    }
    
    if (isContinue)
    {
        double avgTemp = [syn.mean_ambienttem integerValue] ? [syn.mean_ambienttem integerValue] - 50 : 0;
        if (avgTemp < temp_low)
            scoreTemp = 13 * ((temp_hight - temp_low) - (temp_low - avgTemp)) / (temp_hight - temp_low);
        else if (avgTemp > temp_hight)
            scoreTemp = 13 * ((temp_hight - temp_low) - (avgTemp - temp_hight)) / (temp_hight - temp_low);
        else
            scoreTemp = 13;
    }
    
    //  ------------------------ 湿度得分 -------------------------
    
    NSInteger soil_Low = ([ft.soli integerValue] - 1) * 20;                 // 湿度 最低
    NSInteger soil_Hight = [ft.soli integerValue] * 20;                     // 湿度 最高
    
    double avgSoil = [syn.mean_solimois doubleValue];
    if ((avgSoil < soil_Low && soil_Low - avgSoil >= 20) || (avgSoil > soil_Hight && avgSoil - soil_Hight >= 20))
        scoreSoil = 0;
    else if(avgSoil < soil_Low)
        scoreSoil = 14 * (double)(20 - (soil_Low - avgSoil)) / 20.0;
    else if(avgSoil > soil_Hight)
        scoreSoil = 14 * (double)(20 - (avgSoil - soil_Hight)) / 20.0;
    else
        scoreSoil = 14;
    
    
    scoreLight = scoreLight < 0 ? 0 : scoreLight;
    scoreTemp = scoreTemp < 0 ? 0 : scoreTemp;
    scoreSoil = scoreSoil < 0 ? 0 : scoreSoil;

    NSInteger result = scoreLight + scoreTemp + scoreSoil;
    NSLog(@"%ld-%ld : 光照：%ld分 温度：%ld分 湿度： %ld分  总分：%ld",  (long)[syn.month integerValue],  (long)[syn.day integerValue],(long)scoreLight, (long)scoreTemp, (long)scoreSoil, (long)result);
    result += 60;
    return  @(result);
}


// 获取在数组中最大的那个值的索引  （数组中为NSNumber）
-(NSInteger)getBiggestIndexInArray:(NSMutableArray *)array
{
    NSInteger tem = 0;
    NSInteger bigger = 0;
    NSInteger ind = 0;              // 索引
    for (int i = 0; i < array.count; i++)
    {
        bigger = [array[i] integerValue];
        if (tem < bigger) {
            tem = bigger;
            ind = i;
        }
    }
    
    return ind;
}






@end
