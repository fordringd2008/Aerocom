//
//  tvcRemind.m
//  aerocom
//
//  Created by 丁付德 on 15/7/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcRemind.h"

@implementation tvcRemind

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setModel:(Remind *)model
{
    _model = model;
    if ([model.alarm_type isEqualToString:@"01"])
    {
        self.lblTitle.text = kString(@"拍照提醒");
        self.lblContent.text = kString(@"您好久没给植物拍照了");
        self.imV.image = IMG(@"Photograph");
    }
    else if ([model.alarm_type isEqualToString:@"02"])
    {
        self.lblTitle.text = kString(@"光照提醒");
        if([model.alarm_sub_type isEqualToString:@"00"])
        {
            self.lblContent.text = Remind_Meg_Light_Low; // Illumination
            self.imV.image = IMG(@"Illumination");
        }
        else
        {
            self.lblContent.text = Remind_Meg_Light_Hight;
            self.imV.image = IMG(@"Illumination_2");
        }
    }
    else if ([model.alarm_type isEqualToString:@"03"])
    {
        self.lblTitle.text = kString(@"温度提醒");
        if([model.alarm_sub_type isEqualToString:@"00"])
        {
            self.lblContent.text = Remind_Meg_Tem_LowEst;
            self.imV.image = IMG(@"Temperature");
        }
        else if([model.alarm_sub_type isEqualToString:@"01"])
        {
            self.lblContent.text = Remind_Meg_Tem_Low;
            self.imV.image = IMG(@"Temperature");
        }
        else if([model.alarm_sub_type isEqualToString:@"02"])
        {
            self.lblContent.text = Remind_Meg_Tem_Hight;
            self.imV.image = IMG(@"Temperature_2");
        }
        else
        {
            self.lblContent.text = Remind_Meg_Tem_HightEst;
            self.imV.image = IMG(@"Temperature_2");
        }
    }
    else if ([model.alarm_type isEqualToString:@"04"])
    {
        self.lblTitle.text = kString(@"湿度提醒");
        if([model.alarm_sub_type isEqualToString:@"00"])
        {
            self.lblContent.text = Remind_Meg_Soil_Low;
            self.imV.image = IMG(@"Humidity");
        }
        else
        {
            self.lblContent.text = Remind_Meg_Soil_Hight;
            self.imV.image = IMG(@"Humidity_2");
        }
    }
    
    NSMutableArray *arrDate = [self HmF2KIntToDate:[model.k_date integerValue]];
    self.lblDateTime.text = [NSString stringWithFormat:@"%@: %@/%@/%@", kString(@"时间"), arrDate[0], arrDate[1], arrDate[2]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcRemind"; // 标识符
    tvcRemind *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcRemind" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
