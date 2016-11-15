//
//  BLEManager.m
//  BLE
//
//  Created by 丁付德 on 15/5/24.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import "BLEManager.h"
#import "BLEManager+Helper.h"

static BLEManager *manager;
@interface BLEManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@end

@implementation BLEManager

+(BLEManager *)sharedManager
{
    @synchronized(self)
    {
        if (!manager)
        {
            manager = [[BLEManager alloc] init];
            
            manager -> dic = [[NSMutableDictionary alloc] init];
            manager -> dicSysData = [[NSMutableDictionary alloc] init];
            
            manager -> beginDate = [NSDate date];
            manager -> num = 0;
            manager.connetNumber = 100000000;
            manager.connetInterval = 1;
        
            manager.dicConnected = [[NSMutableDictionary alloc] init];
            manager.isFailToConnectAgain = YES;
            manager.isSendRepeat = NO;
        }
        return manager;
    }
}

-(void)startScan
{
    if (self.Bluetooth.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙中心设备没开启");
        return;
    }
    if(!self.isNotSearch)
    {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.xinyi.aerocom", DISPATCH_QUEUE_SERIAL);
        if (!self.Bluetooth)
            self.Bluetooth = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
        self.Bluetooth.delegate = self;
        dic = [[NSMutableDictionary alloc]init];
        [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    }
}

-(void)startScanNotInit
{
    if (self.Bluetooth.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙中心设备没开启");
        return;
    }
    self.Bluetooth.delegate = self;
    dic = [[NSMutableDictionary alloc]init];
    [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)stopScan
{
    if (self.Bluetooth)
    {
        //NSLog(@"扫描结束");
        [self.Bluetooth stopScan];
    }
}

- (void)connectDevice:(CBPeripheral *)peripheral
{
    if (peripheral && !self.isNotSearch) {
        [_Bluetooth connectPeripheral:peripheral options:nil];
    }
}

-(void)stopLink:(CBPeripheral *)peripheral
{
    self.isFailToConnectAgain = NO;
    __block BLEManager *blockSelf = self;
    NextWaitInCurrentTheard(blockSelf.isFailToConnectAgain = YES;, 3);
    if (peripheral)
    {
        [_Bluetooth cancelPeripheralConnection:peripheral];
        [self.dicConnected removeObjectForKey:[[peripheral identifier] UUIDString]];
    }
    else
    {
        for (int i = 0; i < self.dicConnected.count ; i++)
            [_Bluetooth cancelPeripheralConnection:self.dicConnected.allValues[i]];
    }
}

+ (BLEManager *)returnNil
{
    @synchronized(self)
    {
        if (manager)
        {
            manager = nil;
        }
        return manager;
    }
}

/**
 *  自动连接
 *
 *  @param uuidString uuidString
 */
-(void)retrievePeripheral:(NSString *)uuidString
{
    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:uuidString];
    if(nsUUID)
    {
        NSArray *peripheralArray = [self.Bluetooth retrievePeripheralsWithIdentifiers:@[nsUUID]];
        //NSLog(@"uuidArray.count=%lu", (unsigned long)peripheralArray.count);
        if([peripheralArray count] > 0)
        {
            for(CBPeripheral *peripheral in peripheralArray)
            {
                peripheral.delegate = self;
                [self stopScan];
                [self startScan];
                __block BLEManager *blockSelf = self;
                __block CBPeripheral *blockperipheral= peripheral;
                NextWaitInCurrentTheard(
                    [blockSelf connectDevice:blockperipheral];
                    ,0.5);
            }
        }
        else
        {
            CBUUID *cbUUID = [CBUUID UUIDWithNSUUID:nsUUID];
            NSArray *connectedPeripheralArray = [self.Bluetooth retrieveConnectedPeripheralsWithServices:@[cbUUID]];
            //NSLog(@"cuuidArray.count=%lu", (unsigned long)connectedPeripheralArray.count);
            if([connectedPeripheralArray count] > 0)
            {
                for(CBPeripheral *peripheral in connectedPeripheralArray)
                {
                    peripheral.delegate = self;
                    [self connectDevice:peripheral];
                }
            }
            else
            {
                //NSLog(@"自动连接--- 重新扫描");
                [self startScan];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([dic.allKeys containsObject:uuidString]) {
                        //NSLog(@"已经找到--- 开始连接");
                        [self connectDevice:dic[uuidString]];
                    }
                });
            }
        }
    }
}


#pragma mark - CBCentralManagerDelegate 中心设备代理

/**
 *  当Central Manager被初始化，我们要检查它的状态，以检查运行这个App的设备是不是支持BLE
 *
 *  @param central 中心设备
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (_Bluetooth.state) {
        case CBCentralManagerStatePoweredOff:
        {
            // 蓝牙未打开
            SetUserDefault(BLEisON, @(0));
            [self.dicConnected removeAllObjects];
        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            // 开始扫描
            [_Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            SetUserDefault(BLEisON, @(1));
        }
            break;
        default:
            break;
    } 
}


/**
 *  扫描到设备的回调
 *
 *  @param central           中心设备
 *  @param peripheral        扫描到的外设
 *  @param advertisementData 外设的数据集
 *  @param RSSI              信号
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"peripheral.name : %@", peripheral.name);
//    NSLog(@"%@", advertisementData);
    
//    float juli = powf(10, (abs([RSSI integerValue]) - 59) / (10 * 2.0));
//    NSLog(@"设备名称 : %@  距离 %.1f米", peripheral.name, juli);
    
    if (peripheral.name && ([peripheral.name rangeOfString:areocom_Plant_Name].length || [peripheral.name rangeOfString:areocom_Plant_other_Name].length))
    {
        if ([peripheral respondsToSelector:@selector(identifier)]) {
            [dic setObject:peripheral forKey:[peripheral.identifier UUIDString]];
        }
    }
    
    if (dic.count > 0 && [self.delegate respondsToSelector:@selector(Found_CBPeripherals:)])
        [self.delegate Found_CBPeripherals:dic];
}


/**
 *  连接设备成功的方法回调
 *
 *  @param central    中央设备
 *  @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.Bluetooth stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];      // 扫描服务
    
    NSString *uuidString = [peripheral.identifier UUIDString];
    [self.dicConnected setObject:peripheral forKey:uuidString];
    
    if ([self.delegate respondsToSelector:@selector(CallBack_ConnetedPeripheral:)])
    {
        [self.delegate CallBack_ConnetedPeripheral:uuidString];
    }
    //NSLog(@"连接成功了, uuidString: %@", [[peripheral identifier] UUIDString]);
}


/**
 *  连接失败的回调
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"无法连接");
    if (self.isFailToConnectAgain)
        [self beginLinkAgain:peripheral];
}

// 此方法
/**
 *  当已经建立的连接被断开时调用。这个方法在connectPeripheral：options方法建立的连接断开是调用，如果断开连接不是有cancelPeripheralConnection方法发起的，那么断开连接的详细信息就在error参数中，当这个方法被调用只有peripheral代理中的方法不在被调用。注意：当peripheral断开连接时，peripheral所有的service、characteristic、descriptors都无效
 */

/**
 *  被动断开
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接被断开了");
    
    NSString *uuidString = [[peripheral identifier] UUIDString];
    [self.dicConnected setObject:peripheral forKey:uuidString];
    
    [self.dicConnected removeObjectForKey:uuidString];
    if ([self.delegate respondsToSelector:@selector(CallBack_DisconnetedPerpheral:)])
        [self.delegate CallBack_DisconnetedPerpheral:uuidString];
    if (self.isFailToConnectAgain)
        [self beginLinkAgain:peripheral];
}

/**
 *  发现服务 扫描特性
 *
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        peripheral.delegate = self;
        for (CBService *service in peripheral.services)
        {
            [peripheral discoverCharacteristics:nil forService:service];  // 扫描特性
        }
    }
    else
    {
        //NSLog(@"error:%@",error);
    }
}

/**
 *  发现特性 订阅特性
 *
 *  @param peripheral 外设
 *  @param service    服务
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error//4
{
    if (!error)
    {
        for (CBCharacteristic *chara in [service characteristics])
        {
            
            NSString *uuidString = [chara.UUID UUIDString];
            if ([Arr_R_UUID containsObject:uuidString]) {
                [peripheral setNotifyValue:YES forCharacteristic:chara];   // 订阅特性
            }
        }
    }
}


/**
 *  订阅结果回调，我们订阅和取消订阅是否成功
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        //NSLog(@"error  %@",error.localizedDescription);
    }
    else
    {
        [peripheral readValueForCharacteristic:characteristic];
        //读取服务 注意：不是所有的特性值都是可读的（readable）。通过访问 CBCharacteristicPropertyRead 可以知道特性值是否可读。如果一个特性的值不可读，使用 peripheral:didUpdateValueForCharacteristic:error:就会返回一个错误。
    }
    
//    NSString *uuidString = [characteristic.UUID UUIDString];
//      如果不是我们要特性就退出
//    if (![uuidString isEqualToString:FeiTu_TIANYIDIAN_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNZU_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNDONG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNCHENG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNHUAN_ReadUUID])
//    {
//        return;
//    }
    
    if (characteristic.isNotifying)
    {
        //NSLog(@"外围特性通知开始");
    }
    else
    {
        //NSLog(@"外围设备特性通知结束，也就是用户要下线或者离开%@",characteristic);
    }
}


/**
 *  当我们订阅的特性值发生变化时 （ 就是， 外设向我们发送数据 ）
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error//6
{
    NSData *data = characteristic.value;
    NSString *uu = [characteristic.UUID UUIDString];
    //[data LogDataAndPrompt:uu];
    if ([Arr_R_UUID containsObject:uu])
    {
        [self setData:data peripheral:peripheral charaUUID:uu];
    }
}

-(void)readChara:(NSString *)uuidString charUUID:(NSString *)charUUID;
{
    CBPeripheral * cbp = self.dicConnected[uuidString];
    
     NSArray *arry = [cbp services];
     for (CBService *ser in arry)
     {
         NSString *serverUUID = [ser.UUID UUIDString];
         if ([serverUUID isEqualToString:ServerUUID])
         {
             for (CBCharacteristic *chara in [ser characteristics])
             {
                 NSString *cUUID = [chara.UUID UUIDString];
                 if ([cUUID isEqualToString:charUUID])
                 {
                     //NSLog(@"开始读 %@，  %@", uuidString, charUUID);
                     [cbp readValueForCharacteristic:chara];
                     break;
                 }
             }
         }
     }
}
         
-(void)setData:(NSData *)data peripheral:(CBPeripheral *)peripheral charaUUID:(NSString *)charaUUID
{
    //  流程   连接 -》 检查时间（如果时间不对，写入时间  202） - 》 读取当天（205） -》 读取记录(204) -> 写入记录（204） -》 读取环境（206）
    
    NSString *uuid = [[peripheral identifier] UUIDString];
    Byte *bytes = (Byte *)data.bytes;
    if ([self checkData:data])
    {
        if ([charaUUID isEqualToString:RW_Datetime_UUID])
        {
            self.isBeginOK = YES;
//            static BOOL isSoQuick = NO;
//            if (!isSoQuick) {
//                isSoQuick = YES;
//                [self performBlockInCurrentTheard:^{
//                    isSoQuick = NO;
//                } afterDelay:100];
//            }
//            else
//            {
//                NSLog(@"多条的重复数据， 不用处理");
//                return;
//            }
            
            [data LogDataAndPrompt:@"尼玛----------"];
            NSNumber *year = [NSNumber numberWithInt:2000 + bytes[1]];
            NSNumber *month = [NSNumber numberWithInt:1 + bytes[2]];
            NSNumber *day = [NSNumber numberWithInt:1 + bytes[3]];
            NSNumber *hour = [NSNumber numberWithInt:bytes[4]];
            NSNumber *minute = [NSNumber numberWithInt:bytes[5]];
            NSNumber *second = [NSNumber numberWithInt:bytes[6]];
            NSMutableArray *arrNumb = [[NSMutableArray alloc] initWithObjects:year, month, day, hour, minute, second, nil];
            NSDate *date = [self getDateFromInt:arrNumb];
            
            NSLog(@"---- 解析后的时间为 :%@", date);
            NSDate *now = [NSDate date];
            now = [now getNowDateFromatAnDate:now];
            double inter = [now timeIntervalSinceDate:date];
            
            NSLog(@"间隔：%f", inter);
            NSString *uuid = [[peripheral identifier] UUIDString];
            if (fabs(inter) > 60)
            {
                [self setDate:uuid];   // 先重新设置时间后， 间隔一段时间，后再同步   // 写完， 读
                sleep(dataInterval);
                [self readChara:uuid charUUID:RW_Datetime_UUID];
            }
            else
                [self sysToday:uuid];
            
        }
        else if([charaUUID isEqualToString:R_LastDay_UUID])
        {
            static int numBack[6] = { 9 , 9 , 9 , 9 , 9 , 9 };  // 回来的时候， 一天的数据 分成了 6条， 每条是4个小时的
            static int ambient_temperature[24]; // 环境温度
            static int soil_moisture[24];       // 土壤湿度
            static int light[24];               // 环境光照
            
            int sub = bytes[2];
            numBack[sub] = sub;
            
            NSLog(@"sub = %d", sub);
            
            for (int i = 0; i < 4; i++)
            {
                // 如果为0 不赋值  如果不为 0 ， 后面的 直到当前小时， 全部赋值
                int temp = bytes[i * 4 + 4];
                if (temp > 0)
                {
                    for (int j = 0; j < 24 - sub  * 4 - i; j++)
                    {
                        ambient_temperature[sub * 4 + i + j] = bytes[i * 4 + 4];
                        soil_moisture[sub * 4 + i + j] = bytes[i * 4 + 5];
                        light[sub * 4 + i + j] = bytes[i * 4 + 6];
                    }
                }
            }
            
            NSDate * now = [NSDate date];
            int dateValue = [self HmF2KNSDateToInt:now];
            NSInteger year = [now getFromDate:1];
            NSInteger month = [now getFromDate:2];
            NSInteger day = [now getFromDate:3];
            
            // 当天数据 的当前小时候的数据，一律为0  这里出现了未覆盖  已经OK
            NSInteger hourThis = [[NSDate date] getFromDate:4];         // 当前的小时
            for(NSInteger j = hourThis; j < 24; j++)
                ambient_temperature[j] = soil_moisture[j] = light[j] = 0;
            
            FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bind_device_mac == %@ and access == %@", uuid, myUserInfo.access] inContext:DBefaultContext];
            
            NSNumber *subNum = @(sub);
            NSNumber *dateValueNum = @(dateValue);
            
            //NSArray *arrSyn_0 = [SyncDate findAll];
            //NSLog(@"arrSyn_0.cout = %lu", (unsigned long)arrSyn_0.count);
            
            // 检查本地是否已经保存了
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
            {
                NSInteger numFromLocal = [[SyncDate numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"my_plant_id == %@ and access == %@ and sub == %@ and dateValue == %@", fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T, myUserInfo.access, subNum, dateValueNum] inContext:localContext] integerValue];
                if (numFromLocal == 0)
                {
                    SyncDate *syn = [SyncDate MR_createEntityInContext:localContext];
                    syn.my_plant_id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
                    syn.access = myUserInfo.access;
                    syn.sub = subNum;
                    syn.year = @(year);
                    syn.month = @(month);
                    syn.day = @(day);
                    //NSLog(@"最后一天 : %ld", (long)day);
                    syn.dateValue = dateValueNum;
                    syn.isUpload = @(NO);
                    
                    syn.ambient_temperature = [self intArrayToString:ambient_temperature length:24];
                    syn.soil_moisture = [self intArrayToString:soil_moisture length:24];
                    syn.light = [self intArrayToString:light length:24];
                    
                    syn.mean_ambienttem = @([self intArrayToAVG:ambient_temperature length:24]);
                    syn.mean_solimois = @([self intArrayToAVG:soil_moisture length:24]);
                    syn.mean_light = @([self intArrayToAVG:light length:24]);
                    NSLog(@"写入本地");
                    DLSave;
                    DBSave;
                }
                else
                {
                    NSLog(@"本地已经存在");
                }
                
                NSLog(@"arr.cout = %lu", (unsigned long)([SyncDate findAllInContext:DBefaultContext]).count);
                
                static BOOL islock = NO;
                BOOL isHas0 = [self intArrayIsHas0:numBack value:9 length:6];
                if (isHas0){
                    [self sysToday:uuid];
                }
                else if(!isHas0)  // 进行下一次同步大数据
                {
                    islock = YES;
                    [self readChara:uuid charUUID:R_Record_UUID];
                    
                    NextWaitInCurrentTheard(islock = NO;, dataInterval);
                }
            }];
        }
        else if([charaUUID isEqualToString:R_Record_UUID]) // R_Record_UUID
        {
            [data LogData];
            NSMutableArray *arr = [NSMutableArray new];
            NSMutableArray *arrDate = [NSMutableArray new];
            NSMutableArray *arrCount = [NSMutableArray new];
            for (int i = 0; i < 16; i+=4)
            {
                int dataInt_1 = ( bytes[i+3] << 8 ) | bytes[i+2];
                int dataInt_2 = ( bytes[i+5] << 8 ) | bytes[i+4];
                NSNumber *num_1 = [NSNumber numberWithInt:dataInt_1];
                [arr addObject:num_1];
                NSNumber *num_2 = [NSNumber numberWithInt:dataInt_2];
                [arrCount addObject:num_2];
                
                NSMutableArray *arrNum = [self HmF2KIntToDate:dataInt_1];
                NSDate *date = [self getDateFromInt:arrNum];
                
                //NSLog(@"------------------------- date : %@  dataInt : %d", date, dataInt_1);
                [arrDate addObject:date];
            }
            
            
            NSMutableArray *arr_1 = dicSysData[uuid];  // 获取这个外设的存放数组  1： count(5661)  2: 日期  3: 数据统计情况
            if (!arr_1)
            {
                arr_1 = [NSMutableArray new];
                [dicSysData setObject:arr_1 forKey:uuid];
            }
            
            if (bytes[1] == 0x00)
            {
                if (arr_1.count == 0)
                {
                    [arr_1 addObject:arr];
                    [arr_1 addObject:arrDate];
                    [arr_1 addObject:arrCount];
                }
                else if (arr_1.count == 3)
                {
                    NSMutableArray *arrFrom_1 = arr_1[0];
                    if (arrFrom_1.count != 8)
                    {
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)];
                        [arrFrom_1 insertObjects:arr atIndexes:indexSet];
                        
                        NSMutableArray *arrFrom_2 = arr_1[1];
                        [arrFrom_2 insertObjects:arrDate atIndexes:indexSet];
                        
                        NSMutableArray *arrFrom_3 = arr_1[2];
                        [arrFrom_3 insertObjects:arrCount atIndexes:indexSet];
                    }
                }
            }
            else if (bytes[1] == 0x01)
            {
                if (arr_1.count == 0)
                {
                    [arr_1 addObject:arr];
                    [arr_1 addObject:arrDate];
                    [arr_1 addObject:arrCount];
                }
                else if (arr_1.count == 3)
                {
                    NSMutableArray *arrFrom_1 = arr_1[0];
                    if (arrFrom_1.count != 8)
                    {
                        [arrFrom_1 addObjectsFromArray:arr];
                        
                        NSMutableArray *arrFrom_2 = arr_1[1];
                        [arrFrom_2 addObjectsFromArray:arrDate];
                        
                        NSMutableArray *arrFrom_3 = arr_1[2];
                        [arrFrom_3 addObjectsFromArray:arrCount];
                    }
                }
            }
            // 当装满8个的时候
            NSMutableArray *arrFrom = arr_1[0];
            
            if (arrFrom.count == 8)
            {
                todayIndexInSysData = [self getBiggestIndexInArray:arrFrom];
                NSArray *arrData = [self set204Data:arr_1 uuid:uuid];
                
                NSLog(@"%@", arr_1);
                
                NSData *data204 = arrData[0];
                //[data204 LogData];
                shieldCountOfDay = [self isAllShield:data204];
                
                [self Command:data204 uuidString:uuid charaUUID:R_Record_UUID];  // 发送 屏蔽标识
                
                if (shieldCountOfDay.count < 8) // 888888                                   // 如果没有全部屏蔽， 开始同步
                {
                    __block BLEManager *blockSelf = self;
                    NextWaitInCurrentTheard(
                        NSLog(@"开始读取大数据");
                        [blockSelf readChara:uuid charUUID:R_Environment_UUID];, dataInterval);           // 读取环境信息
   
                }
                else                            // 这里说明 已经全部屏蔽了， 结束了 开始回调
                {
                    [self.delegate CallBack_Data:206 uuidString:uuid obj:peripheral.name];
                }
            }
            else if(arrFrom.count == 4)
            {
                NSLog(@"回来了4个记录数据， 再次读取");
                [self readChara:uuid charUUID:R_Record_UUID];                    // 如果 接受了4个   就再次读取
            }
        }
        else if([charaUUID isEqualToString:R_Environment_UUID])
        {
            static BOOL isRevice = NO;   // 停止接收
            if (isRevice)
            {
                NSLog(@"// 停止接收");
                return;
            }
            
            static int indexData[8] = { 9 ,9 ,9 ,9 ,9 ,9 ,9 ,9 };   // 记录状态8条数据中的排序位置（0-7）
            if (shieldCountOfDay.count)                             // 把屏蔽的数过滤掉
            {
                for (int i = 0; i < shieldCountOfDay.count; i++)
                {
                    int j = [shieldCountOfDay[i] intValue];
                    indexData[j] = j;
                }
            }
            
            static int indexSub[6] = { 9 ,9 ,9 ,9 ,9 ,9 };          // 一天6条数据中的第几条
            
            int indexDataInt = bytes[1] ? bytes[1] : 0;             // 在8天数据中的索引
            int indexSubInt = bytes[2] ? bytes[2] : 0;              // 在一天数据中 6条数据的索引
            //NSLog(@"这是第 %d 天的数据第 %d 条数据", indexDataInt, indexSubInt);
            [data LogDataAndPrompt:[NSString stringWithFormat:@"这是第 %d 天的数据第 %d 条数据", indexDataInt, indexSubInt]];

            
            static int ambient_temperature_E[24]; // 环境温度
            static int soil_moisture_E[24];       // 土壤湿度
            static int light_E[24];               // 环境光照
            
            indexData[indexDataInt] = indexDataInt;
            indexSub[indexSubInt] = indexSubInt;

            
            for (int i = 0; i < 4; i++)
            {
                // 如果为0 不赋值  如果不为 0 ， 后面的 直到当前小时， 全部赋值   (解决了问题：   掉包的情况， 数据取自上一个小时 )
                int temp = bytes[i * 4 + 4];
                if (temp > 0)
                {
                    for (int j = 0; j < 24 - i - indexSubInt * 4; j++)
                    {
                        ambient_temperature_E[indexSubInt * 4 + i + j] = bytes[i * 4 + 4];
                        soil_moisture_E[indexSubInt * 4  + i + j] = bytes[i * 4 + 5];
                        light_E[indexSubInt * 4  + i + j] = bytes[i * 4 + 6];
                    }
                }
                else if(i == 0 && temp == 0 && indexSubInt == 0 && todayIndexInSysData == indexDataInt) // 今天 0时更新了数据
                {
                    for(int j = 0; j < 24; j++)
                        ambient_temperature_E[j] = soil_moisture_E[j] = light_E[j] = 0;
                }
            }
            
            // 当天数据 的当前小时候的数据，一律为0  这里出现了未覆盖  已经OK
            NSInteger hourThis = [[NSDate date] getFromDate:4];         // 当前的小时
            if (todayIndexInSysData == indexDataInt) {
                for(NSInteger j = hourThis; j < 24; j++)
                    ambient_temperature_E[j] = soil_moisture_E[j] = light_E[j] = 0;
            }
            
            
            NSDate *dateFromDic = dicSysData[uuid][1][indexDataInt]; // 保存的记录信息
            NSNumber *dataCount = dicSysData[uuid][2][indexDataInt];
            
            int dateValue = [self HmF2KNSDateToInt:dateFromDic];
            NSInteger year = [dateFromDic getFromDate:1];
            NSInteger month = [dateFromDic getFromDate:2];
            NSInteger day = [dateFromDic getFromDate:3];
            
            FlowerData *fd = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bind_device_mac == %@ and access == %@", uuid, myUserInfo.access] inContext:DBefaultContext];
            
            NSNumber *subNum = @(indexSubInt);
            NSNumber *dateValueNum = @(dateValue);
            
            //NSArray *arrSyn_0 = [SyncDate findAll];
            //NSLog(@"arrSyn_0.cout = %lu", (unsigned long)arrSyn_0.count);
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
            {
                // 检查本地是否已经保存了
                SyncDate *syn = [SyncDate findFirstWithPredicate:[NSPredicate predicateWithFormat:@"my_plant_id == %@ and access == %@ and sub == %@ and dateValue == %@", fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T, myUserInfo.access, subNum, dateValueNum] inContext:localContext];
                if (!syn)
                {
                    syn = [SyncDate MR_createEntityInContext:localContext];
                    NSLog(@"写入本地");
                }
                syn.my_plant_id = fd.my_plant_id ? fd.my_plant_id : fd.my_plant_id_T;
                syn.access = myUserInfo.access;
                syn.sub = subNum;
                syn.year = @(year);
                syn.month = @(month);
                syn.day = @(day);
                syn.dateValue = dateValueNum;
                syn.isUpload = @(NO);

                syn.ambient_temperature = [self intArrayToString:ambient_temperature_E length:24];
                syn.soil_moisture = [self intArrayToString:soil_moisture_E length:24];
                syn.light = [self intArrayToString:light_E length:24];
                syn.count = dataCount;
                
                
                if (year == [[NSDate date] getFromDate:1] && month == [[NSDate date] getFromDate:2 && day == [[NSDate date] getFromDate:3]]) {
                    syn.mean_ambienttem = @([self intArrayToAVG:ambient_temperature_E length:(int)day]);
                    syn.mean_solimois = @([self intArrayToAVG:soil_moisture_E length:(int)day]);
                    syn.mean_light = @([self intArrayToAVG:light_E length:(int)day]);
                }else
                {
                    syn.mean_ambienttem = @([self intArrayToAVG:ambient_temperature_E length:24]);
                    syn.mean_solimois = @([self intArrayToAVG:soil_moisture_E length:24]);
                    syn.mean_light = @([self intArrayToAVG:light_E length:24]);
                }

                
                // 如果这个 shieldCountOfDay.count > 1 说明，昨天的数据， 没有同步  要计算昨天的分数
                // 这里算出每一天的得分好了  最后一天（也就是今天的数据 不完整 分数是错误的）
                
                
                NSInteger ind = todayIndexInSysData - 1 < 0 ? 7 : todayIndexInSysData - 1;
                //if([subNum integerValue] == 5)                                  //  调试用
                if([subNum integerValue] == 5 && ind  == indexDataInt)        //  最终版
                    syn.score = fd.score = [self getScore:syn];
                DLSave
                DBSave;
                
                //NSArray *arrSyn = [SyncDate findAll];
                //NSLog(@"arr.cout = %lu", (unsigned long)arrSyn.count);
                
                BOOL isSubHas9 = [self intArrayIsHas0:indexSub value:9 length:6];
                if (!isSubHas9) {
                    for (int i = 0; i < 6; i++) {
                        indexSub[i] = 9;
                    }
                }
                
                BOOL isDateHas9 = [self intArrayIsHas0:indexData value:9 length:8];
                if (isDateHas9 || isSubHas9){
                    [self readChara:uuid charUUID:R_Environment_UUID];
                }
                else if (!isSubHas9)                                                                 // 同步结束，  全部清空
                {
                    for (int i = 0; i < 8; i++)
                    {
                        indexData[i] = 9;
                        if(i < 6)
                            indexSub[i] = 9;
                    }
                    
                    [self.delegate CallBack_Data:206 uuidString:uuid obj:peripheral.name];
                    //  同步结束， 根据昨天的数据， 写入提醒表
                    [self writeDataInRemind:uuid];
                    
                    // 停止接收  1秒后再开启
                    isRevice = YES;
                    NextWaitInCurrentTheard(isRevice = NO;, 1);
                }
            }];
        }
        else if([charaUUID isEqualToString:R_RealTime_UUID])
        {
//            int hour = bytes[3];
//            int minute = bytes[4];
//            int second = bytes[5];
            int temp = bytes[7];
            int soil = bytes[8];
            int light = bytes[9];
            
            //NSLog(@"hour = %d, minute = %d, second = %d, temp = %d, soil = %d, light = %d", hour, minute, second, temp, soil, light);
            NSArray *array = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", light],
                              [NSString stringWithFormat:@"%d", soil],
                              [NSString stringWithFormat:@"%d", temp - 50],
                              nil];
            [self.delegate CallBack_Data:207 uuidString:uuid obj:array];
        }
    }
}


// 写入时间
-(void)setDate:(NSString *)uuidString
{
    NSDate *now = [NSDate date];
    NSLog(@"now:%@", now);
    NSUInteger year = [now getFromDate:1];
    NSUInteger month = [now getFromDate:2];
    NSUInteger day = [now getFromDate:3];
    NSUInteger hour = [now getFromDate:4];
    NSUInteger minute = [now getFromDate:5];
    NSUInteger second = [now getFromDate:6];
    
    char data[8];
    data[0] = DataFirst;
    data[1] = (year - 2000) & 0xFF;
    data[2] = (month - 1) & 0xFF;
    data[3] = (day - 1) & 0xFF;
    data[4] = hour & 0xFF;
    data[5] = minute & 0xFF;
    data[6] = second & 0xFF;
    
    int sum = 0;
    for (int i = 1; i < 7; i++) {
        sum += (data[i]) ^ i;
    }
    data[7] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:8];
    [self Command:dataPush uuidString:uuidString charaUUID:RW_Datetime_UUID];
}



/**
 *  写入数据
 *
 *  @param data      数据集
 *  @param charaUUID  写入的特性值
 */
-(void)Command:(NSData *)data uuidString:(NSString *)uuidString charaUUID:(NSString *)charaUUID
{
    self.per = self.dicConnected[uuidString];
    NSArray *arry = [self.per services];
    for (CBService *ser in arry)
    {
        NSString *serverUUID = [ser.UUID UUIDString];
        if ([serverUUID isEqualToString:ServerUUID])
        {
            for (CBCharacteristic*chara in [ser characteristics])
            {
                if ([[chara.UUID UUIDString] isEqualToString:charaUUID])
                {
                    NSString *uuid = [[self.per identifier] UUIDString];
                    [data LogDataAndPrompt:uuid promptOther:[NSString stringWithFormat:@" - %@ -- >", charaUUID]];
                    [self.per writeValue:data
                       forCharacteristic:chara
                                    type:CBCharacteristicWriteWithResponse];
                    break;
                }
            }
            break;
        }
    }
}




// ------------------------------------------------------------------------------

// ----------------------------- 私有方法 ----------------------------------------

// ------------------------------------------------------------------------------

/**
 *  开始断开重连
 *
 *  @param peripheral 要重新连接的设备
 */
//-(void)beginLinkAgain:(CBPeripheral *)peripheral
//{
//    NSDate *now = [NSDate date];
//    if ([now timeIntervalSinceDate:beginDate] > self.connetInterval && num < self.connetNumber)
//    {
//        NSLog(@"-------- 再次连接");
//        [self startScan];
//        NextWaitInCurrentTheard([self.Bluetooth connectPeripheral:peripheral options:nil];, 0.5);
//        beginDate = [NSDate date];
//        num ++;
//    }
//    else if(num == self.connetNumber)
//        NextWaitInCurrentTheard(num = 0;, 1);
//}

-(void)beginLinkAgain:(CBPeripheral *)peripheral
{
    NSTimer *timR;
    timR = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(link:) userInfo:peripheral repeats:YES];
    //[self.Bluetooth connectPeripheral:peripheral options:nil];
}

-(void)link:(NSTimer *)timerR
{
    CBPeripheral *cp = timerR.userInfo;
    [self.Bluetooth connectPeripheral:cp options:nil];
}

//

// ------------------------------------------------------------------------------

// ----------------------------- 帮助方法 ----------------------------------------

// ------------------------------------------------------------------------------



- (void)begin:(NSString *)uuid
{
    NSLog(@"----------  开始了， uuid:%@", uuid);
    self.isLock = YES;
    [self readChara:uuid charUUID:RW_Datetime_UUID];
    self.isBeginOK = NO;
    
    // 这里开始读的时候， 可能链接还不稳定，  如果在一定时间内，没有返回数据，  应该再次读取    1秒
    __block BLEManager *blockSelf = self;
    NextWaitInCurrentTheard(if(!blockSelf.isBeginOK){ [blockSelf begin:uuid]; };, 1);
}

- (void)sysToday:(NSString *)uuid
{
    [self readChara:uuid charUUID:R_LastDay_UUID];
}


- (void)realTime:(NSString *)uuid isBegin:(BOOL)isBegin
{
    if (isBegin) {
        timeRealTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginRealTime:) userInfo:uuid repeats:YES];
    }else
    {
        [timeRealTime stop];
        timeRealTime = nil;
    }
}

-(void)beginRealTime:(NSTimer *)timerR
{
    if (!dateLastReadReal || fabs([dateLastReadReal timeIntervalSinceNow]) >= 0.9) {
        __block BLEManager *blockSelf = self;
        __block id userinfo = timeRealTime.userInfo;
        NextWaitInGlobal([blockSelf readChara:userinfo charUUID:R_RealTime_UUID];
                         dateLastReadReal = [NSDate date];, 1);
    }
}














@end
