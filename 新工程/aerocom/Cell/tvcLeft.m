//
//  tvcLeft.m
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcLeft.h"

@implementation tvcLeft

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcLeft"; // 标识符
    tvcLeft *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcLeft" owner:nil options:nil] lastObject];
    }
    return cell;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if( highlighted == YES )
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iosbeijing2"]];
    else
        self.backgroundView = nil;
    
    [super setHighlighted:highlighted animated:animated];
}

@end
