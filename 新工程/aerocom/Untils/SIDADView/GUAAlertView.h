//
//  GUAAlertView.h
//  GUAAlertView
//
//  Created by gua on 11/11/14.
//  Copyright (c) 2014 GUA. All rights reserved.
//

@import UIKit;


typedef void (^GUAAlertViewBlock)(void);


@interface GUAAlertView : UIView

+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle
               buttonTouchedAction:(GUAAlertViewBlock)buttonBlock
                     dismissAction:(GUAAlertViewBlock)dismissBlock;

+ (instancetype)alertViewWithContentView:(UIView *)contentView
                     buttonTouchedAction:(GUAAlertViewBlock)buttonBlock
                           dismissAction:(GUAAlertViewBlock)dismissBlock;

- (void)show;
- (void)dismiss;

@end

// 版权属于原作者  动画划入 动画画出
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
