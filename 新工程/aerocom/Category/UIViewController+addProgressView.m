//
//  UIViewController+addProgressView.m
//  FitTu
//
//  Created by 丁付德 on 15/5/27.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "UIViewController+addProgressView.h"
#import "SDLoopProgressView.h"

@implementation UIViewController (addProgressView)

/**
 *  添加进度条
 *
 *  @param contentView 容器
 *  @param progress    进度
 */
-(void)addProgressView:(UIView *)contentView progress:(float)progress
{
    CGFloat simple = 700.0 / 1242.0 * [[UIScreen mainScreen] bounds].size.width;
    SDLoopProgressView *progressView = [[SDLoopProgressView alloc] init];
    progressView.frame = CGRectMake(0, 0, simple, simple);
    progressView.progress = progress / 100.0;
    [contentView addSubview:progressView];
}



/**
 *  添加进度条   带动画
 *
 *  @param contentView 容器
 *  @param progress    进度
 */
-(void)addProgressViewWithAnimation:(UIView *)contentView progress:(float)progress
{
    if (progress < 1) {
        [self addProgressView:contentView progress:progress];
    }
    else
    {
        NSTimer *timer;
        NSArray *arr = [[NSArray alloc] initWithObjects:contentView, [NSString stringWithFormat:@"%f", progress], nil];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(roll:) userInfo:arr repeats:YES];
    }
}

// 顺序滚动
-(void)roll:(NSTimer *)timeFuc
{
    NSArray *arr = timeFuc.userInfo;
    UIView *contentView = arr[0];
    CGFloat pro = [arr[1] floatValue];
    static float num = 100.1;
    num -= 1;
    if (num >= pro - 1) {
        [self removeAllProgress:contentView];
        [self addProgressView:contentView progress:num];
    }
    else
    {
        num = 100;
        [timeFuc setFireDate:[NSDate distantFuture]];
        [timeFuc invalidate];
    }
}

/**
 *  移除所有容器内的进度条
 *
 *  @param contentView 容器
 */
-(void)removeAllProgress:(UIView *)contentView
{
    NSArray *arrView = [contentView subviews];
    [arrView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
     {
         if ([view isMemberOfClass:[SDLoopProgressView class]])
         {
             [view removeFromSuperview];
         }
     }];
}

// 动画变更label的进度
-(void)beginLabelAnimation:(UILabel *)lbl progress:(float)progress
{
    if (progress < 1) {
        lbl.text = [NSString stringWithFormat:@"%.0f", progress];
    }
    else
    {
        NSArray *arr = [[NSArray alloc] initWithObjects:lbl, [NSString stringWithFormat:@"%f", progress], nil];
        [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(plusNumber:) userInfo:arr repeats:YES];
    }
}



-(void)plusNumber:(NSTimer *)timerF
{
    NSArray *arr = timerF.userInfo;
    UILabel *lbl = arr[0];
    CGFloat pro = [arr[1] floatValue];
    static float num = 100;
    num -= 1;
    if (num >= pro) {
        lbl.text = [NSString stringWithFormat:@"%.0f", num];
    }
    else
    {
        num = 100;
        [timerF setFireDate:[NSDate distantFuture]];
        [timerF invalidate];
    }
}





@end
