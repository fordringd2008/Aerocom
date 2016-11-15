//
//  tvcNewPlant.m
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcNewPlant.h"

@implementation tvcNewPlant


-(void)layoutSubviews
{
    [super layoutSubviews];
//    self.lblTitle.fdTextAlignment = FDTextAlignmentLeft;
//    self.lblTitle.fdAutoFitMode = FDTextAlignmentLeft;
//    self.lblTitle.fdLineScaleBaseLine = FDLineHeightScaleBaseLineTop;
    self.txfvalue.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.txfvalue];
//    self.lblTitle.
    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)change:(UISegmentedControl *)sender
{
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    NSInteger tagD = self.tagIndex;
    NSLog(@"%ld, tag : %ld", (long)selectedIndex, (long)tagD);
    
    [self.delegate stcChange:selectedIndex tadex:tagD];
}

- (IBAction)txfDidBeginEditing:(UITextField *)sender
{
    //NSLog(@"00000000");
    [self.txfvalue addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.delegate txfChange:sender];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.delegate btnReturnClick];
    return true;
}

-(void)valueChanged:(UITextField  *)sender
{
    //NSString *text = sender.text;
    //NSLog(@"%@",text);
    [self.delegate txfChange:sender];
}

//- (void)textFieldDidChange:(UITextField *)textField
//{
//    if (textField == self.txfvalue) {
//        if (textField.text.length > 20) {
//            textField.text = [textField.text substringToIndex:20];
//        }
//    }
//}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSInteger length = [NSString getLength:textField.text];
    NSString *lang = self.txfvalue.textInputMode.primaryLanguage;// 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-hant"])// 简体中文输入, 繁体中文，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (length > plantNameLength) {
                textField.text = [toBeString substringToIndex:plantNameLength/2];
            }
        }
    }
    else{
        if (length > plantNameLength) {
            textField.text = [toBeString substringToIndex:plantNameLength/2];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger loc = range.location;
    if(loc < 15) {
        return YES;
    }else {
        return NO;
    }
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcNewPlant"; // 标识符
    tvcNewPlant *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcNewPlant" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
