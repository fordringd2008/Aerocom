//
//  NSTimer+stop.m
//  FitTu
//
//  Created by 丁付德 on 15/5/21.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "NSTimer+stop.h"

@implementation NSTimer (stop)

/**
 *  停止循环
 */
-(void)stop
{
    if (self) {
        [self setFireDate:[NSDate distantFuture]];
        [self invalidate];
    }
}

// 暂停
-(void)time_pause
{
    [self setFireDate:[NSDate distantFuture]];
}

// 继续
-(void)time_continue
{
    [self setFireDate:[NSDate date]];
}



@end
