//
//  Engine.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetManager : NSObject
{
    NSDate *lastDate;
}
@property (nonatomic, assign) AFNetworkReachabilityStatus netStatus;

@property (nonatomic, strong) void (^responseSuccessDic)(NSDictionary *dic);
@property (nonatomic, strong) void (^responseFail)(NSString *str);
@property (nonatomic, strong) void (^requestFailError)(NSError *error);
@property (nonatomic, strong) void (^canNotConnectToNet)(NSString *error);
@property (nonatomic, assign) BOOL isBusy;                                                      // 当前比较繁忙
@property (nonatomic, assign) NSInteger netstatus;                                              // 当前网络类型

//+(NetManager *)sharedManager;
//
//-(void)sharedClient:(void(^)(NSInteger netState))block;                                         // 监视网络， 有网后的操作
//
//-(void)observeNet;
//
//-(void)checkStatus:(BOOL)isprompt block:(void(^)(NSInteger netState))block;                     // 监视网络， 是否提示， 接着操作


//+(NetManager *)sharedManager;

+(void)observeNet;                                                                              // 监视网络

+(void)DF_requestWithAction:(void(^)(NetManager *net))action success:(void(^)(NSDictionary *dic))success failError:(void(^)(NSError *erro))failError inView:(UIView *)inView isShowError:(BOOL)isShowError;

//-(void)checkStatus:(BOOL)isprompt block:(void(^)(NSInteger netState))block;                     // 监视网络， 是否提示， 接着操作

-(void)login:(NSString *)email password:(NSString *)password;                                   // 登录

-(void)registered:(NSString *)email password:(NSString *)password;                              // 注册

-(void)getUserInfo:(NSString *)access;                                                          // 获取用户个人信息

-(void)updateUserInfo:(NSDictionary *)dic;                                                      // 更新用户个人信息

-(void)getToken_distribute_server:(NSString *)access;                                           // token-distribute-server

-(void)getNewestPlantData;                                                                      // 获取最新植物数据包的地址

-(void)getNewestPlantJSONData:(NSString *)name;                                                 // Get  拉去最新的植物分类json数据

-(void)updateSysSetting:(NSDictionary *)dic;                                                    // 更新系统设置

-(void)getSystemSetting:(NSString *)access;                                                     // 获取系统设置

-(void)getInfoHint:(NSString *)access;                                                          // 获取修改信息提示

-(void)getMyPlantInfo:(NSString *)access;                                                       // 获取我的花园信息

-(void)updateMyPlantInfo:(NSDictionary *)dic;                                                   // 保存我的花园植物信息 ( 新增 、修改 )

-(void)deleteOneMyPlantInfo:(NSString *)access plantID:(NSString *)plantID;                     // 删除一个我的花园植物

-(void)updateMyPlantData:(NSDictionary *)dic;                                                   // 上传监测数据

-(void)getMyPlantData:(NSString *)access my_plant_id:(NSString *)my_plant_id k_date_from:(int)k_date_from k_date_to:(int)k_date_to;                                                                             // 获取我的植物检测数据

-(void)updateAlarmInfo:(NSDictionary *)dic;                                                     // 上传报警信息

-(void)getAlarmInfo:(NSDictionary *)dic;                                                        // 获取报警信息

-(void)getFileUrl:(NSString *)access;                                                           // 获取使用帮助图片地址

-(void)findPassword:(NSString *)email;                                                          // 获取使用帮助图片地址

-(void)getNewestPlantData_112;                                                                  // 获取最新植物数据包的地址(1.12版)

@end

