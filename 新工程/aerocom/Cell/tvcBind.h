//
//  tvcBind.h
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tvcBindDelegate <NSObject>

-(void)binding:(Per *)per;

@end

@interface tvcBind : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnBind;
@property (weak, nonatomic) IBOutlet UILabel *lblBind;

@property (strong, nonatomic) Per *per;

@property (strong, nonatomic) id<tvcBindDelegate> delegate;

- (IBAction)btnClick:(UIButton *)sender;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
