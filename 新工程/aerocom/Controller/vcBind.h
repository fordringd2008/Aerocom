//
//  vcBind.h
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcBindDelegate <NSObject>

-(void)bind:(Per *)per;

@end

@interface vcBind : vcBase

@property (nonatomic, strong) Per *per;  // 上个页面传进来的 设备对象


@property (nonatomic, strong) id<vcBindDelegate> delegate;

@end
