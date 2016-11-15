//
//  UIViewController+GetAccess.h
//  Coasters
//
//  Created by 丁付德 on 15/12/18.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (GetAccess)

#pragma mark  判断是否含有权限  当有权限的时候 进行操作  1: 相册  2: 摄像头  3:麦克风 4:   5:
- (void)getAccessNext:(int)typeSub block:(void(^)())block;

@end
