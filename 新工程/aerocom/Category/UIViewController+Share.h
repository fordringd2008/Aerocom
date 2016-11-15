//
//  UIViewController+Share.h
//  FitTu
//
//  Created by 丁付德 on 15/6/3.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ShareSDK/ShareSDK.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import "UIViewController+Delay.h"
#import "MBProgressHUD+Add.h"
#import "MBProgressHUD.h"
#import "IPAddress.h"

@interface UIViewController (Share) <UIActionSheetDelegate>

/**
 *  调用分享功能
 *
 *  @param shareType 1： 新浪微博   2： QQ空间
 */
//-(void)share:(int)shareType;

/**
 *  截频
 *
 *  @param theView 所在的视图
 *
 *  @return 截好的图片
 */
- (UIImage *)imageFromView:(UIView *)theView;


// 显示分享菜单
- (void)ShowShareActionSheet;

// 清除权限
+ (void)CancelAuthWithAll;


@end
