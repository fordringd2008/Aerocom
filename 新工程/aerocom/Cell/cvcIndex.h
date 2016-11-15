//
//  cvcIndex.h
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlowerData.h"

@interface cvcIndex : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imv;
@property (strong, nonatomic) FlowerData *model;

@end
