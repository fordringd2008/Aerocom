//
//  vcBase.h
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UserInfo.h"
#import "BLEManager.h"
#import "NetManager.h"
#import "aLiNet.h"

@interface vcBase : UIViewController

@property (nonatomic, strong) AppDelegate *         appDelegate;
@property (nonatomic, strong) UIApplication *       application;
@property (nonatomic, strong) UIView *              windowView;
@property (nonatomic, strong) UIButton *            leftButton;
@property (nonatomic, strong) NSArray *             arrPush;          // 跨页面传值
@property (nonatomic, strong) UserInfo  *           userInfo;         // 当前用户
@property (nonatomic, assign) BOOL                  isPop;            // 是否是倒退 还是显示做侧栏
@property (nonatomic, strong) BLEManager *          Bluetooth;        // 蓝牙单例对象
@property (nonatomic, strong) NSMutableDictionary * dicBLEFound;      // 蓝牙扫描到得外设
@property (nonatomic, strong) UIView *              dicView;          // 搜索显示的列表

@property (nonatomic, assign) BOOL                  isJumpLock;       // 跳转锁定  Yes  不能跳转  No 可以
//@property (nonatomic, strong) NetManager *          netManager;       // 网络实例
//@property (assign)            NSInteger             netState;         // 当前网络状态   0 : 无网络  1 : WIFI   2: 2G/3G/4G
//@property (assign)            NSInteger             interfaceIndex;   // 当前网络请求接口ID

@property (nonatomic, strong) NSArray *             arrNewValues;     // 最新数据包 值的 集合
@property (nonatomic, strong) aLiNet *              alinet;           // 


@property (nonatomic, copy)   NSString *            imgType;          // 待上传的格式
@property (nonatomic, strong) NSData *              imgdata;          // 待上传的图片数据
@property (nonatomic, strong) NSMutableArray *      arrUpdataSynID;   // 发送了上传 同步数据的 植物ID集合


@property (strong, nonatomic) NSMutableDictionary * dicNeedConnet; // 需要连接的植物集合 （ 连接上后 不会移除 ）key: uuidString value: 植物对象
@property (strong, nonatomic) NSMutableArray      * arrNeed;       // 需要连接的植物集合 （ 连接上后 会移除 ）

@property (strong, nonatomic) NSMutableArray      * arrUploadRemind;   // 已经发送上传请求的提醒数组

@property (nonatomic, strong) void                  (^upLoad_Next)(NSString *url); // 上传图片后的操作

@property (nonatomic, strong) NSTimer *            timerAutoLink;                   // 连接循环器



// 待下载新包 字典的集合， key:版本号  value:下载包地址 最后一个是  key:@"json" value:json地址
@property (nonatomic, strong) NSMutableArray *      arrInNewPlantData;

- (void)initLeftButton:(NSString *)imgName;

-(void)initRightButton:(NSString *)text imgName:(NSString *)imgName;

-(void)rightButtonClick;

-(void)back;

-(void)backAfterOneSecond;

-(void)gotoMainStoryBoard;

-(void)gotoLoginStoryBoard;

-(void)setSideslip:(BOOL)isSlip;                                       // 设置是否开启侧滑

-(void)resetBLEDelegate;                                               // 重置蓝牙代理


-(void)getTokenAndUpload;                                               // 先获取权限， 然后上传


// ------------------------------------------------------  蓝牙相关操作

-(void)resetTimerAutoLink;


-(void)Scan;                                                           // 开始扫描

-(void)readValue:(NSString *)va;


-(void)Found_Next:(NSMutableDictionary *)recivedTxt;                   // 发现回调后的 接下来操作，   --  用来重写

-(void)Conneted_Next:(NSString *)uuidString;                           // 连接上后 接下来操作，      --  用来重写

-(void)Disconneted_Next:(NSString *)uuidString;                        // 断开连接后 接下来操作，     --  用来重写

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj;//           --   用来重写

-(void)MatchingFont:(UIView *)view;                                    // 适配所有字体

//-(void)dataSuccessBack:(NSDictionary *)dic;                            // 网络正常请求的回调处理  用来重写

-(void)setNavTitle:(UIViewController *)vc title:(NSString *)title;


-(void)dataSuccessBack_getNewestPlantJSONData:(NSDictionary *)dic;


-(void)alertBecauseFirstBind;

-(void)setBar;

-(void)changeNavigationBar:(UIColor *)color;        // 改变导航条的颜色


@end
