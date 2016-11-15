//
//  NSObject+userInfo.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "NSObject+userInfo.h"
#import "NSString+toDate.h"

static UserInfo *userInfo;


@implementation NSObject (userInfo)

-(id)getUserInfo
{
    return [self sharedManager];
}

- (UserInfo *)sharedManager
{
    @synchronized(self)
    {
        if (!userInfo)
        {
          NSString *access = GetUserDefault(userInfoAccess);
          if (access)
          {
            UserInfo *us =
                [[UserInfo findByAttribute:@"access" withValue:access] firstObject];
            if (us)
              userInfo = us;
            else
            {
              [self initUserInfo:userInfo access:access];
              [self initSystemSettings:access];
            }
          }
        }
        return userInfo;
      }
}

+(void)returnUserNil
{
    userInfo = nil;
}

-(void)initUserInfo:(UserInfo *)userinfo access:(NSString *)access
{
    userInfo = [UserInfo MR_createEntityInContext:DBefaultContext];
    userInfo.email = ((NSDictionary *)GetUserDefault(userInfoEmail))[access];        //  赋值默认数据前， 本地已经存储了邮箱
    userInfo.access = access;
    userInfo.distanceSwitch = @(NO);
    userInfo.temperatureSwitch = @(NO);
    userInfo.info_start = @9;
    userInfo.info_end = @20;
    userInfo.user_country_code = @0;
    userInfo.user_city_code = @0;
    userInfo.user_state_code = @0;
    userInfo.user_gender = @(NO);
    userInfo.user_height = @180.0;
    userInfo.user_weight = @65.0;
    NSString *strDate = @"19900101";
    userInfo.user_birthday = [strDate toDate:strDate];
    userInfo.update_time = @0;
    userInfo.my_plant_update_time = @0;
    userInfo.help_pic_update_time = @0;
    userInfo.plant_data_max_version = @0;
    userInfo.user_pic_url = @"touxiang";
    userInfo.isUpate = @(YES);
    DBSave;
}

-(void)initSystemSettings:(NSString *)access
{
    // 默认的系统设置数据
    SystemSettings *sst;
    sst = [SystemSettings MR_createEntityInContext:DBefaultContext];
    sst.update_time = @([[NSDate date] timeIntervalSince1970] * 1000);
    sst.access = access;
    sst.sys_distance_unit = @(YES);
    sst.sys_temperature_unit = @(YES);
    sst.sys_notify_time_start = @9;
    sst.sys_notify_time_end = @20;
    sst.isUpload = @(NO);
    sst.getAddress = @(YES);
    DBSave;
}

@end
