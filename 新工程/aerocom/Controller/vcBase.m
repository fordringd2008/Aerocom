//
//  vcBase.m
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"
#import "LxxPlaySound.h"
#import "LNNotificationsUI.h"
#import "GUAAlertView.h"

#define NavRightButtonFrame                         CGRectMake(0, 0, 30, 30)

const NSTimeInterval LinkInterverl =                     1;

static NSTimer *timerRealSys;                       // 循环同步器  20分钟一次同步所有

@interface vcBase () <BLEManagerDelegate, aLiNetDelegate>
{
//    void                (^RightButtonClickBlock)();
    CGFloat             fontSize;
    NSDate *            lastBeginLinkDate;
    
}

@end

@implementation vcBase

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButton:nil];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.userInfo = [self getUserInfo];

    // 这里要进行判定， 如果是注销，后进来的， 就阻止初始化   
    if([GetUserDefault(isNotRealNewBLE) boolValue])
    {
        self.Bluetooth = [BLEManager sharedManager];
        self.Bluetooth.delegate = self;                                     // 这里改动， 可能影响很多
        self.Bluetooth.isFailToConnectAgain = YES;
    }
    else
    {
        [self.timerAutoLink stop];
        self.timerAutoLink = nil;
    }
    self.isPop = YES;
    
    self.windowView = [UIApplication sharedApplication].keyWindow;
    self.alinet = [[aLiNet alloc] init];
    self.alinet.delegate = self;
    if(!self.arrUploadRemind)
        self.arrUploadRemind = [NSMutableArray new];
    
    [self getFontSize];
    [self checkRemindTakePhone];
    
    if (!timerRealSys)
    {
//        NSLog(@"-------------- 这里初始化了 ：%@", self);
        [self realSyn];
        timerRealSys = [NSTimer scheduledTimerWithTimeInterval:1 * 60 target:self selector:@selector(realSyn) userInfo:nil repeats:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userInfo = [self getUserInfo];
    self.Bluetooth.delegate = self;
    
    if(![GetUserDefault(UpdateDataing) boolValue])
    {
        [self reachabilityManager];
    }
    else if (GetUserDefault(JSonFail))
    {
        __block vcBase *blockSelf = self;
        RequestCheckBefore(
           NSLog(@"开始下载JSon文件");
           [net getNewestPlantJSONData:GetUserDefault(NewJsonURL)];,
           RemoveUserDefault(JSonFail);
           [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];,
           NSLog(@"------- 5  下载Json 失败");
           RemoveUserDefault(UpdateDataing);
           SetUserDefault(JSonFail, @YES);)
    }
    else NSLog(@"viewWillAppear前检查 -- 正在下");
}

-(void)setNavTitle:(UIViewController *)vc title:(NSString *)title
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.text = kString(title);
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor whiteColor];
    vc.navigationItem.titleView = lblTitle;
}

-(void)resetBLEDelegate
{
    self.Bluetooth.delegate = self;
}



// 进入APP判断 是否改提醒  只看天数
-(void)checkRemindTakePhone
{
    NSInteger todayValue             = [self HmF2KNSDateToInt:[NSDate date]];
    NSInteger lastCheckRemind        = [GetUserDefault(CheckRemind) integerValue];
    if (lastCheckRemind == todayValue)                                                      // 如果今天检查过了， 就不再检查了
        return;
    if (!self.arrUploadRemind)
        self.arrUploadRemind = [NSMutableArray new];
    NSArray *arrFl = [FlowerData findByAttribute:@"access" withValue:self.userInfo.access];
    for (int i = 0;  i < arrFl.count; i++)
    {
        FlowerData *fd = arrFl[i];
        NSArray *arrAlarm = [fd.alarm_set componentsSeparatedByString:@"-"];                // 如果这个植物禁止了拍照提醒 跳过
        arrAlarm = arrAlarm.count < 4 ? @[@"1",@"1",@"1",@"1"] : arrAlarm;                  // 坑爹的江华
        if ([arrAlarm[3] boolValue])
            continue;
        
        NSInteger lastDateValueTakePhone = [self HmF2KNSDateToInt:fd.last_photo_time];
        NSInteger todayValue             = [self HmF2KNSDateToInt:[NSDate date]];

        if (todayValue == lastDateValueTakePhone + 1)
        {
            Remind *rd = [Remind MR_createEntityInContext:DBefaultContext];
            rd.access = self.userInfo.access;
            rd.k_date = @(todayValue);
            rd.flower_Id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
            rd.isUpload = @(NO);
            rd.alarm_type = @"01";
            rd.alarm_sub_type = @"00";        // 这个随便一个 不为空就好
            DBSave;
            [self.arrUploadRemind addObject:rd];
        }
    }
    if(arrFl.count > 0) SetUserDefault(CheckRemind, @(todayValue));
}


-(void)reachabilityManager
{
    if (self.userInfo.access && [GetUserDefault(isFirstSys) boolValue])       // 同步完成的时候，置为YES
    {
        __block vcBase *blockSelf = self;
        RequestCheckNoWaring(
             [net getInfoHint:blockSelf.userInfo.access];,
             [blockSelf dataSuccessBack_getInfoHint:dic];)
    }
}

#pragma mark -  流程
// ----------------------------------------------------------------
//    流程  系统设置  ---》 我的花园  --》 个人信息修改  -- > 植物数据包
// ----------------------------------------------------------------

// ----------------------------------------------------------------
//    流程  上传全天数据后， 再上传提醒
// ----------------------------------------------------------------

-(void)dataSuccessBack_getInfoHint:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        long long user_sys_update_time = [dic[@"user_sys_update_time"] longLongValue];
        long long my_plant_update_time = [dic[@"my_plant_update_time"] longLongValue];
        long long help_pic_update_time = [dic[@"help_pic_update_time"] longLongValue];
        NSInteger plant_data_max_version = [dic[@"plant_data_max_version"] integerValue];
        long long user_info_update_time = [dic[@"user_info_update_time"] longLongValue];
        
        self.arrNewValues = [NSArray arrayWithObjects:@(user_sys_update_time), @(my_plant_update_time), @(help_pic_update_time), @(plant_data_max_version), @(user_info_update_time), nil];
        
        //  这里判定 帮助图片是否有更新
        [self checkHelpUrl];
        
        SystemSettings *sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
        long long valueFromServer = [self.arrNewValues[0] longLongValue];
        long long valueFromLocal = [sst.update_time longLongValue];
        if (valueFromServer > valueFromLocal)  // 服务器设置 覆盖掉本地
        {
            // 获取服务器最新系统设置
            __block vcBase *blockSelf = self;
            RequestCheckNoWaring(
                 [net getSystemSetting:blockSelf.userInfo.access];,
                 [blockSelf dataSuccessBack_getSys:dic];)
        }
        else if (valueFromServer < valueFromLocal) // 上传本地设置
        {
            NSMutableDictionary *dicR = [NSMutableDictionary new];
            [dicR setObject:self.userInfo.access forKey:@"access"];
            [dicR setObject:([sst.sys_distance_unit boolValue] ? @"01" : @"02") forKey:@"sys_distance_unit"];
            [dicR setObject:([sst.sys_temperature_unit boolValue]  ? @"01" : @"02") forKey:@"sys_temperature_unit"];
            [dicR setObject:sst.sys_notify_time_start forKey:@"sys_notify_time_start"];
            [dicR setObject:sst.sys_notify_time_end forKey:@"sys_notify_time_end"];
            [dicR setObject:sst.update_time forKey:@"update_time"];
            [dicR setObject:@([sst.getAddress integerValue])  forKey:@"sys_location_status"];
            
            __block vcBase *blockSelf = self;
            RequestCheckNoWaring(
                 [net updateSysSetting:dicR];,
                 [blockSelf dataSuccessBack_updateSys:dic];);
        }
        else
        {
            [self sysMyPlantInfo];
        }
    }
}

-(void)dataSuccessBack_getSys:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        SystemSettings *sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
        
        sst.update_time = @([dic[@"update_time"] longLongValue]);
        sst.sys_distance_unit = @([[dic[@"sys_distance_unit"] description] isEqualToString:@"01"]);
        sst.sys_temperature_unit = @([[dic[@"sys_temperature_unit"] description] isEqualToString:@"01"]);
        sst.sys_notify_time_start = @([dic[@"sys_notify_time_start"] integerValue]);
        sst.sys_notify_time_end = @([dic[@"sys_notify_time_end"] integerValue]);
        sst.update_time = @([dic[@"update_time"] longLongValue]);
        sst.isUpload = @(YES);
        DBSave;
        
        [self sysMyPlantInfo];
    }
    else if ([dic[@"status"] isEqualToString:@"1"])             //  没有上传系统设置
    {
        // 这里要上传系统设置
        SystemSettings *sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
        sst.update_time = @([dic[@"update_time"] longLongValue]);
        sst.sys_distance_unit = @([[dic[@"sys_distance_unit"] description] isEqualToString:@"01"]);
        sst.sys_temperature_unit = @([[dic[@"sys_temperature_unit"] description] isEqualToString:@"01"]);
        sst.sys_notify_time_start = @([dic[@"sys_notify_time_start"] integerValue]);
        sst.sys_notify_time_end = @([dic[@"sys_notify_time_end"] integerValue]);
        sst.update_time = @([dic[@"update_time"] longLongValue]);
        sst.isUpload = @(YES);
        DBSave;
    }
}

-(void)dataSuccessBack_updateSys:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        SystemSettings *sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
        sst.update_time = @([dic[@"update_time"] longLongValue]);
        sst.isUpload = @(YES);
        [NetTool changeType:4 isFinish:YES];
        DBSave;
        
        [self sysMyPlantInfo];
    }
}

-(void)dataSuccessBack_get_MyPlantInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        long long datetimeFromServer = [dic[@"update_time"] longLongValue];
        long long addDatetimeFromLocal = [NetTool getLastDateTime:0];                   // 添加，修改 的最后时间
        long long deleteDatetimeFromLocal = [NetTool getLastDateTime:1];                // 删除      的最后时间
        long long lastValue = addDatetimeFromLocal > deleteDatetimeFromLocal ? addDatetimeFromLocal : deleteDatetimeFromLocal;
        
        NSArray *arrPlantData = dic[@"my_plant_arr"];
        if (datetimeFromServer > lastValue)                // 以服务器时间为主， 如果服务器时间轴大于本地， 覆盖本地
        {
            // 这里如果全部删除， 会删除之前的分数数据
            //                [FlowerData deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access = %@", self.userInfo.access]];
            //                DBSave;
            
            //NSMutableArray *arrPlantFromServer = [NSMutableArray new]; // 存放服务器存在的数据，本地的数据如果没有在这里，就删掉
            for (int i = 0;  i <  arrPlantData.count; i++)
            {
                NSDictionary * dicFdFromServer = arrPlantData[i];
                FlowerData * fdFromLocal = [[FlowerData findByAttribute:@"my_plant_id" withValue:dicFdFromServer[@"my_plant_id"]] firstObject];
                if (!fdFromLocal)
                    fdFromLocal = [FlowerData MR_createEntityInContext:DBefaultContext];
                fdFromLocal.access = self.userInfo.access;
                fdFromLocal.alarm_set = [dicFdFromServer[@"alarm_set"] debugDescription];
                fdFromLocal.bind_device_mac = dicFdFromServer[@"bind_device_mac"];
                fdFromLocal.bind_device_name = dicFdFromServer[@"bind_device_name"];
                fdFromLocal.camera_alert = @([dicFdFromServer[@"camera_alert"] integerValue]);
                fdFromLocal.my_plant_id = @([dicFdFromServer[@"my_plant_id"] integerValue]);
                fdFromLocal.my_plant_latitude = @([dicFdFromServer[@"my_plant_latitude"] doubleValue]);
                fdFromLocal.my_plant_longitude = @([dicFdFromServer[@"my_plant_longitude"] doubleValue]);
                fdFromLocal.my_plant_name = dicFdFromServer[@"my_plant_name"];
                fdFromLocal.my_plant_pic_url = dicFdFromServer[@"my_plant_pic_url"];
                fdFromLocal.my_plant_pot = @([dicFdFromServer[@"my_plant_pic_url"] isEqualToString:@"01"]);
                fdFromLocal.my_plant_room = @([dicFdFromServer[@"my_plant_room"] isEqualToString:@"01"]);
                fdFromLocal.plant_id = @([dicFdFromServer[@"plant_id"] integerValue]);
                fdFromLocal.isUpdate = @(YES);
                DBSave;
            }
            
            NSArray *arrFromLocal = [FlowerData findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
            if (arrFromLocal.count > arrPlantData.count)                        // 这里说明， 本地有需要删除的数据
            {
                NSLog(@"这里要删除 数据");
                NSArray *arrDelete = [arrFromLocal filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"not (SELF in %@)", arrPlantData]];
                for (FlowerData *fdDeltete in arrDelete)
                    [fdDeltete MR_deleteEntityInContext:DBefaultContext];
                DBSave;
            }
            
            
            // 本地中 临时ID不为0的 数据  就是没上传的数据
            NSArray *arrFdNewFromLocal = [FlowerData findAllWithPredicate:[NSPredicate predicateWithFormat:@"my_plant_id_T != 0 and access = %@", self.userInfo.access] inContext:DBefaultContext];
            if (arrFdNewFromLocal.count > 0)
            {
                FlowerData *fd = arrFdNewFromLocal[0];
                [self upLocalFlowerData:fd];
            }
            else
            {
                [self sysUserInfo];// 上传后，  进行一下个流程  个人信息修改                                            //开始更新
            }
        }
        else if (datetimeFromServer < lastValue)            // 服务器时间小于本地   以本地时间为主
        {
            // 找到没上传的第一个 ( 包括 添加的 和 修改的)
            FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isUpdate = %@", @NO] sortedBy:@"my_plant_id_T" ascending:NO inContext:DBefaultContext];
            if (fd)
                [self upLocalFlowerData:fd];
            else
                [self sysUserInfo];
        }
        else
        {
            [self sysUserInfo];
        }
    }
}

-(void)dataSuccessBack_updateUser:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        self.userInfo.update_time = @([[dic[@"update_time"] description] longLongValue]);
        self.userInfo.isUpate = @(YES);
        self.imgdata = self.userInfo.imageData = nil;     // 上传完成后，  清空
        self.imgType = self.userInfo.imageType = nil;
        DBSave;
        [NetTool changeType:3 isFinish:YES];
        // 个人信息同步完成  进入同步提醒
        
        [self sysPlantDat];
    }
}

-(void)dataSuccessBack_updatePlant:(NSDictionary *)dic
{
    if (!CheckIsOK) return;
    
    // 同步上传的成功后
    [NetTool changeType:0 isFinish:YES];
    
    FlowerData *model = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isUpdate = %@", @(NO)] sortedBy:@"my_plant_id_T" ascending:NO inContext:DBefaultContext];
    
    model.isUpdate = @(YES);
    model.update_time = @([dic[@"update_time"] longLongValue]);
    model.my_plant_id = @([dic[@"my_plant_id"] integerValue]);
    NSNumber *plantID = model.my_plant_id_T;
    model.my_plant_id_T = @(0);                                                // 上传后， 临时ID 设置为0
    self.imgdata = model.imageData = nil;                                      // 上传完成后，  清空
    self.imgType = model.imageType = nil;
    
    // 上传成功后， 一定要把它关联的相册表， 还有同步数据表中的  临时ID 改为新的ID  还有提醒表
    NSArray *arrAlbum = [Album findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and flowerID = %@", self.userInfo.access, plantID] inContext:DBefaultContext];
    for (Album *ab in arrAlbum) {
        ab.flowerID = model.my_plant_id;
    }
    
    NSArray *arrSysData = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and my_plant_id = %@", self.userInfo.access, plantID] inContext:DBefaultContext];
    for (SyncDate *sd in arrSysData) {
        sd.my_plant_id = model.my_plant_id;
    }
    
    NSArray *arrRemind = [Remind findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and flower_Id = %@", self.userInfo.access, plantID] inContext:DBefaultContext];
    for (Remind *rd in arrRemind) {
        rd.flower_Id = model.my_plant_id;
    }
    
    
    DBSave;
    
    NSArray *arrData = [FlowerData findAllWithPredicate:[NSPredicate predicateWithFormat:@"isUpdate = %@ and access = %@", @(NO), self.userInfo.access] inContext:DBefaultContext];
    if (arrData.count > 0)
    {
        [self upLocalFlowerData:arrData[0]];
    }
    else
    {
        [NetTool changeType:0 isFinish:YES];
        [NetTool changeType:1 isFinish:YES];
        [self sysUserInfo];
    }
}

-(void)dataSuccessBack_get_UserIno:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
//        self.userInfo = [[UserInfo findByAttribute:@"access" withValue:self.userInfo.access] firstObject];
        self.userInfo = myUserInfo;
        self.userInfo.email = ((NSDictionary *)GetUserDefault(userInfoEmail))[self.userInfo.access];
        self.userInfo.user_pic_url = [dic[@"user_pic_url"] description].length == 0 ? @"touxiang" : [dic[@"user_pic_url"] description];
        self.userInfo.user_nick_name = dic[@"user_nick_name"];
        self.userInfo.user_country_code = @(([dic[@"user_country_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_country_code"] integerValue]));
        self.userInfo.user_state_code = @(([dic[@"user_state_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_state_code"] integerValue]));
        self.userInfo.user_city_code = @(([dic[@"user_city_code"] isEqualToString:@""] ? 0 : [(NSString *)dic[@"user_city_code"] integerValue]));
        self.userInfo.user_gender = @([(NSString *)dic[@"user_gender"] intValue]);
        self.userInfo.user_weight = @([(NSString *)dic[@"user_weight"] doubleValue]);
        self.userInfo.user_height = @([(NSString *)dic[@"user_height"] doubleValue]);
        self.userInfo.user_birthday = [dic[@"user_birthday"] toDate:dic[@"user_birthday"]];
        self.userInfo.update_time = @((long)dic[@"update_time"]);
        self.userInfo.isUpate = @(YES);
        DBSave;
        
        // 个人信息同步完成 开始同步植物数据信息
        [self sysPlantDat];
    }
}

-(void)dataSuccessBack_NewPlantData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSArray *arrNewPlant = dic[@"plant_pic"];
        if (!self.arrInNewPlantData)  self.arrInNewPlantData = [[NSMutableArray alloc] init];
        NSInteger versionFromLocal = [GetUserDefault(version_Pic) integerValue];
        
        for (NSDictionary *d in arrNewPlant)
        {
            NSInteger version = [d[@"pic_version"] integerValue];
            NSString *pic_url = d[@"pic_url"];
            if (version > versionFromLocal)
            {
                [self.arrInNewPlantData addObject:@{ d[@"pic_version"]:pic_url }];
            }
        }
        
        NSInteger versionJson = [dic[@"plant_data"][@"data_version"] integerValue];
        versionFromLocal = [GetUserDefault(version_Local) integerValue];
        if (versionJson > versionFromLocal)
        {
            [self.arrInNewPlantData addObject:@{ @"json":dic[@"plant_data"][@"data_url"] }];
        }
        
        // 取消更新的话 间隔时间后 再次提示   1H
        
//        __block vcBase *blockSelf = self;
//        RequestCheckNoWaring(
//                 [net getNewestPlantJSONData:@"http://plant-data.oss-cn-shenzhen.aliyuncs.com//plant_data_zh_v7.json"];,
//                 [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];)
        
        if (self.arrInNewPlantData.count > 1)
        {
            if ([GetUserDefault(DNet) intValue] == 1)
            {
                TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"植物数据有新增，是否获取最新的数据包？"];
                [alert showWithActionSure:^{
                    LMBShow(@"正在更新植物数据");
                    [self.alinet downLoadNewestData_112:self.arrInNewPlantData];
                } cancel:^{
                    RemoveUserDefault(UpdateDataing);
                    SetUserDefault(LoadRejectData, [NSDate date]);
                }];
            }
            else if ([GetUserDefault(DNet) intValue] == 2)
            {
                TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"植物数据有新增，是否获取最新的数据包？（当前网络为2G/3G/4G， 建议在WIFI网络时下载）"];
                [alert showWithActionSure:^{
                    [self.alinet downLoadNewestData_112:self.arrInNewPlantData];            //  2G/3G/4G 时提醒用户
                } cancel:^{}];
            }
        }
    }
}

-(void)dataSuccessBack_getNewestPlantJSONData:(NSDictionary *)dicA
{
    NSLog(@"json 下载成功");
    __block vcBase *blockSelf = self;
    __block NSDictionary *blockdic = dicA;
    
    NextWaitInGlobal(
     [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *arrData = blockdic[@"flowers"];
        for (int i = 0; i < arrData.count; i++)
        {
            NSDictionary *dic = arrData[i];
            FlowerType *ft = [[FlowerType findByAttribute:@"iD" withValue:dic[@"id"] inContext:localContext] firstObject];
            if (!ft)
                ft = [FlowerType MR_createEntityInContext:localContext];
            ft.iD = @([dic[@"id"] integerValue]);
            ft.icon = dic[@"icon"];
            ft.otherName = dic[@"otehrname"];
            ft.scientificname = dic[@"scientificname"];
            ft.startLetter = dic[@"StartLetter"];
            ft.name = dic[@"name"];
            ft.descript = dic[@"description"];
            ft.light = @([dic[@"light"] integerValue]);
            ft.light_lowest_time = @([dic[@"light_lowest_time"] integerValue]);
            ft.light_highest_time = @([dic[@"light_highest_time"] integerValue]);
            ft.soli = @([dic[@"soli"] integerValue]);
            ft.temperatureLow = @([dic[@"temperature_lowest"] integerValue]);
            ft.temperatureHeight = @([dic[@"temperature_highest"] integerValue]);
            ft.temperatureLowEST = @([dic[@"temperature_aralm_lowest"] integerValue]);
            ft.temperatureHeightEST = @([dic[@"temperature_aralm_highest"] integerValue]);
            ft.temp1 = dic[@"temp1"];
            ft.temp2 = dic[@"temp2"];
            ft.temp3 = dic[@"temp3"];
            ft.temp4 = dic[@"temp4"];
            DLSave;
            DBSave;
        }
        NSLog(@"json 文件解析 保存完毕");
        [blockSelf sysOneceOver];
        RemoveUserDefault(NewJsonURL);
        }];
    , 0);
}

-(void)dataSuccessBack_updateMyPlantData:(NSDictionary *)dic
{
    NSMutableArray *arrSearch = [[NSMutableArray alloc] initWithObjects:self.userInfo.access, nil];
    [arrSearch addObjectsFromArray:self.arrUpdataSynID];
    NSArray *arrSyn = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"my_plant_id in %@", self.arrUpdataSynID] inContext:DBefaultContext];
    
    for (SyncDate *sn in arrSyn)
    {
        if ([sn.access isEqualToString:self.userInfo.access])
        {
            sn.isUpload = @(YES);
        }
    }
    DBSave;
    
    // 同步完大数据， 这里就可以同步提醒了
    [self  sysRemind];
}

// 上传温度 湿度 光照 异常
-(void)dataSuccessBack_updateAlarmInfoForLight:(NSDictionary *)dic
{
    //NSLog(@"光照，温度，湿度 报警上传成功    《《《《《《《《《《《");
    if (CheckIsOK)
    {
        for (Remind *rd in self.arrUploadRemind)
        {
            if (rd) {
                rd.isUpload = @YES;
            }
        }
        DBSave;
        [NetTool changeType:5 isFinish:YES];
        [self.arrUploadRemind removeAllObjects];
    }
}

-(void)dataSuccessBack_updateAlarmInfoForTakePhoto:(NSDictionary *)dic
{
    //NSLog(@"拍照提醒 上传成功    《《《《《《《《《《《《《《《《《《《《《《《《");
    if (!CheckIsOK) return;
    for (Remind *rd in self.arrUploadRemind)
        rd.isUpload = @YES;
    DBSave;
    [NetTool changeType:5 isFinish:YES];
    [self.arrUploadRemind removeAllObjects];
}

-(void)dataSuccessBack_getToken_distribute_server:(NSDictionary *)dic
{
    [self.alinet initAndupload:self.imgType imData:self.imgdata dic:dic];   // 上传图片
}



-(void)checkHelpUrl
{
    long long  lastUpdateTimeFromServer =  [self.arrNewValues[2] longLongValue];
    NSMutableArray *arr = GetUserDefault(HelpUrlVersion);                 // 0: 时间值  1， 版本号  2 URL(NSArray)  3 是否有更新 4 语言 1 2 3
    arr = [arr mutableCopy];
    if (!arr || arr.count != 4)
    {
        arr = [@[ @(0), @(0), @[@"", @"", @""], @(NO)] mutableCopy];
    }
    long long lastUpdateTimeFromLocal = [arr[0] longLongValue];
    if (lastUpdateTimeFromLocal < lastUpdateTimeFromServer)
    {
        arr[3] = @(YES);
        SetUserDefault(HelpUrlVersion, arr);
    }
}

// 逐一上传， 如果有图片 先上传图片 后上传服务器   ( 这里也可能是修改的 )
-(void)upLocalFlowerData:(FlowerData *)fd
{
    if (fd.imageData)
    {
        self.imgdata = fd.imageData;
        self.imgType = fd.imageType;
        __block vcBase *blockSelf = self;
        self.upLoad_Next = ^(NSString *url)
        {
            if(!url.length)
            {
                NSLog(@"图片上传失败");
                LMBShowInBlock(NONetTip);
            }else
            {
                fd.my_plant_pic_url = url;
                DBSave;
                [blockSelf saveFlantToServer:fd];
            }
        };
        [self getTokenAndUpload];
    }
    else
    {
        [self saveFlantToServer:fd];
    }
}

// 上传服务器 （ 图片已经完成了 ）
-(void)saveFlantToServer:(FlowerData *)model
{
    NSMutableArray *arrLatitudeAndLongtude = GetUserDefault(Latitude_Longitude);
    if (arrLatitudeAndLongtude) {
        model.my_plant_longitude = arrLatitudeAndLongtude[0];
        model.my_plant_latitude = arrLatitudeAndLongtude[1];
    }
    else
    {
        model.my_plant_longitude = @(0);
        model.my_plant_latitude = @(0);
    }
    DBSave;
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:self.userInfo.access forKey:@"access"];
    [dic setObject:model.my_plant_name forKey:@"my_plant_name"];
    [dic setObject:model.plant_id forKey:@"plant_id"];
    [dic setObject:model.my_plant_room ? @"01" : @"02" forKey:@"my_plant_room"];
    [dic setObject:model.my_plant_pot ?   @"01" : @"02" forKey:@"my_plant_pot"];
    [dic setObject:model.camera_alert forKey:@"camera_alert"];
    [dic setObject:model.bind_device_name ? model.bind_device_name : @"" forKey:@"bind_device_name"];
    [dic setObject:model.bind_device_mac ? model.bind_device_mac : @"" forKey:@"bind_device_mac"];
    [dic setObject:model.alarm_set forKey:@"alarm_set"];
    [dic setObject:model.my_plant_pic_url ? model.my_plant_pic_url : @"" forKey:@"my_plant_pic_url"];
    [dic setObject:model.my_plant_longitude forKey:@"my_plant_longitude"];
    [dic setObject:model.my_plant_latitude forKey:@"my_plant_latitude"];
    if ([model.my_plant_id boolValue]) {
        [dic setObject:model.my_plant_id forKey:@"my_plant_id"];
    }
    
    __block vcBase *blockSelf = self;
    RequestCheckNoWaring(
         [net updateMyPlantInfo:dic];,
         [blockSelf dataSuccessBack_updatePlant:dic];)
}


// 同步个人资料      （ 花园资料后的操作 ）
-(void)sysUserInfo
{
    long long datetimeUserEditFromServer = [self.arrNewValues[4] longLongValue];
    long long datetimeUserEditFromLocal = [NetTool getLastDateTime:3];
    if (datetimeUserEditFromServer > datetimeUserEditFromLocal)
    {
        // 拉去。 覆盖
        __block vcBase *blockSelf = self;
        RequestCheckNoWaring(
         [net getUserInfo:blockSelf.userInfo.access];,
         [blockSelf dataSuccessBack_get_UserIno:dic];)
        
    }
    else if (datetimeUserEditFromServer < datetimeUserEditFromLocal)
    {
        // 上传 个人信息  可能有图片
        if (self.userInfo.imageData)
        {
            self.imgdata = self.userInfo.imageData;
            self.imgType = self.userInfo.imageType;
            __block vcBase *blockSelf = self;
            self.upLoad_Next = ^(NSString *url)
            {
                if(!url.length)
                {
                    NSLog(@"图片上传失败");
                    LMBShowInBlock(NONetTip);
                }else
                {
                    blockSelf.userInfo.user_pic_url = url;
                    blockSelf.userInfo.imageData = nil;
                    blockSelf.userInfo.imageType = nil;
                    DBSave;
                    [blockSelf saveUserInfoToServer];
                }
            };
            [self getTokenAndUpload];
        }
        else
        {
            [self saveUserInfoToServer];
        }
    }
    else
    {
        [self sysPlantDat];
    }
}

-(void)sysRemind
{
    if (self.arrUploadRemind.count > 0)
    {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:self.userInfo.access forKey:@"access"];
        
        NSMutableArray *arrSub = [NSMutableArray new];
        
        for (int i = 0; i < self.arrUploadRemind.count; i++)
        {
            Remind *rd = self.arrUploadRemind[i];
            if ([rd.flower_Id intValue])
            {
                NSMutableDictionary *dicSub = [NSMutableDictionary new];
                [dicSub setObject:[rd.flower_Id description] ? [rd.flower_Id description] : [[rd valueForKey:@"flower_Id"] description]  forKey:@"my_plant_id"];
                [dicSub setObject:rd.alarm_type ? rd.alarm_type : [rd.alarm_type description] forKey:@"alarm_type"];
                [dicSub setObject:rd.alarm_sub_type ? rd.alarm_sub_type : [rd.alarm_sub_type description]  forKey:@"alarm_sub_type"];
                [dicSub setObject:rd.k_date ? rd.k_date : [rd.k_date description]  forKey:@"k_date"];
                [arrSub addObject:[dicSub mutableCopy]];
            }
        }
        
        NSString *jsonString = [self toJsonStringForUpload:arrSub];
        [dic setObject:jsonString forKey:@"alarm_arr"];
        
        
//        if(!dic.count || [dic.allValues[1] description].length < 3) return;
        
        __block vcBase *blockSelf = self;
        RequestCheckNoWaring(
         [net updateAlarmInfo:dic];,
         [blockSelf dataSuccessBack_updateAlarmInfoForLight:dic];)
    }
}


-(void)saveUserInfoToServer    //（ 图片已经完成了 ）
{
    NSMutableDictionary *dicUp = [NSMutableDictionary new];
    [dicUp setObject:self.userInfo.access forKey:@"access"];
    [dicUp setObject:self.userInfo.user_nick_name ? self.userInfo.user_nick_name : @"" forKey:@"user_nick_name"];
    [dicUp setObject:self.userInfo.user_country_code forKey:@"user_country_code"];
    [dicUp setObject:self.userInfo.user_state_code forKey:@"user_state_code"];
    [dicUp setObject:self.userInfo.user_gender forKey :@"user_gender"];
    [dicUp setObject:self.userInfo.user_height forKey:@"user_height"];
    [dicUp setObject:self.userInfo.user_weight forKey:@"user_weight"];
    [dicUp setObject:self.userInfo.user_pic_url forKey:@"user_pic_url"];
    [dicUp setObject: self.userInfo.user_birthday ? [self.userInfo.user_birthday toString:@"YYYYMMdd"] : @"19900101" forKey:@"user_birthday"];
    
    __block vcBase *blockSelf = self;
    RequestCheckNoWaring(
     [net updateUserInfo:dicUp];,
     [blockSelf dataSuccessBack_updateUser:dicUp];)
}

-(void)sysPlantDat              // 检查 植物数据库包    同步
{
    NSInteger versionFromServer = [self.arrNewValues[3] integerValue];
    NSInteger versionFromLocal = [GetUserDefault(version_Local) integerValue];
    
    if (versionFromServer > versionFromLocal)                                           // 有最新版本
    {
        NSDate *lastDate = (NSDate *)GetUserDefault(LoadRejectData);
        NSDate *now = [NSDate date];
        NSLog(@"距离上次拒绝时间 间隔为： %f", fabs([now timeIntervalSinceDate:lastDate]));
//#warning -------- refresh data interval
        if (!lastDate || fabs([now timeIntervalSinceDate:lastDate]) > 24 * 60 * 60)  // 一天 24 * 60 * 60
        {
            if(![GetUserDefault(UpdateDataing) boolValue])
            {
                SetUserDefault(UpdateDataing, @(YES));
                __block vcBase *blockSelf = self;
                RequestCheckNoWaring(
                     [net getNewestPlantData_112];,
                     [blockSelf dataSuccessBack_NewPlantData:dic];)
            }
            else if (GetUserDefault(JSonFail))
            {
                __block vcBase *blockSelf = self;
                RequestCheckBefore(
                   NSLog(@"开始下载JSon文件");
                   [net getNewestPlantJSONData:GetUserDefault(NewJsonURL)];,
                   RemoveUserDefault(JSonFail);
                   [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];,
                   NSLog(@"------- 5  下载Json 失败");
                   RemoveUserDefault(UpdateDataing);
                   SetUserDefault(JSonFail, @YES);)
            }
            else
            {
                NSLog(@"正在下");
            }
        }else
        {
            NSLog(@"还不到时间");
        }
    }
    else
    {
        [self sysOneceOver];
    }
}

-(void)sysOneceOver
{
    // 这里要 保存版本在本地了
    SetUserDefault(version_Local, self.arrNewValues[3]);
    SetUserDefault(isFirstSys, @0);                           //  同步完成
    RemoveUserDefault(UpdateDataing);
}

// 直接拉取
-(void)sysMyPlantInfo
{
    if(self.userInfo.access)
    {
        __block vcBase *blockSelf = self;
        RequestCheckNoWaring(
             [net getMyPlantInfo:blockSelf.userInfo.access];,
             [blockSelf dataSuccessBack_get_MyPlantInfo:dic];)
    }
    else NSLog(@"---------------  BUG");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initLeftButton:(NSString *)imgName
{
    NSString *img = imgName ? imgName : @"fanhui";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = NavButtonFrame;
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)back
{
    if (self.isJumpLock) {
        return;
    }
    
    self.isJumpLock = YES;
    if (self.isPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        YRSideViewController *sideViewController = [self.appDelegate sideViewController];
        [sideViewController showLeftViewController:true];
    }
    
    __block vcBase *blockSelf = self;
    NextWait(blockSelf.isJumpLock = NO;, 0.5);
}


-(void)backAfterOneSecond
{
    __block vcBase *blockSelf = self;
    NextWait(blockSelf.isJumpLock = NO;, 1);
}


-(void)initRightButton:(NSString *)text imgName:(NSString *)imgName
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 22, 22);
    
    if (imgName || text) {
        [button addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (imgName)
        [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    else if (text)
    {
        button.frame = CGRectMake(0, 0, 60, 22);
        [button setTitle:kString(text) forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 20 , 0, 0);
        //        Border(button, DRed);
        [button setTitleColor:DWhite forState:UIControlStateNormal];
        [button setBackgroundColor:DClear];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    if (!imgName && !text) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

-(void)rightButtonClick
{
    // 用来重写
}

-(void)gotoMainStoryBoard
{
    SetUserDefault(isNotRealNewBLE, @(1));
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.appDelegate.window.rootViewController = self.appDelegate.sideViewController;
    self.appDelegate.customTb.selectedIndex = 0;
}


-(void)gotoLoginStoryBoard
{
    SetUserDefault(isNotRealNewBLE, @(0));
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    UINavigationController *loginNav = login.instantiateInitialViewController;
    delegate.window.rootViewController = loginNav;
}

-(void)setSideslip:(BOOL)isSlip
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.sideViewController.needSwipeShowMenu = isSlip;
}

-(void)Scan
{
}



// BLEManagerDelegate
-(void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt
{
    NSMutableString *str = [NSMutableString string];
    for (NSString *key in recivedTxt.allKeys)
    {
        [str appendString:@"UUID:"];
        [str appendString:key];
        [str appendString:@"  name:"];
        [str appendString: ((CBPeripheral *)recivedTxt[key]).name];
        [str appendString:@"   "];
    }
    // NSLog(@"%@", str);
    
    self.dicBLEFound = recivedTxt;
    [self Found_Next:recivedTxt];
}

-(void)CallBack_ConnetedPeripheral:(NSString *)uuidString
{
    NSLog(@"已经连接 ---%@", uuidString);
    if (!self.Bluetooth.dicSysIng)
    {
        NSLog(@"---  这里重置了");
        self.Bluetooth.dicSysIng = [NSMutableDictionary new];
        self.Bluetooth.dicSysEnd = [NSMutableDictionary new];
    }
    [self performBlock:^{
        [self.Bluetooth.dicSysIng setObject:@"" forKey:uuidString];
    } afterDelay:0.1];
    
    [self Conneted_Next:uuidString];
}



-(void)CallBack_DisconnetedPerpheral:(NSString *)uuidString
{
    NSLog(@"连接断开 ---%@", uuidString);
    if ([[[self.Bluetooth.per identifier] UUIDString] isEqualToString:uuidString] || !self.Bluetooth.per)
        self.Bluetooth.isSysIng = NO;
    
    [self.Bluetooth.dicSysIng removeObjectForKey:uuidString];
    [self.Bluetooth.dicSysEnd removeObjectForKey:uuidString];
    [self Disconneted_Next:uuidString];
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    switch (type) {
        case 204:
            break;
        case 206:           // 一个植物数据同步完成的回调     obj是设备名
        {
            self.Bluetooth.isSysIng = NO;
            [self.Bluetooth.dicSysEnd setObject:@"" forKey:uuidString];
            [self beginSysNext];
            
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject  :self.userInfo.access forKey:@"access"];
            
            NSNumber *plantID = ((FlowerData *)[FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and bind_device_name = %@", self.userInfo.access, (NSString *)obj] inContext:DBefaultContext]).my_plant_id;
            
            // 这里 只上传了 下标为5 的也就是最后一天的 数据  这里因为要使用 平均值 和 数据数量
            NSArray *arrSyn = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == 0 and my_plant_id == %@ and sub == 5", self.userInfo.access, plantID] inContext:DBefaultContext];
            //NSLog(@"count = %d", arrSyn.count);
            
            if (!arrSyn.count)
            {
                NSLog(@"没有需要上传的数据");
                return;
            }
            
            
            NSMutableArray *arrSub = [NSMutableArray new];
            NSMutableDictionary *dicSub;
            for (SyncDate *sn in arrSyn)
            {
                dicSub = [NSMutableDictionary new];
                if (!sn.my_plant_id || !sn.dateValue) {
                    return;  // 这里有问题
                }
                [dicSub setObject:[sn.my_plant_id description] forKey:@"my_plant_id"];
                [dicSub setObject:sn.dateValue forKey:@"k_date"];
                [dicSub setObject:sn.mean_light forKey:@"my_plant_light"];
                [dicSub setObject:sn.mean_ambienttem forKey:@"my_plant_temperature_c"];
                [dicSub setObject:sn.mean_solimois forKey:@"my_plant_humidity"];
                [dicSub setObject:sn.count forKey:@"counts"];
                [dicSub setObject:sn.light forKey:@"light_array"];
                [dicSub setObject:sn.soil_moisture forKey:@"humidity_array"];
                [dicSub setObject:sn.ambient_temperature forKey:@"temperature_c_array"];
                
                [arrSub addObject:[dicSub mutableCopy]];
            }

            
            NSString *jsonString = [self toJsonStringForUpload:arrSub];
            [dic setObject:jsonString forKey:@"my_all_plant_data"];
            
            // 保存上传植物的信息
            if(!self.arrUpdataSynID)
                self.arrUpdataSynID = [NSMutableArray new];
            [self.arrUpdataSynID addObject:plantID];

            __block vcBase *blockSelf = self;
            RequestCheckNoWaring(
                 [net updateMyPlantData:dic];,
                 [blockSelf dataSuccessBack_updateMyPlantData:dic];)
        }
            break;
        case 301:
        {
            // 这里不上传，  在同步完大数据后上传
            NSMutableArray *arr = (NSMutableArray *)obj; //
            NSLog(@"----- 报警， 报警总数 ： %@", @(arr.count));
            if (arr.count > 0)
            {
                NSString *message = [self getLocalMessage:arr];
                [self addLocalNotification:[NSDate date]
                                    repeat:NSCalendarUnitDay
                                 soundName:UILocalNotificationDefaultSoundName
                                 alertBody:message
                applicationIconBadgeNumber:0
                                  userInfo:@{@"remind":message}];
                
                NSString *flowerIDStr = [((Remind *)arr[0]).flower_Id description] ;
                NSMutableDictionary *dicR = [(NSDictionary *)GetUserDefault(RemindCount) mutableCopy];
                NSInteger remindCount = [dicR[flowerIDStr] integerValue];
//                remindCount += arr.count;     // 这里提醒次数 累加 改为  替换
                
                remindCount = arr.count;
                if (flowerIDStr)
                {
                    [dicR setObject:@(remindCount) forKey:flowerIDStr];
                    SetUserDefault(RemindCount, dicR);
                }
                
                if ([flowerIDStr intValue])
                {
                    for(int i = 0; i < arr.count; i++)
                    {
                        Remind *rd = arr[i];
                        [NetTool changeType:5 isFinish:NO];
                        [self.arrUploadRemind addObject:rd];
                    }
                }
                else
                {
                    NSLog(@"---------------------  本地植物的报警通知，不上传");
                }
            }
        }
            break;
            
        default:
            break;
    }
}

// 拼装上传的报警参数
//-(NSMutableDictionary *)makeUploadAlarmDataBeforPost
//{
//    
//    
//    
//    
////    for (Remind *rd in self.arrUploadRemind )
////    {
////        NSLog(@"------ rd.flower_id = %@", rd.flower_Id);
////        if (rd.flower_Id)
////        {
////            dicSub = [NSMutableDictionary new];
////            [dicSub setObject:[rd.flower_Id description]  forKey:@"my_plant_id"];
////            [dicSub setObject:rd.alarm_type forKey:@"alarm_type"];
////            [dicSub setObject:rd.alarm_sub_type forKey:@"alarm_sub_type"];
////            [dicSub setObject:rd.k_date forKey:@"k_date"];
////            [arrSub addObject:[dicSub mutableCopy]];
////        }
////    }
//    
//    NSString *jsonString = [self toJsonStringForUpload:arrSub];
//    
//    [dic setObject:jsonString forKey:@"alarm_arr"];
//    return dic;
//}


// 发现回调后的 接下来操作，
-(void)Found_Next:(NSMutableDictionary *)recivedTxt
{
    for (NSString *uuid in recivedTxt.allKeys)
    {
        if ([self.dicNeedConnet.allKeys containsObject:uuid])
        {
            [self.Bluetooth retrievePeripheral:uuid];
        }
    }
}

// 连接上后 接下来操作，
-(void)Conneted_Next:(NSString *)uuidString
{
    NSLog(@"连接上后 接下来操作，");
}



// 断开连接后 接下来操作，
-(void)Disconneted_Next:(NSString *)uuidString
{

}

//-(void)RetrievePeripheral:(NSString *)uuidString
//{
//    [self.Bluetooth retrievePeripheral:uuidString isRe:NO];
//}

-(void)readValue:(NSString *)va
{
    //[self.Bluetooth readChara:@"41DD4F50-37B1-19BF-BC24-90209DEFE16C" charUUID:@"F202"];
}

-(void)refreshLink:(NSTimer *)timerFu
{
    if (![GetUserDefault(isNotRealNewBLE) boolValue])                       //  这里 因为多线程的关系， 需要再这里判读
    {
        [timerFu stop];
        timerFu = nil;
        return;
    }
    //NSLog(@"--refreshLink-  self.Bluetooth: %@", self.Bluetooth);
    NSArray *arrFlower = [FlowerData findByAttribute:@"access" withValue:self.userInfo.access];
    self.dicNeedConnet = [[NSMutableDictionary alloc] init];
    for (FlowerData *fl in arrFlower)
    {
        //CGFloat a = [[NSDate date] timeIntervalSince1970] - [fl.update_time longLongValue] / 1000;
       // NSLog(@"当前时间-- %f ", [[NSDate date] timeIntervalSince1970]);
        //NSLog(@"------------ 植物的更新时间 -- %lld", [fl.update_time longLongValue] / 1000);
       // NSLog(@" 相距 -- %f", a);
        
        
        if(fl.bind_device_mac.length == 36) //  && [fl.update_time longLongValue]
            [self.dicNeedConnet setObject:fl forKey:fl.bind_device_mac];
    }
    
    if (self.dicNeedConnet.count > 0 && self.dicNeedConnet.count > self.Bluetooth.dicConnected.count)
    {
        if (!lastBeginLinkDate || [[NSDate date] compare:lastBeginLinkDate] >= 0)
        {
            //NSLog(@"------------------------------------------------------------------------------------");
            // 过滤出需要连接的外设
            self.arrNeed = [[NSMutableArray alloc] init];
            for (NSString *uuid in self.dicNeedConnet.allKeys) {
                if (![self.Bluetooth.dicConnected.allKeys containsObject:uuid]) {
                    [self.arrNeed addObject:uuid];
                }
            }
            
            NSTimeInterval inter = self.arrNeed.count * LinkInterverl;
            lastBeginLinkDate = [NSDate dateWithTimeIntervalSinceNow:inter];
            __block vcBase *blockSelf = self;
            NextWait([blockSelf resetTimerAutoLink];, inter);
            
            NSMutableArray *arrCoyp = [self.arrNeed mutableCopy];
            [self.Bluetooth retrievePeripheral:arrCoyp[0]];
            if (arrCoyp.count > 1)
            {
                __block vcBase *blockSelf = self;
                __block NSMutableArray *blockarrCoyp = arrCoyp;
                
                NextWait
                (
                 if (blockarrCoyp.count > 2)
                 {
                     NextWait(
                              [blockSelf.Bluetooth retrievePeripheral:blockarrCoyp[2]];
                              if (blockarrCoyp.count > 3)
                              {
                                  NextWait(
                                           [blockSelf.Bluetooth retrievePeripheral:blockarrCoyp[3]];
                                           , LinkInterverl);
                              }
                              , LinkInterverl);
                 }
                 , LinkInterverl);
            }
        }
    }
    if (self.dicNeedConnet.count == self.Bluetooth.dicConnected.count) {
        //[timerFu stop];
    }
    [self beginSysNext];
}


-(void)resetTimerAutoLink
{
    [self.timerAutoLink stop];
    self.timerAutoLink = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLink:) userInfo:nil repeats:YES];
}

//  链接完成 后开始同步
-(void)beginSysNext
{
    //  && self.dicSysIng.count > 0
//    NSLog(@">>>>>>>>>>>>>>>  isSynIng = %hhd, self.self.dicSysEnd.count = %d,    self.dicSysIng.count = %d  -- %@", self.Bluetooth.isSysIng, self.Bluetooth.dicSysEnd.count, self.Bluetooth.dicSysIng.count, @(self.Bluetooth.dicConnected.count  &&
//          !self.Bluetooth.isSysIng &&
//          (self.Bluetooth.dicSysEnd.count < self.Bluetooth.dicSysIng.count || !self.Bluetooth.dicSysIng)));
    
    if (self.Bluetooth.dicConnected.count  &&
        !self.Bluetooth.isSysIng &&
        (self.Bluetooth.dicSysEnd.count < self.Bluetooth.dicSysIng.count || !self.Bluetooth.dicSysIng))
    {
        self.Bluetooth.isSysIng = YES;
        for (int i = 0 ; i < self.Bluetooth.dicConnected.count ; i++)
        {
            NSString *uuid = self.Bluetooth.dicConnected.allKeys[i];
            if (![self.Bluetooth.dicSysEnd.allKeys containsObject:uuid] && [self.Bluetooth.dicSysIng.allKeys containsObject:uuid])
            {
                __block vcBase *blockSelf = self;
                NextWaitInCurrentTheard([blockSelf.Bluetooth begin:uuid];, 1.2);
                break;
            }
        }
    }
    
        
}


-(void)getFontSize
{
    CGFloat fontsize = 0;
    if (ScreenHeight == 480)
    {
        fontsize = 10;
    }else if(ScreenHeight == 568)
    {
        fontsize = 14;
    }else if(ScreenHeight == 667)
    {
        fontsize = 15;
    }else if(ScreenHeight == 736)
    {
        fontsize = 16;
    }
    fontSize = fontsize;
}

-(void)MatchingFont:(UIView *)view
{
    for (UIView *vw in view.subviews)
    {
        if (vw.subviews.count > 0)
        {
            [self MatchingFont:vw];
        }
        else if([vw isMemberOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)vw;
            if (btn.tag != 948) 
                btn.titleLabel.font = [UIFont systemFontOfSize: fontSize];
        }
        else if([vw isMemberOfClass:[UILabel class]])
        {
            UILabel *lbl = (UILabel *)vw;
            if (lbl.tag != 948)
                lbl.font = [UIFont systemFontOfSize:fontSize];
        }
    }
}

-(void)getTokenAndUpload                                            // 先获取权限， 然后上传
{
    __block vcBase *blockSelf = self;
    RequestCheckNoWaring(
     [net getToken_distribute_server:blockSelf.userInfo.access];,
     [blockSelf dataSuccessBack_getToken_distribute_server:dic];)
}



#pragma mark aLiNetDelegate
-(void)upload:(BOOL)isOver
{
    NSLog(@"上传结果： %@", @(isOver));
    NSString *url = [self.alinet.ossUploadData getResourceURL];
    NSLog(@"url :%@", url);
    self.imgdata = nil;
    self.imgType = nil;
    self.upLoad_Next(isOver ? url : @"");
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(NSString *)getLocalMessage:(NSArray *)arr
{
    FlowerData *fd = [FlowerData findFirstByAttribute:@"my_plant_id" withValue:((Remind *)arr[0]).flower_Id inContext:DBefaultContext];
    NSMutableString *message = [NSMutableString new];
    [message appendString:[NSString stringWithFormat:@"%@ :", fd.my_plant_name]];
    for (int i = 0; i < arr.count; i++)
    {
        Remind *model = arr[i];
        if ([model.alarm_type isEqualToString:@"02"])
        {
            if([model.alarm_sub_type isEqualToString:@"00"])
            {
                [message appendString: Remind_Mini_Light_Low];
                [message appendString:@"; "];
            }
            else
            {
                [message appendString: Remind_Mini_Light_Hight];
                [message appendString:@"; "];
            }
        }
        else if ([model.alarm_type isEqualToString:@"03"])
        {
            if([model.alarm_sub_type isEqualToString:@"00"])
            {
                [message appendString: Remind_Mini_Tem_LowEst];
                [message appendString:@"; "];
            }
            else if([model.alarm_sub_type isEqualToString:@"01"])
            {
                [message appendString: Remind_Mini_Tem_Low];
                [message appendString:@"; "];
            }
            else if([model.alarm_sub_type isEqualToString:@"02"])
            {
                [message appendString: Remind_Mini_Tem_Hight];
                [message appendString:@"; "];
            }
            else
            {
                [message appendString: Remind_Mini_Tem_HightEst];
                [message appendString:@"; "];
            }
        }
        else if ([model.alarm_type isEqualToString:@"04"])
        {
            if([model.alarm_sub_type isEqualToString:@"00"])
            {
                [message appendString: Remind_Mini_Soil_Low];
                [message appendString:@"; "];
            }
            else
            {
                [message appendString: Remind_Mini_Soil_Hight];
                [message appendString:@"; "];
            }
        }
    }
    return (NSString *)message;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)showMessage:(NSString *)message
{
    NextWait(
         NSLog(@"showMessage %@", [NSThread currentThread]);
         [[[LxxPlaySound alloc] initForPlayingVibrate] play];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
         [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Leo" icon:nil];
         LNNotification* notification = [LNNotification notificationWithMessage:message];
         notification.title = @"Aerocom";
         [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];, 0);
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)notificationWasTapped:(NSNotification*)notification
{
    
}

-(void)alertBecauseFirstBind
{
    NSLog(@"----- > 是否第一次绑定");
    if(!GetUserDefault(FirstBindding))
    {
        NSLog(@"----- > 是");
        NextWait(
                 [[GUAAlertView alertViewWithContentView:({
                    CGRect rect = IPhone4 ? CGRectMake(0, 40, 250, 335) : CGRectMake(0, 40, 270, 394);
                    UIImageView *imv = [[UIImageView alloc] initWithFrame:rect];
                    switch ([self getPreferredLanguage]) {
                        case 1:
                            imv.image =[UIImage imageNamed:@"firstBindShow_zh"];
                            break;
                        case 2:
                            imv.image =[UIImage imageNamed:@"firstBindShow_en"];
                            break;
                        case 3:
                            imv.image =[UIImage imageNamed:@"firstBindShow_fr"];
                            break;
                            
                        default:
                            break;
                    }
                    imv;
                }) buttonTouchedAction:^{
                    NSLog(@"button touched");
                } dismissAction:^{
                    NSLog(@"dismiss");
                }] show];
                 , 0);
        SetUserDefault(FirstBindding, @1);
    }
    else
    {
        NSLog(@"----- > 不是");
    }
}

-(void)setBar
{
    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    statusBarView.backgroundColor = RGB(118, 152, 98);// [UIColor greenColor]; //
    [self.view addSubview:statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    LSNavigationController *lnav = (LSNavigationController *)self.navigationController;
    [lnav.navigationBar setBackgroundImage:[UIImage imageFromColor:RGB(118, 152, 98)] forBarMetrics:UIBarMetricsDefault];
    lnav.navigationBar.shadowImage = [UIImage imageFromColor:RGB(118, 152, 98)];
    [lnav refreshBackgroundImage];
}

-(void)realSyn
{
    //NSLog(@"现在时间：%@， 分：%@", [NSDate date], @([[NSDate date] getFromDate:5]));
    int minute = (int)[[NSDate date] getFromDate:5];
    if (!self.Bluetooth.isSysIng && (minute == 2 || minute == 22 || minute == 42)) //  == 2  每当现在时刻的分钟为2时，大同步一次
    {
        NSLog(@"----------- > 时间到， 重新同步");
        [self.Bluetooth.dicSysEnd removeAllObjects];
        [self.Bluetooth.dicSysIng removeAllObjects];
        if(!self.Bluetooth) self.Bluetooth = [BLEManager sharedManager];
        for (int i = 0; i < self.Bluetooth.dicConnected.count; i++)
        {
            [self.Bluetooth.dicSysIng setObject:@"" forKey:self.Bluetooth.dicConnected.allKeys[i]];
        }
        [self beginSysNext];
        
        [timerRealSys time_pause];
        NextWait([timerRealSys time_continue];,15 * 60); // 60 * 60
    }
}

-(void)changeNavigationBar:(UIColor *)color        // 改变导航条的颜色
{
    LSNavigationController *lnav = (LSNavigationController *)self.navigationController;
    [lnav.navigationBar setBackgroundImage:[UIImage imageFromColor:color] forBarMetrics:UIBarMetricsDefault];
    lnav.navigationBar.shadowImage = [UIImage imageFromColor:color];
    [lnav refreshBackgroundImage];
}

@end
