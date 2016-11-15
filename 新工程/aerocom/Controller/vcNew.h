//
//  vcNew.h
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcNew : vcBase

@property (nonatomic, strong) FlowerData *flower;           // 穿进来的模型

@property (nonatomic, strong) FlowerType *ftModel;          // 穿进来的模型

@property (nonatomic, copy) NSString  *warnStrig;         // 报警设置  0-0-0-0

@property (nonatomic, strong) Per *per;                     // 设备的名称，  uuidString

@property (nonatomic, assign) BOOL isChange;                // 是否改变了

@end
