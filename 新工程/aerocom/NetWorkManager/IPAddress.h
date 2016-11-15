//
//  IPAddress.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#ifndef WuLiuNoProblem_IPAddress_h
#define WuLiuNoProblem_IPAddress_h

// IP (纯IP)

// IP 地址 (外网)
#define IP @"http://www.sz-hema.net/"
//#define IP @"http://120.25.212.156/"

#define _URL_Head                   @"aero/"

#define _URL(_k)                   [NSString stringWithFormat:@"%@%@%@",IP, _URL_Head, _k]

#define _ALI_URL                   [NSString stringWithFormat:@"http://plant-data.%@/", ALI_HostId]



#define login_URL                   _URL(@"login")                                          // 登录

#define register_URL                _URL(@"register")                                       // 注册

#define findPassword_URL            _URL(@"findPassword")                                   // 找回密码

#define updateMyPlantInfo_URL       _URL(@"updateMyPlantInfo")                              // 保存我的花园植物信息

#define updateUserInfo_URL          _URL(@"updateUserInfo")                                 // 更新用户个人信息

#define getUserInfo_URL             _URL(@"getUserInfo")                                    // 获取用户个人信息

#define getMyPlantInfo_URL          _URL(@"getMyPlantInfo")                                 // 获取我的花园信息

#define deleteOneMyPlantInfo_URL    _URL(@"deleteOneMyPlantInfo")                           // 删除一个我的花园植物

#define updateUserSys_URL           _URL(@"updateUserSys")                                  // 更新系统设置

#define getSystemSetting_URL        _URL(@"getUserSys")                                     // 获取系统设置

#define getFileUrl_URL              _URL(@"getFileUrl")                                     // 获取使用帮助图片地址

#define updateMyPlantData_URL       _URL(@"updateMyPlantData")                              // 上传监测数据

#define getMyPlantData_URL          _URL(@"getMyPlantData")                                 // 获取我的植物检测数据

#define UpdateAlarmInfo_URL         _URL(@"updateAlarmInfo")                                // 上传报警信息

#define getAlarmInfo_URL            _URL(@"getAlarmInfo")                                   // 获取报警信息

#define getInfoHint_URL             _URL(@"getInfoHint")                                    // 获取修改信息提示

#define getPlantDataUrl_URL         _URL(@"getPlantDataUrl")                                // 获取最新植物数据包的地址

#define token_distribute_server_URL _URL(@"distribute-token.json")                          // token-distribute-server  (get)


#define getNewPlantDataUrl_URL       _URL(@"getNewPlantDataUrl")                             // 获取最新植物数据包的地址











#endif
