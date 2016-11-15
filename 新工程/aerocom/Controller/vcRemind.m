//
//  vcRemind.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcRemind.h"
#import "tvcRemind.h"

#define getAlarmInfoInterFaceIndex              8728472

@interface vcRemind() <UITableViewDelegate, UITableViewDataSource>
{
    int dateValue;
}



@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, strong) UITableView *tabView;

@end

@implementation vcRemind

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.title = kString(@"");我的花园
    [self setNavTitle:self title:@"提醒"];
    
    [self initData];
    [self initView];
}

-(void)initData
{
    NSDate *yesteryesterday = [NSDate dateWithTimeIntervalSinceNow:-2 * 24 * 60 * 60];
    dateValue = [self HmF2KNSDateToInt:yesteryesterday];
    NSMutableDictionary *dicR = [NSMutableDictionary new];
    [dicR setObject:self.userInfo.access forKey:@"access"];
    [dicR setObject:@(dateValue) forKey:@"k_date"];
    [self refreshData];
    
    
    // 读取完本地， 有网的时候拉取下网络
    __block vcRemind *blockSelf = self;
    RequestCheckNoWaring(
         [net getAlarmInfo:dicR];,
         [blockSelf dataSuccessBack_getAlarmInfo:dic];)
}

-(void)refreshData
{
    self.arrData = [[Remind findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date > %@ and flower_Id == %@", self.userInfo.access, @(dateValue), self.flower.my_plant_id] inContext:DBefaultContext] mutableCopy];
    
    NSMutableArray *arrIndex = [NSMutableArray new];
    for (int i = 0; i< self.arrData.count ; i++)
    {
        Remind *rd = self.arrData[i];
        if (fabs([rd.remindDate timeIntervalSinceNow]) > 24 * 60 * 60)
        {
            [arrIndex addObject:@(i)];
        }
    }
    for (int i = (int)arrIndex.count; i == 0 && arrIndex.count; i--)
    {
        int indexI = [arrIndex[i] intValue];
        [self.arrData removeObjectAtIndex:indexI];
    }
    
    NSMutableDictionary *dicR = [(NSDictionary *)GetUserDefault(RemindCount) mutableCopy];
    [dicR setValue:@(0) forKey:[self.flower.my_plant_id description]];
    SetUserDefault(RemindCount, dicR);
    [self.tabView reloadData];
}


-(void)initView
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = 55;
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = RGB(245, 245, 245);
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcRemind" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tabView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcRemind *cell = [tvcRemind cellWithTableView:tableView];
    Remind *model = self.arrData[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)dataSuccessBack_getAlarmInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSArray *arrData = dic[@"alarm_info"];
        for (int i = 0; i < arrData.count ; i++)
        {
            // 这里离
            NSDictionary *dic = arrData[i];
            NSNumber *my_plant_id = @([dic[@"my_plant_id"] integerValue]);
            NSString *alarm_type = dic[@"alarm_type"];
            NSString *alarm_sub_type = dic[@"alarm_sub_type"];
            NSNumber *k_date = @([dic[@"k_date"] integerValue]);
            Remind *rd = [Remind findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and flower_Id == %@ and alarm_type == %@ and alarm_sub_type == %@ and k_date == %@", self.userInfo.access, my_plant_id, alarm_type, alarm_sub_type, k_date ] inContext:DBefaultContext];
            if (!rd)
            {
                rd = [Remind MR_createEntityInContext:DBefaultContext];
                rd.access = self.userInfo.access;
                rd.flower_Id = my_plant_id;
                rd.alarm_type = alarm_type;
                rd.alarm_sub_type = alarm_sub_type;
                rd.k_date = @(dateValue);
                rd.isUpload = @(YES);
                
                rd.remindDate = [self getDateTimeFormDateValue:dateValue];
                NSLog(@"%@", rd.remindDate);
                DBSave;
            }
            
            [self refreshData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}




@end
