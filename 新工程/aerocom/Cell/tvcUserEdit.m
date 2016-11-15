//
//  tvcUserEdit.m
//  aerocom
//
//  Created by 丁付德 on 15/7/8.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcUserEdit.h"

@implementation tvcUserEdit


- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setIsShowLine:(BOOL)isShowLine
{
    _isShowLine = isShowLine;
    self.line.hidden = !isShowLine;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcUserEdit"; // 标识符
    tvcUserEdit *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcUserEdit" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
