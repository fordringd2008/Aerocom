//
//  tvcRemind.h
//  aerocom
//
//  Created by 丁付德 on 15/7/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcRemind : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imV;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;


@property (nonatomic, strong) Remind *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
