//
//  UIViewController+addProgressView.h
//  FitTu
//
//  Created by 丁付德 on 15/5/27.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (addProgressView)

/**
 *  添加进度条
 *
 *  @param contentView 容器
 *  @param progress    进度
 */
-(void)addProgressView:(UIView *)contentView progress:(float)progress;

/**
 *  添加进度条   带动画
 *
 *  @param contentView 容器
 *  @param progress    进度
 */
-(void)addProgressViewWithAnimation:(UIView *)contentView progress:(float)progress;

/**
 *  移除所有容器内的进度条
 *
 *  @param contentView 容器
 */
-(void)removeAllProgress:(UIView *)contentView;

// 动画变更label的进度
-(void)beginLabelAnimation:(UILabel *)lbl progress:(float)progress;


@end
