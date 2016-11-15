//
//  cvcIndex.m
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "cvcIndex.h"

@implementation cvcIndex

- (void)awakeFromNib {
    self.imv.layer.borderWidth = 3;
    self.imv.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imv.layer.cornerRadius = 3;
    self.imv.clipsToBounds = YES;
}

-(void)setModel:(FlowerData *)model
{
    self.imv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:model.my_plant_pic_url]];
}


@end
