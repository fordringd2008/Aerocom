//
// 
//  MasterDemo
//
//  Created by 丁付德 on 15/6/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_BLEHeader_h
#define aerocom_BLEHeader_h

//*************************************************************************************

//--------------------------------------   UUID(统一大写写)   --------------------------

//*************************************************************************************


#define ServerUUID                                      @"FF05"             // 主服务UUID
#define RW_Datetime_UUID                                @"F202"             // 时间 的 读和写
#define R_Record_UUID                                   @"F204"             // 读取记录状态列表
#define R_Environment_UUID                              @"F206"             // 读取环境数据
#define R_RealTime_UUID                                 @"F207"             // 实时信息
#define R_LastDay_UUID                                  @"F205"             // 读取当天（最新一天）第一条环境记录

#define Arr_R_UUID                                      [[NSArray alloc] initWithObjects:RW_Datetime_UUID, R_Record_UUID, R_Environment_UUID,R_RealTime_UUID, R_LastDay_UUID, nil]


//*************************************************************************************

//--------------------------------------  设备名称   ----------------------------------

//*************************************************************************************


#define areocom_Plant_Name                              @"PLANT-"
#define areocom_Plant_other_Name                        @"watcher-"

#define dataInterval                                    1.2                // 时间间隔


//*************************************************************************************

//--------------------------------------    数据     ----------------------------------

//*************************************************************************************



#define DataFirst                                       0xF5
#define DataOOOO                                        0x00


#endif
