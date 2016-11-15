//
//  vcSet.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcSet.h"
#import "DoubleSlider.h"

#define updateSysSettingInterFackIndex      1312112

@interface vcSet()
{
    BOOL isMetric;
    BOOL isC;
    BOOL isAllowGetAddress;
    NSInteger leftValue;
    NSInteger rightValue;
    
    BOOL isChange;          // 是否变化
}

@property (strong, nonatomic) DoubleSlider *slider;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabels;
@property (weak, nonatomic) IBOutlet UIView *viewSider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcRangeUnit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcTempUnit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcAddress;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;


- (IBAction)sgcChange:(UISegmentedControl *)sender;

@property (strong, nonatomic) NSMutableArray *arrTitle;

@property (strong, nonatomic) SystemSettings *sst;                  // 系统设置对象

@end

@implementation vcSet

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"系统设置"];
    self.isPop = NO;
    
    [self initLeftButton:@"iosmulu"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
    [self initView];
    
    if (self.slider) {
        [self.slider removeFromSuperview];
    }
    self.slider = [DoubleSlider doubleSlider];
    [self.slider addTarget:self action:@selector(valueChangedForDoubleSlider:) forControlEvents:UIControlEventValueChanged];
    self.slider.frame = CGRectMake(20, 20, ScreenWidth - 40, 20);
    self.slider.minSelectedValue = leftValue;
    self.slider.maxSelectedValue = rightValue;
    [self.slider moveSlidersToPosition:@(leftValue * 4.16) rightSlider:@(rightValue * 4.16) animated:NO];
    isChange = NO;
    
    [self.viewSider addSubview:self.slider];
    
}

// 离开页面 保存更改
-(void)viewWillDisappear:(BOOL)animated
{
    if(isChange)
    {
        DBSave;
        self.sst.isUpload = @(NO);
        [NetTool changeType:4 isFinish:NO];
        NSMutableDictionary *dicR = [NSMutableDictionary new];
        [dicR setObject:self.userInfo.access forKey:@"access"];
        [dicR setObject:(self.sst.sys_distance_unit ? @"01" : @"02") forKey:@"sys_distance_unit"];
        [dicR setObject:(self.sst.sys_temperature_unit ? @"01" : @"02") forKey:@"sys_temperature_unit"];
        [dicR setObject:self.sst.sys_notify_time_start forKey:@"sys_notify_time_start"];
        [dicR setObject:self.sst.sys_notify_time_end forKey:@"sys_notify_time_end"];
        [dicR setObject:self.sst.update_time forKey:@"update_time"];
        [dicR setObject:self.sst.getAddress forKey:@"sys_location_status"];
        
        __block vcSet *blockSelf = self;
        RequestCheckNoWaring(
         [net updateSysSetting:dicR];,
         [blockSelf dataSuccessBack_updateSysSetting:dic];)
    }
    [super viewWillDisappear:animated];
}

-(void)initData
{
    // 有网络的况下  拉去接口，  没有的时候读取本地
    // 需要修改
    
    
    self.sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
    //NSLog(@"%@", self.sst);
    
    isMetric = [self.sst.sys_distance_unit boolValue];
    isC = [self.sst.sys_temperature_unit boolValue];
    isAllowGetAddress = [self.sst.getAddress boolValue];
    
    leftValue = [self.sst.sys_notify_time_start integerValue];
    rightValue = [self.sst.sys_notify_time_end integerValue];
    
    
    NSString *leftLabelText = [NSString stringWithFormat:@"%@%@:00", kString(@"开始:"), @(leftValue)];
    NSString *rightLabelText = [NSString stringWithFormat:@"%@%@:00", kString(@"结束:"), @(rightValue)];
    
    self.arrTitle = [@[ kString(@"单位"), kString(@"距离"), kString(@"温度"), kString(@"通知时间"), leftLabelText, rightLabelText, kString(@"位置"), kString(@"获得系统位置") ] mutableCopy];
}

-(void)refreshSlider
{
    self.slider.minSelectedValue = leftValue;
    self.slider.maxSelectedValue = rightValue;
    UILabel *lblLeft = self.arrLabels[4];
    lblLeft.text = self.arrTitle[4];
    UILabel *lblRight = self.arrLabels[5];
    lblRight.text = self.arrTitle[5];
}


-(void)initView
{
    for (int i = 0;  i < 8; i++) {
        UILabel *lbl = self.arrLabels[i];
        lbl.text = self.arrTitle[i];
    }
    self.sgcRangeUnit.selectedSegmentIndex = isMetric;
    self.sgcTempUnit.selectedSegmentIndex = isC;
    self.sgcAddress.selectedSegmentIndex = isAllowGetAddress;
    
    [self.sgcRangeUnit setTitle:kString(@"英制") forSegmentAtIndex:0];
    [self.sgcRangeUnit setTitle:kString(@"公制") forSegmentAtIndex:1];
    [self.sgcTempUnit setTitle:kString(@"℉") forSegmentAtIndex:0];   // @"华氏℉"
    [self.sgcTempUnit setTitle:kString(@"℃") forSegmentAtIndex:1];   // @"摄氏℃"
    [self.sgcAddress setTitle:kString(@"关") forSegmentAtIndex:0];
    [self.sgcAddress setTitle:kString(@"开") forSegmentAtIndex:1];

    if (IPhone4) {
        self.viewMainHeight.constant = ScreenHeight + 1;
    }else
    {
        self.viewMainHeight.constant = ScreenHeight - NavBarHeight - BottomHeight + 1;
    }
//    self.viewMainHeight.constant = ScreenHeight - NavBarHeight - BottomHeight + 1;
}

- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider
{
    isChange = YES;
    leftValue = (NSInteger)ceil(slider.minSelectedValue );
    rightValue = (NSInteger)ceil(slider.maxSelectedValue);
    self.sst.sys_notify_time_start = @(leftValue);
    self.sst.sys_notify_time_end = @(rightValue);
    NSLog(@"%ld, %ld", (long)leftValue, (long)rightValue);
    
    self.arrTitle[4] = [NSString stringWithFormat:@"%@：%ld:00", kString(@"开始"), (long)leftValue];
    self.arrTitle[5] = [NSString stringWithFormat:@"%@：%ld:00", kString(@"结束"), (long)rightValue];
    
    [self refreshSlider];
}


- (IBAction)sgcChange:(UISegmentedControl *)sender {
    isChange = YES;
    switch (sender.tag) {
        case 1:
        {
            isMetric = sender.selectedSegmentIndex;
            self.sst.sys_distance_unit = @(isMetric);
        }
            break;
        case 2:
        {
            isC = sender.selectedSegmentIndex;
            self.sst.sys_temperature_unit = @(isC);
        }
            break;
        case 3:
        {
            isAllowGetAddress = sender.selectedSegmentIndex;
            self.sst.getAddress = @(isAllowGetAddress);
        }
            break;
            
        default:
            break;
    }
}

-(void)dataSuccessBack_updateSysSetting:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSLog(@"更新成功");
        [NetTool changeType:4 isFinish:YES];
        long long update_time = [dic[@"update_time"] longLongValue];
        self.sst.update_time = @(update_time);
        self.sst.isUpload = @(YES);
        DBSave;
    }
    else
    {
        NSLog(@"无网络");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

@end
