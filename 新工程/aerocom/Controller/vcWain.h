//
//  vcWain.h
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcWainDelegate <NSObject>

-(void)chaneIsWain:(NSString *)warnString;

@end

@interface vcWain : vcBase

@property (nonatomic, copy) NSString *wariString;

@property (nonatomic, strong) id<vcWainDelegate> delegate;

@end
