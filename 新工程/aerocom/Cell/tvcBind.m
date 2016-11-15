//
//  tvcBind.m
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcBind.h"


@implementation tvcBind

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.btnBind.layer.cornerRadius = (self.frame.size.height - 10 ) / 2.0;
    self.btnBind.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPer:(Per *)per
{
    _per = per;
    [self.btnBind setBackgroundImage:[UIImage imageFromColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    self.lblName.text = per.perName;
    _lblBind.text = per.isBind ? kString(@"解绑") : kString(@"绑定");
}

- (IBAction)btnClick:(UIButton *)sender
{
    //NSLog(@"  ------  s======");
    if (self.per.isBind) {
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"解除绑定？"];
        [alert showWithActionSure:^
         {
             NSLog(kString(@"确定"));
             [self.delegate binding:self.per];
         } cancel:^{
         }];
    }else
    {
        [self.delegate binding:self.per];
    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcBind"; // 标识符
    tvcBind *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcBind" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
