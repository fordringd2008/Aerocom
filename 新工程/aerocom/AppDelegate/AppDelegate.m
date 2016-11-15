//
//  AppDelegate.m
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "AppDelegate.h"
#import "vcLeft.h"
#import "vcStart.h"

#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "LxxPlaySound.h"
#import "LNNotificationsUI.h"
#import "GUAAlertView.h"
#import <Bugtags/Bugtags.h>
#import <JSPatch/JSPatch.h>
#import "MobClick.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 热修复
    // [JSPatch testScriptInBundle];  这一句用来测试本地
    [JSPatch startWithAppKey:JSPatchKey];
#if isDevelemont == 1
    [JSPatch setupDevelopment];
#endif
    [JSPatch sync];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"aerocom.sqlite"];
    [MagicalRecord enableShorthandMethods];
    
    [Bugtags startWithAppKey:BugTagsAppKey invocationEvent:BTGInvocationEventNone];
    [MobClick startWithAppkey:UMengKey reportPolicy:BATCH channelId:nil];
    
    
    [self initFlowerTypeData];
    SetUserDefault(isNotRealNewBLE, @(0));
    SetUserDefault(UpdateDataing, @NO);
    
    if (!GetUserDefault(RemindCount)) SetUserDefault(RemindCount, [NSMutableDictionary new]);

    if (![GetUserDefault(version_Local) integerValue])
    {
        SetUserDefault(version_Local, ThisVersion);                 // 默认系统版本
        SetUserDefault(version_Pic, ThisPicVersion);                // 默认图片版本
    }
    
    if (![GetUserDefault(CurrentLanguage) integerValue]) RemoveUserDefault(CurrentLanguage);
    
    [NetManager observeNet];
    // ------------------------- 默认重置第一次同步 (一个小时后重置， 循环)
    SetUserDefault(isFirstSys, @1);
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 * 60 * 60 target:self selector:@selector(restSys:) userInfo:nil repeats:YES];
    
    [self initializePlat];
    [self initYRSideVc];
    [self initRootView];
    
    if (IS_Only_IOS_7)
    {
        self.window.clipsToBounds =YES;
        self.window.frame =  CGRectMake(0,0,self.window.frame.size.width,self.window.frame.size.height);
        [self.window makeKeyAndVisible];
    }
    
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    if (sysVersion>=8.0) {
        UIUserNotificationType type=UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        else
        {
            [[UIApplication sharedApplication]registerUserNotificationSettings:setting];
        }
    }
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

-(void)initFlowerTypeData
{
    if (![[FlowerType numberOfEntitiesWithContext:DBefaultContext] integerValue])
    {
        NSData *data = [self getFlowerTypeDataFromJSON];
        NSDictionary *dic = (NSDictionary *)data;
        NSArray *arrData = dic[@"flowers"];
        for (int i = 0; i < arrData.count; i++)
        {
            NSDictionary *dic = arrData[i];
            FlowerType *ft = [FlowerType MR_createEntityInContext:DBefaultContext];
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
            DBSave;
        }
    }
}


-(void)initializePlat
{
    [ShareSDK registerApp:SHARESDKID];
    [ShareSDK connectSinaWeiboWithAppKey:SINAKEY
                               appSecret:SINASECRET
                             redirectUri:ShareUrl ];
    [ShareSDK connectQZoneWithAppKey:QQKEY
                           appSecret:QQSECRET
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectQQWithQZoneAppKey:QQKEY
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectWeChatWithAppId:WEIXINKEY
                           appSecret:WEIXINSECRET
                           wechatCls:[WXApi class]];
    [ShareSDK connectFacebookWithAppKey:FacebookKEY
                              appSecret:FacebookSECRET];
    [ShareSDK connectTwitterWithConsumerKey:TwitterKEY
                             consumerSecret:TwitterSECRET
                                redirectUri:ShareUrl];
}

-(void)restSys:(NSTimer *)timerF
{
    SetUserDefault(isFirstSys, @1);                           // 默认重置第一次同步
}

//添加两个回调方法,return的必须要ShareSDK的方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:nil];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:nil];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"------------ >  APP将要推出");
    [MagicalRecord cleanUp];
}

//  applicationDidBecomeActive是app在后台运行，通知时间到了，你从通知栏进入，或者直接点app图标进入时，会走的方法。
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self setIconNumber:0];
}

-(void)setIconNumber:(int)num
{
    if([[UIDevice currentDevice]systemVersion].floatValue >= 8)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = num;
}


// 是app在前台运行，通知时间到了，调用的方法。如果程序在后台运行，时间到了以后是不会走这个方法的。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self setIconNumber:1];
    [self notificationNext:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self notificationNext:notification.userInfo];
}


-(void)notificationNext:(NSDictionary *)userInfo
{
    if (userInfo[@"remind"])
    {
        NextWaitInMain(
            NSLog(@"--------- 通知来了");
            [[[LxxPlaySound alloc] initForPlayingVibrate] play];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
            [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Leo" icon:nil];
            LNNotification* notification = [LNNotification notificationWithMessage:userInfo[@"remind"]];
            notification.title = @"Aerocom";
            [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];// 删除所有本地通知
                       );
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)notificationWasTapped:(NSNotification*)notification
{
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // ...
}


-(void)initYRSideVc
{
    vcLeft *leftViewController = [[vcLeft alloc]initWithNibName:nil bundle:nil];
    leftViewController.view.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
    self.sideViewController = [YRSideViewController new];
    self.sideViewController.leftViewController = leftViewController;
    self.sideViewController.leftViewShowWidth = 260;
    self.sideViewController.needSwipeShowMenu = true;
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.sideViewController;
}

//加载rootView
- (void)initRootView
{
    self.customTb = [CustomTabBarController new];
    self.sideViewController.rootViewController = self.customTb;
    
    if (!GetUserDefault(ISFISTRINSTALL))
    {
        vcStart *startVc = [vcStart new];
        SetUserDefault(ISFISTRINSTALL, @"ISFISTRINSTALL");
        self.window.rootViewController = startVc;
    }
    else
    {
        if (myUserInfo.access)
        {
            SetUserDefault(isNotRealNewBLE, @(1));
            self.window.rootViewController = self.sideViewController;
        }
        else
        {
            UIStoryboard *indexLg = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]]; // navMain
            UINavigationController *navLg = indexLg.instantiateInitialViewController;
            self.window.rootViewController = navLg;
        }
    }
}

-(void)setUpBackGroundReflash{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Coasters" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSLog(@"------------------------------- > 数据迁移");  // 数据迁移完成
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self getDomentURL] stringByAppendingPathComponent: @"Coasters.sqlite"]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
    }
    
    return persistentStoreCoordinator;
}

@end
