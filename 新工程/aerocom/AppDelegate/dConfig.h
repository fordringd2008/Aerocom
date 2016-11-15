//
//  dConfig.h
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_dConfig_h
#define aerocom_dConfig_h

#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#define ThisVersion                         @2                    // 当前植物数据库版本  // 总的版本
#define ThisPicVersion                      @2                    // 当前植物图片数据包版本

#define dString(_S)                         NSLocalizedString(_S, @"")
#define RGBA(_R,_G,_B,_A)                   [UIColor colorWithRed:_R / 255.0f green:_G / 255.0f blue:_B / 255.0f alpha:_A]
#define RGB(_R,_G,_B)                       RGBA(_R,_G,_B,1)


// ------- 本地存储
#define GetUserDefault(key)                 [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define SetUserDefault(k, v)                [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]; [[NSUserDefaults standardUserDefaults]  synchronize];
#define RemoveUserDefault(k)                [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]; [[NSUserDefaults standardUserDefaults] synchronize];

// ------- 提示
#define MBShowAll                           [MBProgressHUD showHUDAddedTo:self.view animated:YES];
#define MBShowAllInBlock                    [MBProgressHUD showHUDAddedTo:blockSelf.view animated:YES];
#define MBHide                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES]
#define MBHideInBlock                       [MBProgressHUD hideAllHUDsForView:blockSelf.view animated:YES];

#define LMBShow(message)                     [MBProgressHUD show:kString(message) toView:self.view]
#define LMBShowInBlock(message)              [MBProgressHUD show:kString(message) toView:blockSelf.view]

#define HDDAF                                NextWait(MBHideInBlock;, 20);
// ------- 系统相关

#define IPhone4                             (ScreenHeight == 480)
#define IPhone5                             (ScreenHeight == 568)
#define IPhone6                             (ScreenHeight == 667)
#define IPhone6P                            (ScreenHeight == 736)
#define ISIOS                               [[[UIDevice currentDevice] systemVersion] doubleValue]  // 当前系统版本
#define IS_IOS_7                            (ISIOS>=7.0)?YES:NO                  // 系统版本是否是iOS7+
#define IS_Only_IOS_7                       (ISIOS>=7.0 && ISIOS<8.0)?YES:NO     // 系统版本是否是iOS7.
//#define IS_IPad                             [[UIDevice currentDevice].model rangeOfString:@"iPad"].length > 0    // 是否是ipad
#define IS_IPad                             0    // 是否是ipad

// 中英文
#define kString(_S)                            NSLocalizedString(_S, @"")

// ------- 宽高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define StateBarHeight                      20
#define NavBarHeight                        64
#define BottomHeight                        49
#define RealHeight(_k)                      ScreenHeight * (_k / 2208.0)
#define RealWidth(_k)                       ScreenWidth * (_k / 1242.0)
#define ScreenRadio                         0.562                           // 屏幕宽高比
#define Border(_label, _color)              _label.layer.borderWidth = 1; _label.layer.borderColor = _color.CGColor;

// ------- 控件相关
#define dHeightForBigView                   200
#define dCellHeight                         44

// 第一次运行标记
#define ISFISTRINSTALL                      @"ISFISTRINSTALL"
#define myUserInfo                          ((UserInfo *)[self getUserInfo])
#define NavButtonFrame                      [self getNavFrame]
#define UserUnit                            @"UserUnit"
#define KgToLb                              0.4532
#define CmToFt                              0.0328             // cm -> ft 英尺
#define Picture_Limit_KB                    100
#define DefaultLogo                         @"touxiang"
#define CurrentLanguage                     @"CurrentLanguage"
#define DefaultLogoImage                    [UIImage imageNamed:DefaultLogo]

#define ImageFromLocal(_k)                 [UIImage imageNamed:_k] ? [UIImage imageNamed:_k] : ([UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]] ? [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]] : [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]]])

// 阿里云 相关
#define ALI_HostId                          @"oss-cn-shenzhen.aliyuncs.com"
#define my_plant_pic                        @"my-plant-pic"
#define plant_pic                           @"plant-pic"
#define sourse                              @"Sourse"
#define tokenIng                            1 * 60 * 60                     // token 过期时间 （ 一个小时 ）


#define NONetTip                            @"网络异常,请检查网络"
#define version_Local                       @"version_Local"
#define version_Pic                         @"version_Pic"
#define plant_pic_Name                      @"plant-pic"                    // 保存的zip名称
#define plant_json_Name                     @"flowers"                      // 保存的Json的名称前缀 后面还有添加 zh, en, fr

#define SystemPromptBegin                   @"SystemPromptBegin"
#define SystemPromptFinish                  @"SystemPromptFinish"
#define RangeUnit                           @"RangeUnit"
#define TemperatureUnit                     @"TemperatureUnit"
#define Latitude_Longitude                  @"Latitude_Longitude"
#define IsGetUserAddress                    @"IsGetUserAddress"
#define CheckIsOK                           [dic[@"status"] isEqualToString:@"0"]
#define isFirstSys                          @"isFirstSys"                   // 默认为1   每次进入app的时候同步 同步完改为0
#define DSys                                @"DSys"                         // 同步 退出时 停止所有同步  登陆成功再设置可以同步
#define isSysContinue                       ([GetUserDefault(DSys) boolValue])                //  是否继续 是  继续  否 停止

// k1 发起请求 k2 成功回调 k3 网络错误回调
//#define RequestCheckBefore(_k1, _k2, _k3)        NetManager *net = [NetManager new];[net checkStatus:NO block:^(NSInteger netState) { if(netState) {_k1} else {_k3}}];net.requestFailError = ^(NSError *erro){MBHideInBlock;NSLog(@"%@\n error:%@", NONetTip, erro);_k3 };net.responseSuccessDic = ^(NSDictionary *dic){ _k2  };
//
//
//#define RequestCheckAfter(_k1, _k2)           __block NetManager *net = [NetManager new];[net checkStatus:YES block:^(NSInteger netState) {if(netState) { _k1 } else{MBHideInBlock;LMBShowInBlock(NONetTip); NSLog(NONetTip); }}];net.requestFailError = ^(NSError *error){MBHideInBlock;LMBShowInBlock(NONetTip);NSLog(@"%@\n error:%@", NONetTip, error);};net.responseSuccessDic = ^(NSDictionary *dic){ _k2  };
//
//
//#define RequestCheckNoWaring(_k1, _k2)        __block NetManager *net = [NetManager new];[net checkStatus:NO block:^(NSInteger netState) { if(netState) {_k1}}];net.requestFailError = ^(NSError *erro){MBHideInBlock;NSLog(@"%@\n error:%@", NONetTip, erro);};net.responseSuccessDic = ^(NSDictionary *dic){ _k2  };

#define RequestCheckBefore(_k1, _k2, _k3)        [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {_k3} inView:blockSelf.windowView isShowError:NO];

#define RequestCheckAfter(_k1, _k2)            [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {} inView:blockSelf.windowView isShowError:YES];

#define RequestCheckNoWaring(_k1, _k2)        [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {} inView:blockSelf.windowView isShowError:NO];


#define IMG(_k)                             [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]]] ? [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]]] : [UIImage imageNamed:_k]                          // 优先考虑Document中的文件

#define DDWeakVV                   DDWeak(self)
#define DDStrongVV                 DDStrong(self)

#define DDWeak(type)               __weak typeof(type) weak##type = type;
#define DDStrong(type)             __strong typeof(type) type = weak##type;

#define NextWait(_k, _v)                    [self performBlock:^{ _k } afterDelay:_v]
#define NextWaitInMain(_k)                  [self performBlockInMain:^{ _k }]
#define NextWaitInMainAfter(_k, _v)         [self performBlockInMain:^{ _k } afterDelay:_v]
#define NextWaitInCurrentTheard(_k, _v)     [self performBlockInCurrentTheard:^{ _k } afterDelay:_v]
#define NextWaitInGlobal(_k, _v)            [self performBlockInGlobal:^{ _k }]

#define RemindCount                         @"RemindCount"                  // key flowerID string   value : 报警次数 number
#define CheckRemind                         @"CheckRemind"
#define HelpUrlVersion                      @"HelpUrlVersion"
#define isNotRealNewBLE                     @"isNotRealNewBLE"              //默认为O  在index设置为1
#define BLEisON                             @"BLEisON"
#define UpdateDataing                       @"UpdateDataing"  // 正在下载中 数据包
#define DNet                                @"DNet"           // 网络更新
#define NewJsonURL                          @"NewJsonURL"     // 最新的Json 地址
#define JSonFail                            @"JSonFail"       // JSon文件下载失败

#define LoadRejectData                      @"LoadRejectData"       // 上次用户拒绝更新的时间
#define FirstBindding                       @"FirstBind"       // 用户第一次绑定成功
#define FirstBindMessage                    kString(@"欢迎使用智能守望者植物伙伴，现在开始将照看你花花草草的工作交给我吧！守望者会及时把它们的需求告诉你，别忘了每天回家跟我握个手！")       // 用户第一次绑定成功


#define Remind_Meg_Light_Hight              kString(@"光照太强了,请移到相对阴凉的地方.")
#define Remind_Meg_Light_Low                kString(@"光照不足,求帮助.")
#define Remind_Meg_Tem_LowEst               kString(@"温度太低了,花草扛不住了.")
#define Remind_Meg_Tem_Low                  kString(@"温度相对有点低了.")
#define Remind_Meg_Tem_Hight                kString(@"温度有点高了.")
#define Remind_Meg_Tem_HightEst             kString(@"太热了,受不了了.")
#define Remind_Meg_Soil_Low                 kString(@"太干燥了,求浇水.")
#define Remind_Meg_Soil_Hight               kString(@"水太多了,我快喝饱了.")

#define Remind_Mini_Light_Hight              kString(@"光照太强")
#define Remind_Mini_Light_Low                kString(@"光照不足")
#define Remind_Mini_Tem_LowEst               kString(@"温度太低")
#define Remind_Mini_Tem_Low                  kString(@"温度有点低")
#define Remind_Mini_Tem_Hight                kString(@"温度有点高")
#define Remind_Mini_Tem_HightEst             kString(@"温度太高")
#define Remind_Mini_Soil_Low                 kString(@"缺水")
#define Remind_Mini_Soil_Hight               kString(@"水太多")



#define plantNameLength                     20                     // 字节不能超过20

// 默认图片地址

//#define DEFAULTIMAGEADDRESS                                     @"ios"

#define DEFAULTIMAGEADDRESS                 @"ios"
#define DEFAULTIMG                          [UIImage imageNamed:DEFAULTIMAGEADDRESS]

#define DEFAULTLOGOADDRESS                  @"thedefault"
#define DEFAULTTHTDEFAULT                   [UIImage imageNamed:DEFAULTLOGOADDRESS]

#define userInfoAccess                      @"userInfoAccess"
#define userInfoEmail                       @"userInfoEmail"            // 这是一个字典 key ：access  value: email
#define DBefaultContext                     [NSManagedObjectContext MR_defaultContext]
#define DLSave                              [localContext MR_saveToPersistentStoreAndWait];
#define DBSave                              [DBefaultContext MR_saveToPersistentStoreAndWait];

#define DWhite                              [UIColor whiteColor]
#define DRed                                [UIColor redColor]
#define DYellow                             [UIColor yellowColor]
#define DBlack                              [UIColor blackColor]
#define DClear                              [UIColor clearColor]
#define DLightGray                          [UIColor lightGrayColor]
#define DWhiteA(_k)                         RGBA(255, 255, 255, _k)
#define DBlackA(_k)                         RGBA(0, 0, 0, _k)
#define DBorder                             RGB(211, 211, 211)
//  ------------------------------------------------------------  分享 -----

// shareSDK ID
//#define SHARESDKID                                              @"8e5088b7d740" // 个人
#define SHARESDKID                           @"fb252a258958" // 公司

#define AerocomAPPID                         1018688518
#define ShareContent                         @""
#define ShareDescription                     @""
#define ShareUrl                             @"http://www.sz-hema.com/"


//  ------------------------------------------------------------------------------新浪  APPKEY  appSecret  回调网址
#define SINAKEY                              @"1027304610"
#define SINASECRET                           @"c0733c56ed9f6a670301b975d7b6faeb"
#define SINAURL                              @"http://www.sz-hema.com/"

//  ------------------------------------------------------------------------------QQ APPKEY  appSecret
#define QQKEY                                @"1105066267"   // QQ41DDF91B
#define QQSECRET                             @"SWmXwjy9RFt66ruO"

#define WEIXINKEY                            @"wx203eb0016c1c6127"
#define WEIXINSECRET                         @"b680c3552aa3321689fc5eb8dbd574b0"

#define TwitterKEY                           @"HjYBvOMC4e77prCFkExyFX7Zt"
#define TwitterSECRET                        @"cxwwNlw2GxHzslqXJt9Wks3YfxqvZYTTck0c6LmEbhKrtxIsX7"

#define FacebookKEY                          @"718377231623704"
#define FacebookSECRET                       @"ac2ca25bef58344584427142a396d324"

#define BugTagsAppKey                        @"3fa672d4e4b08ecee5d24d984d4f9055" // 在 my163dfd账号下
#define BugTagsSecret                        @"2d6c75c6ef94728b44be63213cbc8083"

#define JSPatchKey                           @"62d022bd8787e719"                // 1.4 版本
#define UMengKey                             @"55e95bf767e58e27e30004c8"

#if DEBUG
    #import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

#endif
