//
//  tvcLeft.h
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcLeft : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imgBig;
@property (weak, nonatomic) IBOutlet UIImageView *imvRight;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
