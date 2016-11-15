//
//  tvcUserEdit.h
//  aerocom
//
//  Created by 丁付德 on 15/7/8.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcUserEdit : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *line;

@property (assign, nonatomic) BOOL isShowLine;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
