//
//  tvcFlowerList.m
//  aerocom
//
//  Created by 丁付德 on 15/7/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcFlowerList.h"

@implementation tvcFlowerList

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(FlowerType *)model
{
    _model = model;
    UIImage *imagesss = ImageFromLocal(model.icon);
    
    self.imv.image = imagesss;
    self.lblTitle.text = model.name;
    self.lblDetail.text = model.scientificname;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFlowerList"; // 标识符
    tvcFlowerList *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell = nil;
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFlowerList" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
