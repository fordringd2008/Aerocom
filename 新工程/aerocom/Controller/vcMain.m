//
//  vcMain.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcMain.h"
#import "vcAlbum.h"
#import "vcRemind.h"
#import "vcHistory.h"
#import "vcNew.h"
#import "UIViewController+addProgressView.h"
#import "UUChart.h"
#import "BUIView.h"
#import "UIViewController+Share.h"
#import "vcBind.h"
#import "UIViewController+GetAccess.h"


@interface vcMain() <UUChartDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, vcBindDelegate>
{
    int indexSub;           // 当前的标签  0 ， 1，  2
    NSTimer *timerRefre;
    
    NSArray *arrRealTime;   // 实时的光照， 湿度， 温度
    
    NSMutableArray *arrLight;                   // 光照数组
    NSMutableArray *arrAmbient_temperature;     // 光照数组
    NSMutableArray *arrSoil_moisture;           // 光照数组
    TAlertView *alert;
    BOOL isFirstLoad;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;


@property (weak, nonatomic) IBOutlet UIButton                         *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UIView                           *viewProgress;
@property (weak, nonatomic) IBOutletCollection(UIImageView) NSArray   *smallImage;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSArray       *lblTabBar;
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray      *btnTabBar;
@property (weak, nonatomic) IBOutlet UIView                           *viewUU;
@property (weak, nonatomic) IBOutlet UILabel                          *lblNumber;
@property (weak, nonatomic) IBOutlet UIImageView                      *imvBLE;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewButtonContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewStatueContentHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewUUHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn1X;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn2X;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn3X;


@property (strong, nonatomic) UUChart *                     uuchart;
@property (nonatomic, strong) NSMutableArray *              arrX;   // x轴 集合
@property (nonatomic, strong) NSArray *                     arrData;       // 显示的数据集合  （曲线，圆柱的数据） （数组中嵌套数组）
@property (nonatomic, strong) SystemSettings *              sst;    // 当前用户的是系统设置对象
@property (weak, nonatomic) IBOutlet UIButton *           btnRemind;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSArray *     lblArray;

@end

@implementation vcMain

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRightButton:nil imgName:@"fenxiang"];
    
    [self initData];
    [self initView];
    isFirstLoad = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = self.flower ? self.flower.my_plant_name : kString(@"我的新植物");
    [self setNavTitle:self title:title];
    
    [self selectFirst];
    
    [self refreshView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.flower.bind_device_mac || self.flower.bind_device_mac.length < 36)
    {
        if (isFirstLoad)
        {
            isFirstLoad = NO;
            alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"该植物没有绑定设备？" cancelStr:nil sureStr:@"开启"];
            [alert showWithActionSure:^{
                [self performSegueWithIdentifier:@"main_to_bind" sender:self.flower];
            } cancel:^{}];
        }
    }
    else
    {
        if ([self.Bluetooth.dicConnected.allKeys containsObject:self.flower.bind_device_mac])
        {
            NSLog(@"准备读 uuid : %@",self.flower.bind_device_mac);
            [self.Bluetooth realTime:self.flower.bind_device_mac isBegin:YES];
        }
        else
        {
            NSLog(@"没有连接到");
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.Bluetooth realTime:self.flower.bind_device_mac isBegin:NO];
    [timerRefre stop];
    timerRefre = nil;
    [alert close];
    [super viewDidDisappear:animated];
}


-(void)rightButtonClick
{
    [self ShowShareActionSheet];
}

-(void)initView
{
    self.containHeight.constant = IPhone4 ? ScreenHeight - NavBarHeight : ScreenHeight - 2 * NavBarHeight;
    self.viewTopHeight.constant = RealHeight(110.0);
    self.viewButtonHeight.constant = RealHeight(110.0);
    self.viewButtonContentHeight.constant = 25;//RealHeight(80.0);
    CGFloat x = RealHeight(80.0) * 0.833;
    self.btn1X.constant = self.btn3X.constant = x * 1.5;
    self.btn2X.constant = - x * 1.5;
    
    self.viewUUHeight.constant = RealHeight(700.0);
    self.viewStatueContentHeight.constant = BottomHeight;
    [self.btnRemind setHidden:YES];
    
    NSArray *arrlblText = [NSArray arrayWithObjects:kString(@"光照"),kString(@"湿度"),kString(@"温度"), nil];
    for(int i = 0 ; i < self.lblArray.count; i++)
    {
        UILabel *lbl = self.lblArray[i];
        lbl.text = arrlblText[i];
    }
}

-(void)refreshView
{
    int value = [self.flower.score boolValue] ? [self.flower.score intValue] : 100;
    if (value == 100)
    {
        [self addProgressView:self.viewProgress progress:100];
        self.lblNumber.text = @"100";
    }else
    {
        [self addProgressViewWithAnimation:self.viewProgress progress:value];
        [self beginLabelAnimation:self.lblNumber progress:value];
    }
    
    self.imvBLE.image = IMG(@"ioslanya2");
    if(self.flower.bind_device_mac.length)
    {
        if (timerRefre) {
            [timerRefre stop];
            timerRefre = nil;
        }
        timerRefre = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshImv:) userInfo:nil repeats:YES];
    }
    
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


-(void)selectFirst
{
    indexSub = 0;
    [self selectIndex:0];
}


-(void)initData
{
    self.flower = [FlowerData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"my_plant_id == %@ and my_plant_id_T == %@", self.flower.my_plant_id, self.flower.my_plant_id_T] inContext:DBefaultContext];

    
    self.sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
    
    //  这个数据  只读取本地 不拉取
    if([self isSysTime24])
        self.arrX = [@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23" ] mutableCopy];
    else
        self.arrX = [@[@"AM", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"PM", @"1", @"2", @"3", @"4", @"17", @"5", @"6", @"7", @"8", @"9", @"10", @"11"] mutableCopy];
    
    NSDate *now = [NSDate date];
    NSInteger year = [now getFromDate:1];
    NSInteger month = [now getFromDate:2];
    NSInteger day = [now getFromDate:3];
    
    // 如果今天没有连接上设备， 所有的都是0
    SyncDate *syn = [SyncDate findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and my_plant_id = %@ and year = %d and month = %d and day = %d and sub = 5", self.userInfo.access, self.flower.my_plant_id ? self.flower.my_plant_id : self.flower.my_plant_id_T, year, month, day] inContext:DBefaultContext];
    
    arrLight =[[syn.light componentsSeparatedByString:NSLocalizedString(@",", nil)] mutableCopy];
    arrAmbient_temperature =[[syn.ambient_temperature componentsSeparatedByString:NSLocalizedString(@",", nil)] mutableCopy];
    arrSoil_moisture =[[syn.soil_moisture componentsSeparatedByString:NSLocalizedString(@",", nil)] mutableCopy];
    
    arrLight = [self filterArr:arrLight];
    arrAmbient_temperature = [self filterArr:arrAmbient_temperature];
    arrSoil_moisture = [self filterArr:arrSoil_moisture];
    
    arrLight = [self checkArray:arrLight];
    arrAmbient_temperature = [self checkArray:arrAmbient_temperature];
    arrSoil_moisture = [self checkArray:arrSoil_moisture];
    
    // 这里 温度 要减去 50
    for (int i = 0; i < arrAmbient_temperature.count; i++) {
        NSInteger tem = [arrAmbient_temperature[i] integerValue] ?  [arrAmbient_temperature[i] integerValue] - 50 : 0;
        arrAmbient_temperature[i] = [NSString stringWithFormat:@"%ld", (long)tem];
    }
    //int b = 0;
    // 转换温度
    if (![self.sst.sys_temperature_unit boolValue]) {
        NSMutableArray *arrCopy = [NSMutableArray new];
        for (NSString *str in arrAmbient_temperature)
        {
            NSInteger newTem = [str cTof:[str integerValue]];
            [arrCopy addObject:[NSString stringWithFormat:@"%ld", (long)newTem]];
        }
        arrAmbient_temperature = arrCopy;
    }
    
    self.arrData = @[ arrLight, arrSoil_moisture , arrAmbient_temperature];
}

- (IBAction)btnClick:(UIButton *)sender
{
    if (self.isJumpLock) {
        return;
    }
    self.isJumpLock = YES;
    switch (sender.tag) {
        case 1:
        {
            [self pickImageFromCamera];
        }
            break;
        case 2:
            [self performSegueWithIdentifier:@"main_to_album" sender:self.flower];
            break;
        case 3:
            [self performSegueWithIdentifier:@"main_to_remind" sender:self.flower];
            break;
        case 4:
            [self performSegueWithIdentifier:@"main_to_history" sender:self.flower];
            break;
        case 5:
            [self performSegueWithIdentifier:@"main_to_new" sender:self.flower];
            break;
            
        case 11:
            [self selectIndex:0];
            break;
        case 12:
            [self selectIndex:1];
            break;
        case 13:
            [self selectIndex:2];
            break;
            
        default:
            break;
    }
    __block vcMain *blockSelf = self;
    NextWait(blockSelf.isJumpLock = NO;, 0.5);
}


-(void)restAll
{
    for (int i = 0; i < 3; i++) {
        UILabel *lbl = self.lblTabBar[i];
        lbl.textColor = RGB(24, 177, 17);
        
        UIButton *btn = self.btnTabBar[i];
        [btn setBackgroundColor: RGB(223, 223, 223)];
        
        UIImageView *imV = self.smallImage[i];
        switch (i) {
            case 0:
                imV.image = [UIImage imageNamed:@"taiyang1"];
                break;
            case 1:
                imV.image = [UIImage imageNamed:@"xidu1"];
                break;
            case 2:
                imV.image = [UIImage imageNamed:@"wendu1"];
                break;
            default:
                break;
        }
    }
}

-(void)selectIndex:(int)ind
{
    indexSub = ind;
    [self restAll];
    UILabel *lbl = self.lblTabBar[ind];
    lbl.textColor = RGB(249, 110, 10);
    
    UIButton *btn = self.btnTabBar[ind];
    [btn setBackgroundColor: RGB(189, 189, 189)];
    
    UIImageView *imV = self.smallImage[ind];
    switch (ind) {
        case 0:
            imV.image = [UIImage imageNamed:@"taiyang2"];
            break;
        case 1:
            imV.image = [UIImage imageNamed:@"xidu2"];
            break;
        case 2:
            imV.image = [UIImage imageNamed:@"wendu2"];
            break;
        default:
            break;
    }
    [self changeUUChart];
}

-(void)changeUUChart
{
    if (_uuchart) [_uuchart removeFromSuperview];
    
    CGRect rect = CGRectMake(0, 0, ScreenWidth - 20, RealHeight(700.0));
    self.uuchart = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartLineStyle];
    self.uuchart.Interval = 2;
    [self.uuchart showInView:self.viewUU];
}

-(void)refreshImv:(NSTimer *)timerF
{
    //NSLog(@"self.Bluetooth.dicConnected.count : %d", self.Bluetooth.dicConnected.count);
    //NSLog(@"刷呀刷呀刷呀刷， 我就一直刷");
    if ([self.Bluetooth.dicConnected.allKeys containsObject:self.flower.bind_device_mac] && [GetUserDefault(BLEisON) boolValue])
        self.imvBLE.image = IMG(@"ioslanya");
    else
    {
        self.imvBLE.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], @"ioslanya2"]]] ? [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], @"ioslanya2"]]] : [UIImage imageNamed:@"ioslanya2"];
    }
    
}

#pragma mark UUChartDataSource

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return self.arrX;
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return @[self.arrData[indexSub]];
}


//@optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    switch (indexSub) {
        case 0:
            return @[DRed];// @[RGB(252, 252, 64)]; DRed;
            break;
        case 1:
            return @[RGB(41, 119, 248)];
            break;
        case 2:
            return @[RGB(112, 203, 54)];
            break;
            
        default:
            break;
    }
    return nil;
}


//
//显示数值范围  (Y轴区间)
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    switch (indexSub) {
        case 0:
        case 1:
            return CGRangeMake(100, 0);
            break;
        case 2:
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
    return CGRangeMake(300, 0);
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
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
        NSLog(@"img :%@", IMG(name));
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

#pragma mark - imagepicker delegate  使用相册
-(void)pickImageFromAlbum
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:^{}];
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"main_to_album"])
    {
        vcAlbum *vc = (vcAlbum *)segue.destinationViewController;
        vc.flower = self.flower;
    }
    else if([segue.identifier isEqual:@"main_to_edit"])
    {
        vcNew *vc = (vcNew *)segue.destinationViewController;
        vc.flower = self.flower;
    }
    else if([segue.identifier isEqual:@"main_to_new"])
    {
        vcNew *vc = (vcNew *)segue.destinationViewController;
        vc.flower = self.flower;
    }
    else if([segue.identifier isEqual:@"main_to_history"])
    {
        vcHistory *vc = (vcHistory *)segue.destinationViewController;
        vc.flower = self.flower;
    }  
    else if([segue.identifier isEqual:@"main_to_bind"])                     //  不传值
    {
        vcBind *vc = (vcBind *)segue.destinationViewController;
        vc.delegate = self;
        //vc.flower = self.flower;
    }
    else if([segue.identifier isEqual:@"main_to_remind"])                     //  不传值
    {
        vcRemind *vc = (vcRemind *)segue.destinationViewController;
        vc.flower = self.flower;
    }
}

#pragma mark vcBindDelegate
-(void)bind:(Per *)per
{
    self.flower.bind_device_mac = per.perUUIDString;
    self.flower.bind_device_name = per.perName;
    self.flower.isUpdate = @NO;
    if (per) [self alertBecauseFirstBind];
    DBSave;
    
    
    if (per.perUUIDString) {
        [self.Bluetooth retrievePeripheral:per.perUUIDString];
    }
    
    if (self.flower.my_plant_id && self.flower.bind_device_mac.length)                // 如果服务器有
    {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:self.userInfo.access forKey:@"access"];
        [dic setObject:self.flower.my_plant_name forKey:@"my_plant_name"];
        [dic setObject:self.flower.plant_id forKey:@"plant_id"];
        [dic setObject:self.flower.my_plant_room ? @"01" : @"02" forKey:@"my_plant_room"];
        [dic setObject:self.flower.my_plant_pot ?   @"01" : @"02" forKey:@"my_plant_pot"];
        [dic setObject:self.flower.camera_alert forKey:@"camera_alert"];
        [dic setObject:self.flower.bind_device_name ? self.flower.bind_device_name : @""  forKey:@"bind_device_name"];
        [dic setObject:self.flower.bind_device_mac ? self.flower.bind_device_mac : @"" forKey:@"bind_device_mac"];
        [dic setObject:self.flower.alarm_set forKey:@"alarm_set"];
        [dic setObject:self.flower.my_plant_pic_url ? self.flower.my_plant_pic_url : @"" forKey:@"my_plant_pic_url"];
        [dic setObject:self.flower.my_plant_longitude forKey:@"my_plant_longitude"];
        [dic setObject:self.flower.my_plant_latitude forKey:@"my_plant_latitude"];
        [dic setObject:self.flower.my_plant_id forKey:@"my_plant_id"];
        
        __block vcMain *blockSelf = self;
        RequestCheckNoWaring(
         [net updateMyPlantInfo:dic];,
         [blockSelf dataSuccessBack_updateMyPlantInfo:dic];)
    }
}

-(void)dataSuccessBack_updateMyPlantInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        self.flower.isUpdate = @(YES);
        DBSave;
        LMBShow(@"保存成功");
    }
}


// 赋值前验证， 根据当前的小时 修复
-(NSMutableArray *)checkArray:(NSMutableArray *)array
{
    NSDate *now = [NSDate date];
    NSInteger hourThis = [now getFromDate:4];
    
    if (array.count == 0 || array.count < hourThis)
    {
        NSInteger lastCount = hourThis - array.count;
        for (int i = 0; i < lastCount; i++) {
            [array addObject:@"0"];
        }
    }
    return array;
}

//-(void)checkBLEisBusy:(NSTimer *)timerC
//{
//    if(!self.netManager.isBusy)
//    {
//        NextWait([self.Bluetooth realTime:self.flower.bind_device_mac isBegin:YES];, 2);
//        [timerC stop];
//    } 
//}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (!obj)
        return;
    if (type == 206)
    {
        NSLog(@" ------------------------------------------ > 主界面  回调回来了 -------");
        __block vcMain *blockSelf = self;
        NextWaitInMain(
           indexSub = 0;
           [blockSelf initData];
           [blockSelf selectIndex:0];
           [blockSelf viewDidAppear:YES];);
    }
    else if (type == 207)
    {
        arrRealTime = (NSArray *)obj;
        NSInteger hourThis = [[NSDate date] getFromDate:4];
        if (arrLight.count == hourThis)
        {
            [arrLight addObject:arrRealTime[0]];
            [arrSoil_moisture addObject:arrRealTime[1]];
            
            if (![self.sst.sys_temperature_unit boolValue]) {
                NSInteger temp = [arrRealTime[2] integerValue] + 50;
                [arrAmbient_temperature addObject:[NSString stringWithFormat:@"%ld", (long)temp]];
            }else
                [arrAmbient_temperature addObject:arrRealTime[2]];
        }
        else
        {
            arrLight[hourThis] = arrRealTime[0];
            arrSoil_moisture[hourThis] = arrRealTime[1];
            
            if (![self.sst.sys_temperature_unit boolValue]) {
                NSInteger temp = [arrRealTime[2] integerValue] + 50;
                arrAmbient_temperature[hourThis] = [NSString stringWithFormat:@"%ld", (long)temp];
            }else
                arrAmbient_temperature[hourThis] = arrRealTime[2];
        }
        
        if (arrLight.count > 2) {
            if ([arrLight[arrLight.count - 2] intValue]  == 0 && [arrLight[arrLight.count - 3] intValue] != 0) {
                arrLight[arrLight.count - 2] =  arrLight[arrLight.count - 3];
            }
            if ([arrSoil_moisture[arrSoil_moisture.count - 2] intValue]  == 0 && [arrSoil_moisture[arrSoil_moisture.count - 3] intValue] != 0) {
                arrSoil_moisture[arrSoil_moisture.count - 2] =  arrSoil_moisture[arrSoil_moisture.count - 3];
            }
            if ([arrAmbient_temperature[arrAmbient_temperature.count - 2] intValue]  == 0 && [arrAmbient_temperature[arrAmbient_temperature.count - 3] intValue] != 0) {
                arrAmbient_temperature[arrAmbient_temperature.count - 2] =  arrAmbient_temperature[arrAmbient_temperature.count - 3];
            }
        }
        
        self.arrData = @[ arrLight, arrSoil_moisture , arrAmbient_temperature];
        
        __block vcMain *blockSelf = self;
        NextWait([blockSelf changeUUChart];, 0.1);
    }
    if (type == 301)
    {
        NSLog(@"刷新报警次数 =-------");
        __block vcMain *blockSelf = self;
        NextWaitInMain([blockSelf refreshView];);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}



@end
