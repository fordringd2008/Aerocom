//
//  tvcFlowerList.h
//  aerocom
//
//  Created by 丁付德 on 15/7/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcFlowerList : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;

@property (strong, nonatomic) FlowerType *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
