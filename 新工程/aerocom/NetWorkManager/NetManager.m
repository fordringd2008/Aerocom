//
//  Engine.m
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "NetManager.h"
#import "IPAddress.h"

static NetManager *net;
@implementation NetManager

+(NetManager *)sharedManager
{
    @synchronized(self)
    {
        if (!net) net = [[NetManager alloc] init];
        return net;
    }
}

- (void)getRequestWithUrlStr:(NSString *)urlStr
{
    [self request:urlStr aDic:nil isPost:NO];
}


- (void)postRequestWithUrlStr:(NSString *)urlStr aDic:(NSDictionary *)dic
{
    [self request:urlStr aDic:dic isPost:YES];
}

-(void)request:(NSString *)urlStr aDic:(NSDictionary *)dic isPost:(BOOL)isPost
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer    = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"charset=UTF-8", @"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    __block NetManager *blockSelf= self;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:(isPost?@"POST":@"GET") URLString:urlStr parameters:dic error:nil];
    request.timeoutInterval = 20;
    NSURLSessionDataTask *op = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * response, NSDictionary *responseObject, NSError * error) {
        if(error == nil)
        {
            blockSelf.responseSuccessDic(responseObject);
        }else{
            blockSelf.requestFailError(error);
        }
    }];
    [op resume];
}



+(void)DF_requestWithAction:(void(^)(NetManager *net))action success:(void(^)(NSDictionary *dic))success failError:(void(^)(NSError *erro))failError inView:(UIView *)inView isShowError:(BOOL)isShowError
{
    __block NetManager *netManager = [NetManager new];
    netManager.responseSuccessDic = success;
    __block UIView *blockView = inView;
    netManager.requestFailError = ^(NSError *erro){
        [MBProgressHUD hideAllHUDsForView:blockView animated:YES];
        if(isShowError) [MBProgressHUD show:kString(NONetTip) toView:blockView];
        NSLog(@"%@\n error:%@", NONetTip, erro);
        failError(erro);
    };
    action(netManager);
}

+(void)observeNet
{
    NSLog(@"打开网络监控");
    SetUserDefault(DNet, @1);
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr startMonitoring];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 未知网络");   /// !!!位置网络未处理
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                SetUserDefault(DNet, @0);
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前无网络");
                SetUserDefault(isFirstSys, @1);          // 网络一旦断开  就设置重新同步
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                SetUserDefault(DNet, @1);
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                SetUserDefault(DNet, @2);
                NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 2G/3G/4G");
                break;
        }
    }];
}



-(void)login:(NSString *)email password:(NSString *)password                                   // 登录
{
    NSDictionary *dic = @{@"email":email,@"password":password};
    [self postRequestWithUrlStr:login_URL aDic:dic];
}

-(void)registered:(NSString *)email password:(NSString *)password                              // 注册
{
    NSDictionary *dic = @{@"email":email,@"password":password};
    [self postRequestWithUrlStr:register_URL aDic:dic];
}

-(void)getUserInfo:(NSString *)access                                                          // 获取用户个人信息
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserInfo_URL aDic:dic];
}

-(void)updateUserInfo:(NSDictionary *)dic                                                      // 更新用户个人信息
{
    if (!dic) return;
    [self postRequestWithUrlStr:updateUserInfo_URL aDic:dic];
}

-(void)getToken_distribute_server:(NSString *)access                                            // token-distribute-server
{
    if (!access) return;
    NSString *url = [NSString stringWithFormat:@"%@?user-name=%@", token_distribute_server_URL, access];
    [self get_finally:url];
}

-(void)getNewestPlantData                                                                       // 获取最新植物数据包的地址
{
    NSString *strLang = [NSString stringWithFormat:@"0%ld", (long)[self getPreferredLanguage]];
    NSDictionary *dic = @{@"language_code":strLang};
    //NSDictionary *dic = @{@"language_code":@"01"};
    [self postRequestWithUrlStr:getPlantDataUrl_URL aDic:dic];
}

-(void)getNewestPlantData_112                                                                   // 获取最新植物数据包的地址(1.12版)
{
    NSString *strLang = [NSString stringWithFormat:@"0%ld", (long)[self getPreferredLanguage]];
    NSDictionary *dic = @{@"language_code":strLang};
    [self postRequestWithUrlStr:getNewPlantDataUrl_URL aDic:dic];
}

-(void)updateSysSetting:(NSDictionary *)dic;                                                    // 更新系统设置
{
    if (!dic) return;
    [self postRequestWithUrlStr:updateUserSys_URL aDic:dic];
}

-(void)getSystemSetting:(NSString *)access                                                      // 获取系统设置
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getSystemSetting_URL aDic:dic];
}


-(void)getInfoHint:(NSString *)access;                                                          // 获取修改信息提示
{
    if (!access) return;
    NSString *strLang = [NSString stringWithFormat:@"0%ld", (long)[self getPreferredLanguage]];
    NSDictionary *dic = @{ @"access": access,  @"language_code":strLang };
    [self postRequestWithUrlStr:getInfoHint_URL aDic:dic];
}


-(void)getMyPlantInfo:(NSString *)access                                                        // 获取我的花园信息
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getMyPlantInfo_URL aDic:dic];
}

-(void)getNewestPlantJSONData:(NSString *)name;                                                 // Get  拉去最新的植物分类json数据
{
    if (!name) return;
    NSString *url = [NSString stringWithFormat:@"%@", name];
    [self get_finally:url];
}


-(void)updateMyPlantInfo:(NSDictionary *)dic                                                    // 保存我的花园植物信息 ( 新增 、修改 )
{
    if (!dic) return;
    [self postRequestWithUrlStr:updateMyPlantInfo_URL aDic:dic];
}

-(void)deleteOneMyPlantInfo:(NSString *)access plantID:(NSString *)plantID                      // 删除一个我的花园植物
{
    if (!access || !plantID) return;
    NSDictionary *dic = @{ @"access": access,  @"my_plant_id":plantID };
    [self postRequestWithUrlStr:deleteOneMyPlantInfo_URL aDic:dic];
}

-(void)updateMyPlantData:(NSDictionary *)dic                                                    // 上传监测数据
{
    if (!dic) return;
    [self postRequestWithUrlStr:updateMyPlantData_URL aDic:dic];
}

-(void)getMyPlantData:(NSString *)access my_plant_id:(NSString *)my_plant_id k_date_from:(int)k_date_from k_date_to:(int)k_date_to                                                                                 // 获取我的植物检测数据
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:access forKey:@"access"];
    if (my_plant_id)
        [dic setObject:my_plant_id forKey:@"my_plant_id"];
    [dic setObject:@(k_date_from) forKey:@"k_date_from"];
    [dic setObject:@(k_date_to) forKey:@"k_date_to"];
    
    [self postRequestWithUrlStr:getMyPlantData_URL aDic:dic];
}

-(void)updateAlarmInfo:(NSDictionary *)dic                                                          // 上传报警信息
{
    if (!dic) return;
    if ([dic[@"alarm_arr"] description].length < 3) {
        NSLog(@"这里有问题");return;
    }
    [self postRequestWithUrlStr:UpdateAlarmInfo_URL aDic:dic];
}


-(void)getAlarmInfo:(NSDictionary *)dic                                                             // 获取报警信息
{
    if (!dic) return;
    [self postRequestWithUrlStr:getAlarmInfo_URL aDic:dic];
}

-(void)getFileUrl:(NSString *)access                                                                // 获取使用帮助图片地址
{
    if (!access) return;
    NSString *strLang = [NSString stringWithFormat:@"0%ld", (long)[self getPreferredLanguage]];
    NSDictionary *dic = @{@"access":access, @"file_type": @"help_pic", @"language_code": strLang};
    [self postRequestWithUrlStr:getFileUrl_URL aDic:dic];
}

-(void)findPassword:(NSString *)email                                                               // 找回密码
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970] * 1000;
    NSDictionary *dic = @{@"email":email, @"time": @(time)};
    [self postRequestWithUrlStr:findPassword_URL aDic:dic];
}

// 对传进的参数进行加码处理
-(NSString *)encode:(NSString *)string
{
    NSString *str=  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) string,NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    
    return str;
}

-(void)get_finally:(NSString *)string
{
    NSString *url = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self getRequestWithUrlStr:url];
}

-(NSString *)ToUTF8:(NSString *)string
{
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


@end
