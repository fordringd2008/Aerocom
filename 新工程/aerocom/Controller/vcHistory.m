//
//  vcHistory.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcHistory.h"
#import "UUChart.h"
#import "UIViewController+Share.h"
#import "vcAlbum.h"
#import "vcRemind.h"
#import "vcHistory.h"
#import "vcNew.h"
#import "UIViewController+GetAccess.h"

#define getMyPlantDataInterfaceIndex            32212

@interface vcHistory() <UUChartDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger indexSub;             // 当前的标签  0 ， 1
    NSInteger year;                 // 选中的月份
    NSInteger month;                // 选中的年月份
    int beginInt, endInt;           // 起止时间value
    
    
    NSArray * arrDays_List;
    NSArray * arrMonth_List;
}


@property (weak, nonatomic) IBOutlet UISegmentedControl *sgc;
@property (weak, nonatomic) IBOutlet UIView *viewUUTop;
@property (weak, nonatomic) IBOutlet UIView *viewMiddle;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewStatueContentHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnRemind;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;


- (IBAction)sgcChange:(UISegmentedControl *)sender;
- (IBAction)btnClick:(UIButton *)sender;

@property (strong, nonatomic) UUChart *uuchartTop;
@property (strong, nonatomic) UUChart *uuchartMiddle;
@property (strong, nonatomic) UUChart *uuchartBottom;

@property (nonatomic, strong) NSArray *arrDataList;       // 显示的数据集合  （曲线，圆柱的数据） （数组中嵌套数组）(3个的数组)
@property (nonatomic, strong) SystemSettings *sst;        // 当前用户的是系统设置对象


@end

@implementation vcHistory

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"历史数据"];
    [self initRightButton:nil imgName:@"fenxiang"];
    
    [self initGestureRecognize];
    
    [self initView];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSInteger remindCount= [((NSDictionary *)GetUserDefault(RemindCount))[[self.flower.my_plant_id description]] integerValue];
    
    if (remindCount > 0)
    {
        [self.btnRemind setTitle:[NSString stringWithFormat:@"%ld", (long)remindCount] forState:UIControlStateNormal];
        [self.btnRemind setHidden:NO];
    }
    else
    {
        [self.btnRemind setHidden:YES];
    }
}

-(void)rightButtonClick
{
    [self ShowShareActionSheet];
}

-(void)initView
{
    if (!IPhone4)
    {
        self.contentHeight.constant = ScreenHeight - 2 * NavBarHeight;
        self.viewTopHeight.constant = (ScreenHeight - 158 - NavBarHeight ) / 3;
        
    }else
    {
        self.viewTopHeight.constant = (ScreenHeight - 158 - NavBarHeight ) / 2;
        self.contentHeight.constant = ScreenHeight - NavBarHeight + self.viewTopHeight.constant;
    }

    
    //NSLog(@"----- > %f, %f", self.contentHeight.constant, ScreenHeight);
    
    self.viewStatueContentHeight.constant = BottomHeight;
    
    self.sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
    
    //[self refreshSgc];
    [self refreshUUChart];
}


-(void)initData
{
    //先读本地
    indexSub = 0;
    year = [[NSDate date] getFromDate:1];
    month = [[NSDate date] getFromDate:2];
    
    [self refreshDateValue];
    [self readDataFromLocal];
}


-(void)readDataFromLocal
{
    NSArray *arrData = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and my_plant_id == %@ and sub = 5 and dateValue >= %@ and dateValue < %@",self.userInfo.access, self.flower.my_plant_id ? self.flower.my_plant_id : self.flower.my_plant_id_T,@(beginInt), @(endInt), nil] inContext:DBefaultContext];
    if(!indexSub)   // 月
    {
        NSMutableArray *arrLight = [self getEmptyMothArray];
        NSMutableArray *arrsoil = [self getEmptyMothArray];
        NSMutableArray *arrTem = [self getEmptyMothArray];
        for (int i = 0; i < arrData.count; i++)
        {
            SyncDate *sd = arrData[i];
            NSInteger dataInt = [sd.dateValue integerValue];
            NSInteger day = [[self HmF2KIntToDate:dataInt][2] integerValue];
            
            NSString *lightValue = [sd.mean_light description];
            NSString *soilValue = [sd.mean_solimois description];
            NSString *temValue = [sd.mean_ambienttem description];
            arrLight[day-1] = lightValue;
            arrsoil[day-1] = soilValue;
            arrTem[day-1] = temValue;
            
            //NSLog(@"day:%d tem:%@", day, temValue);
        }
        arrLight = [[self filterArr_month:arrLight] mutableCopy];
        arrsoil = [[self filterArr_month:arrsoil] mutableCopy];
        arrTem = [[self filterArr_month:arrTem] mutableCopy];
        
        arrLight = [self checkArray:arrLight isMonth:YES];
        arrsoil = [self checkArray:arrsoil isMonth:YES];
        arrTem = [self checkArray:arrTem isMonth:YES];
        
        // 这里 温度 要减去 50
        for (int i = 0; i < arrTem.count; i++) {
            NSInteger tem = [arrTem[i] integerValue] > 0 ? [arrTem[i] integerValue] - 50 : [arrTem[i] integerValue];
            arrTem[i] = [NSString stringWithFormat:@"%ld", (long)tem];
        }
        
        arrLight = [self betterShow:arrLight];
        arrsoil = [self betterShow:arrsoil];
        arrTem = [self betterShow:arrTem];
        
        // 转换温度
        if (![self.sst.sys_temperature_unit boolValue]) {
            NSMutableArray *arrCopy = [NSMutableArray new];
            for (NSString *str in arrTem)
            {
                NSInteger newTem = [str cTof:[str integerValue]];
                [arrCopy addObject:[NSString stringWithFormat:@"%ld", (long)newTem]];
            }
            arrTem = arrCopy;
        }
        

        
        self.arrDataList = @[ @[arrLight], @[arrsoil], @[arrTem]];
    }
    else
    {
        NSMutableArray *arrLight = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
        NSMutableArray *arrsoil = [arrLight mutableCopy];
        NSMutableArray *arrTem = [arrLight mutableCopy];
        
        int sum_light[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 每一个月的数据总和
        int num_light[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 非0的次数
        
        int sum_soil[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 每一个月的数据总和
        int num_soil[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 非0的次数
        
        int sum_temp[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 每一个月的数据总和
        int num_temp[12] = { 0,0,0,0,0,0,0,0,0,0,0,0 };          // 非0的次数
        
        for (int i = 0; i < arrData.count; i++)
        {
            SyncDate *syn = arrData[i];
            NSInteger dataInt = [syn.dateValue integerValue];
            NSInteger month_Inner = [[self HmF2KIntToDate:dataInt][1] integerValue];
            
            NSString *lightValue =  [syn.mean_light debugDescription];    //dic[@"my_plant_light"];
            NSString *soilValue =  [syn.mean_solimois debugDescription]; // dic[@"my_plant_humidity"];
            NSString *temValue = [syn.mean_ambienttem debugDescription]; //dic[@"my_plant_temperature_c"];
            if(![self.sst.sys_temperature_unit boolValue])
                temValue = [NSString stringWithFormat:@"%ld", (long)[self cTof:([temValue integerValue] ? [temValue integerValue] - 50 : 0)]];
            
            if ([lightValue intValue]) {
                sum_light[month_Inner - 1] += [lightValue intValue];
                num_light[month_Inner - 1] += 1;
            }
            
            if ([soilValue intValue]) {
                sum_soil[month_Inner - 1] += [soilValue intValue];
                num_soil[month_Inner - 1] += 1;
            }
            
            if ([temValue intValue]) {
                sum_temp[month_Inner - 1] += [temValue intValue];
                num_temp[month_Inner - 1] += 1;
            }
        }
        
        for (int i = 0; i < 12; i++)
        {
            arrLight[i] = [NSString stringWithFormat:@"%d", num_light[i] ? (int)ceil(((double)sum_light[i]  / (double)num_light[i])) : 0];
            arrsoil[i] = [NSString stringWithFormat:@"%d", num_soil[i] ? (int)ceil(((double)sum_soil[i]  / (double)num_soil[i])) : 0];
            arrTem[i] = [NSString stringWithFormat:@"%d", num_temp[i] ? (int)ceil(((double)sum_temp[i]  / (double)num_temp[i])) : 0];
            
        }
        arrLight = [[self filterArr:arrLight] mutableCopy];
        arrsoil = [[self filterArr:arrsoil] mutableCopy];
        arrTem = [[self filterArr:arrTem] mutableCopy];
        
        
        arrLight = [self checkArray:arrLight isMonth:NO];
        arrsoil = [self checkArray:arrsoil isMonth:NO];
        arrTem = [self checkArray:arrTem isMonth:NO];
        
        // 这里 温度 要减去 50
        for (int i = 0; i < arrTem.count; i++) {
            NSInteger tem = [arrTem[i] integerValue] ? [arrTem[i] integerValue] - 50 : 0;
            arrTem[i] = [NSString stringWithFormat:@"%ld", (long)tem];
        }
        
        // 转换温度
        if (![self.sst.sys_temperature_unit boolValue]) {
            NSMutableArray *arrCopy = [NSMutableArray new];
            for (NSString *str in arrTem)
            {
                NSInteger newTem = [str cTof:[str integerValue]];
                [arrCopy addObject:[NSString stringWithFormat:@"%ld", (long)newTem]];
            }
            arrTem = arrCopy;
        }
        
//#warning 111
//        arrLight = [@[@"10"] mutableCopy];
//        arrsoil = [@[@"10"] mutableCopy];
//        arrTem = [@[@"10"] mutableCopy];
        
        
        self.arrDataList = @[ @[arrLight], @[arrsoil], @[arrTem] ];
    }
    
    [self refreshUUChart];
}


-(void)initGestureRecognize
{
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    NSInteger thisYear = [[NSDate date] getFromDate:1];
    NSInteger thisMonth = [[NSDate date] getFromDate:2];
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"swipe left");
        if (indexSub)
        {
            year--;
        }
        else
        {
            month = month == 1 ? 12 : month - 1;
            year = month == 12 ? year - 1 : year;
        }
    }
    else if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"swipe right");
        if (indexSub)
        {
            if (thisYear == year) {
                NSLog(@"时间超过了当前");
                return;
            }
            //year = thisYear == year ? year : year + 1;
            year++;
        }
        else
        {
            if (year == thisYear && month == thisMonth) {
                NSLog(@"时间超过了当前");
                return;
            }
            month = month == 12 ? 1 : month + 1;
            year = month == 1 ? year + 1 : year;
        }
    }
    [self refreshData];
}

// 刷新起止日期
-(void)refreshDateValue
{
    if(indexSub)                                                       //  年
    {
        NSMutableArray *arrDateBegin = [NSMutableArray arrayWithObjects:@(year), @(1), @(1), nil];
        beginInt = [self HmF2KDateToInt:arrDateBegin];
        
        NSMutableArray *arrDateEnd = [NSMutableArray arrayWithObjects:@(year), @(12), @(31), nil];
        endInt = [self HmF2KDateToInt:arrDateEnd];
    }
    else                                                               //  月
    {
        NSMutableArray *arrDateBegin = [NSMutableArray arrayWithObjects:@(year), @(month), @(1), nil];
        beginInt = [self HmF2KDateToInt:arrDateBegin];
        
        NSInteger lastDay = [self getDaysByYearAndMonth:year month:month];
        NSMutableArray *arrDateEnd = [NSMutableArray arrayWithObjects:@(year), @(month), @(lastDay), nil];
        endInt = [self HmF2KDateToInt:arrDateEnd];
    }
    
}

-(void)refreshData
{
    [self refreshDateValue];
    
    [self readDataFromLocal];
}

-(NSMutableArray *)getEmptyMothArray
{
    NSMutableArray *arr = [NSMutableArray new];
    NSInteger cout = [self getDaysByYearAndMonth:year month:month];
    for (int i = 1; i <= cout; i++) {
        [arr addObject:@"-1"];
    }
    return arr;
}


-(void)refreshUUChart
{
    [self refreshSgc];
    [self removiewSubViewFrom:self.viewUUTop];
    [self removiewSubViewFrom:self.viewMiddle];
    [self removiewSubViewFrom:self.viewBottom];
    
    
    CGRect rect = CGRectMake(0, 0, RealWidth(1192),self.viewTopHeight.constant);
    self.uuchartTop = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartLineStyle];
    self.uuchartTop.Interval = indexSub ? 1 : 5;
    self.uuchartTop.tag = 91;
    [self.uuchartTop showInView:self.viewUUTop];
    
    
    self.uuchartMiddle = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartLineStyle];
    self.uuchartMiddle.Interval = indexSub ? 1 : 5;
    self.uuchartMiddle.tag = 92;
    
    [self.uuchartMiddle showInView:self.viewMiddle];
    
    self.uuchartBottom = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartLineStyle];
    self.uuchartBottom.Interval = indexSub ? 1 : 5;
    self.uuchartBottom.tag = 93;
    [self.uuchartBottom showInView:self.viewBottom];
}

-(void)refreshSgc
{
    NSString *str;
    switch (month) {
        case 1: str = kString(@"一月"); break;
        case 2: str = kString(@"二月"); break;
        case 3: str = kString(@"三月"); break;
        case 4: str = kString(@"四月"); break;
        case 5: str = kString(@"五月"); break;
        case 6: str = kString(@"六月"); break;
        case 7: str = kString(@"七月"); break;
        case 8: str = kString(@"八月"); break;
        case 9: str = kString(@"九月"); break;
        case 10: str = kString(@"十月"); break;
        case 11: str = kString(@"十一月"); break;
        case 12: str = kString(@"十二月"); break;
        default:break;
    }
    
    [self.sgc setTitle:str forSegmentAtIndex:0];
    [self.sgc setTitle:[NSString stringWithFormat:@"%ld%@", (long)year, kString(@"年")] forSegmentAtIndex:1];
}

-(void)removiewSubViewFrom:(UIView *)view
{
    for (UIView *vw in view.subviews) {
        if ([vw isMemberOfClass:[UUChart class]])
        {
            [vw removeFromSuperview];
        }
    }
}

#pragma mark UUChartDataSource

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    if (!indexSub) {                                        // 月
        return [self getXarrList:year month:month];
    }
    else
        return @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12" ];
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    switch (chart.tag) {
        case 91:
            return self.arrDataList[0];
            break;
        case 92:
            return self.arrDataList[1];
            break;
        case 93:
            return self.arrDataList[2];
            break;
            
        default:
            break;
    }
    return nil;
}


//@optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    switch (chart.tag) {
        case 91:
            return @[RGB(252, 252, 64)];
            break;
        case 92:
            return @[RGB(41, 119, 248)];
            break;
        case 93:
            return @[RGB(112, 203, 54)];
            break;
            
        default:
            break;
    }
    return nil;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}


//显示数值范围  (Y轴区间)
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    switch (chart.tag) {
        case 91:
        case 92:
            return CGRangeMake(100, 0);
            break;
        case 93:
        {
            if ([self.sst.sys_temperature_unit boolValue]) {
                return CGRangeMake(80, -20);
            }else
            {
                NSInteger cEnd = [self cTof:80];
                NSInteger cStart = [self cTof:-20];
                return CGRangeMake(cEnd, cStart);
            }
        }
            break;
            
        default:
            break;
    }
    return CGRangeMake(100, 0);
}

- (IBAction)btnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
            [self pickImageFromCamera];
            break;
        case 2:
            [self performSegueWithIdentifier:@"history_to_album" sender:self.flower];
            break;
        case 3:
            [self performSegueWithIdentifier:@"history_to_remind" sender:self.flower];
            break;
        case 4:
            [self performSegueWithIdentifier:@"history_to_new" sender:self.flower];
            break;
            
        default:
            break;
    }
}
- (IBAction)sgcChange:(UISegmentedControl *)sender
{
    indexSub = sender.selectedSegmentIndex;
    
    [self refreshData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"history_to_album"])
    {
        vcAlbum *vc = (vcAlbum *)segue.destinationViewController;
        vc.flower = sender;
    }
    else if([segue.identifier isEqual:@"history_to_remind"])
    {
        vcRemind *vc = (vcRemind *)segue.destinationViewController;
        vc.flower = sender;
    }
    else if([segue.identifier isEqual:@"history_to_new"])           // 这里进来的的时候
    {
        vcNew *vc = (vcNew *)segue.destinationViewController;
        vc.flower = sender;
    }
}


// 赋值前验证， 根据当前的年月 修复
-(NSMutableArray *)checkArray:(NSMutableArray *)array isMonth:(BOOL)isMonth
{
    NSDate *now = [NSDate date];
    NSInteger yearThis = [now getFromDate:1];
    NSInteger monthThis = [now getFromDate:2];
    NSInteger dayThis = [now getFromDate:3];
    
    if (indexSub && yearThis == year && array.count == 0)
    {
        for (int i = 0; i < monthThis; i++) {
            [array addObject:@"0"];
        }
    }
    else if (!indexSub && yearThis == year && monthThis == month && array.count == 0)
    {
        for (int i = 0; i < dayThis; i++) {
            [array addObject:@"0"];
        }
    }
    else if (indexSub && year == yearThis && array.count < monthThis)
    {
        NSInteger lastCount = monthThis - array.count;
        for (int i = 0; i < lastCount; i++) {
            [array addObject:@"0"];
        }
    }
    else if (!indexSub && year == yearThis && monthThis == month && array.count < dayThis)
    {
        NSInteger lastCount = dayThis - array.count;
        for (int i = 0; i < lastCount; i++) {
            [array addObject: (isMonth ? @"-1" : @"0")];
        }
    }
    return array;
}

#pragma mark - imagepicker delegate  使用相机
-(void)pickImageFromCamera
{
    [self getAccessNext:2 block:^{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:^{ }];
    }];
}

#pragma mark -- 选中图片后的方法
// 选中图片后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    // 压缩图片大小
    CGFloat compressionRatio = 1.0;
    NSData *imgdata = UIImageJPEGRepresentation(image,compressionRatio);
    NSLog(@"------data.length = %lu", (unsigned long)imgdata.length);
    
    NSString * imgType = [self typeForImageData:imgdata];
    NSLog(@"type : %@", imgType);
    NSString *typeStr = @"jpg";
    if (![imgType isEqualToString:@"image/jpeg"] && ![imgType isEqualToString:@"image/png"])
    {
        LMBShow(@"不支持的图片格式");
        return;
    }
    
    if ([imgType isEqualToString:@"image/png"])
    {
        typeStr = @"png";
    }
    
    NSString *name = [NSString stringWithFormat:@"%.0f.%@", [[NSDate date] timeIntervalSince1970], typeStr];
    BOOL isSaveOK =  [self saveImageToDocoment:imgdata name:name];
    if (isSaveOK)
    {
        //        UIImage *img = IMG(name);
        //NSString *str = [NSString stringWithFormat:@"%@/%@", [self getDomentURL], name];
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], name]];
        NSLog(@"-----Newdata.length = %lu", (unsigned long)([typeStr isEqualToString:@"jpg"] ? UIImageJPEGRepresentation(img, 1) : UIImagePNGRepresentation(img)).length);
    }
    
    self.flower.last_photo_time = [NSDate date];   // 最后一次拍照日期
    
    Album *al = [Album MR_createEntityInContext:DBefaultContext];
    al.access = self.userInfo.access;
    al.imgID = @([[NSDate date] timeIntervalSince1970]);
    al.imgName = name;
    al.flowerID = self.flower.my_plant_id ? self.flower.my_plant_id : self.flower.my_plant_id_T;
    al.datetime = [NSDate date];
    DBSave;
    LMBShow(@"已保存到相册");
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


-(NSMutableArray *)filterArr_month:(NSMutableArray *)arr
{
    NSMutableArray *arrNew = [NSMutableArray new];
    NSMutableArray* reversedArray = [[[arr reverseObjectEnumerator] allObjects] mutableCopy];
    
    BOOL isNotFi = NO;
    for (int i = 0; i < arr.count; i++)
    {
        NSString *st = reversedArray[i];
        if ([st integerValue] != -1 || isNotFi)
        {
            [arrNew addObject:st];
            isNotFi = YES;
        }
        else
        {
            isNotFi = NO;
        }
    }
    NSMutableArray *resultArr = [[[arrNew reverseObjectEnumerator] allObjects] mutableCopy];
    return resultArr;
}


-(NSMutableArray *)betterShow:(NSMutableArray *)arr
{
    NSMutableArray *arrResult = [[NSMutableArray alloc] initWithCapacity:arr.count];
    
    int endlenght = (int)arr.count;
    int lenght = 0;
    int datas[arr.count];
    for (int i = 0; i < endlenght; i++) {
        datas[i] = [arr[i] intValue];
    }
    int startDay = -1;
    for (int i = 0; i <= endlenght ; i++)
    {
        if(datas[i] == -1)
        {
            if(startDay == -1)
            {
                startDay = i; //则这是开始的第一天
                lenght = 1;
            }else
            {
                lenght++;
            }
        }
        else
        {
            if(startDay != -1 ) //存在缺失数据
            {
                if(lenght > 7) //则超过7天
                {
                    for (int j = startDay; j < startDay + lenght ; j++)
                    {
                        datas[j] = 0;
                    }
                }
                else
                {
                    int startdata = 0;
                    int enddata = 0;
                    int space = 0;
                    if(startDay==0) //第一天
                    {
                        startdata = 0;
                    }
                    else
                    {
                        startdata = datas[startDay-1];
                    }
                    if(startDay + lenght == endlenght)
                    {
                        enddata = 0;
                    }
                    else
                    {
                        enddata = datas[startDay+lenght];
                    }
                    space = (enddata - startdata) / (lenght + 1);
                    datas[startDay] = startdata + space;
                    for (int j = startDay+1; j <startDay+lenght ; j++) {
                        datas[j]=datas[j-1]+space;
                    }
                }
                startDay=-1;
                lenght=0;
            }
        }
    }
    
    for (int i = 0; i < endlenght; i++)
    {
        arrResult[i] = [NSString stringWithFormat:@"%d", datas[i]];
    }
    
    return arrResult;
}








@end
