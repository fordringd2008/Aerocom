//
//  vcWain.m
//  aerocom
//
//  Created by 丁付德 on 15/7/13.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcWain.h"

@interface vcWain ()
{
    NSMutableArray *arr;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcLight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcTemp;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcSoil;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcCamera;

@property (weak, nonatomic) IBOutlet UILabel *lblLight;
@property (weak, nonatomic) IBOutlet UILabel *lblTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblSoil;
@property (weak, nonatomic) IBOutlet UILabel *lblCamera;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewManiContentHeight;


- (IBAction)sgcChange:(UISegmentedControl *)sender;

@end

@implementation vcWain

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"提醒设置"];
    
    [self initRightButton:nil imgName:@"baocun"];
    
    
    
    self.viewManiContentHeight.constant = ScreenHeight - NavBarHeight - BottomHeight + 1;
    
    
    self.lblLight.text = kString(@"光照");
    self.lblTemp.text = kString(@"温度");
    self.lblSoil.text = kString(@"湿度");
    self.lblCamera.text =kString(@"拍照");
    [self.sgcLight setTitle:kString(@"开") forSegmentAtIndex:0];
    [self.sgcLight setTitle:kString(@"关") forSegmentAtIndex:1];
    
    [self.sgcTemp setTitle:kString(@"开") forSegmentAtIndex:0];
    [self.sgcTemp setTitle:kString(@"关") forSegmentAtIndex:1];
    
    [self.sgcSoil setTitle:kString(@"开") forSegmentAtIndex:0];
    [self.sgcSoil setTitle:kString(@"关") forSegmentAtIndex:1];
    
    [self.sgcCamera setTitle:kString(@"开") forSegmentAtIndex:0];
    [self.sgcCamera setTitle:kString(@"关") forSegmentAtIndex:1];
    
    NSArray *array = [self.wariString componentsSeparatedByString:@"-"];
    
    arr = [NSMutableArray arrayWithArray:array];
    self.sgcLight.selectedSegmentIndex = [arr[0] boolValue] ? 0: 1;
    self.sgcTemp.selectedSegmentIndex = [arr[1] boolValue] ? 0: 1;
    self.sgcSoil.selectedSegmentIndex = [arr[2] boolValue] ? 0: 1;
    self.sgcCamera.selectedSegmentIndex = [arr[3] boolValue] ? 0: 1;
}

-(void)rightButtonClick
{
    [self.delegate chaneIsWain:self.wariString];
    [self back];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sgcChange:(UISegmentedControl *)sender
{
    arr[sender.tag - 1] = sender.selectedSegmentIndex == 0 ? @"1" : @"0";
    self.wariString = [NSString stringWithFormat:@"%@-%@-%@-%@", arr[0], arr[1], arr[2], arr[3]];
}
@end
