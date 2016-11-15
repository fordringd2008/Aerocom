//
//  vcUserEdit.m
//  aerocom
//
//  Created by 丁付德 on 15/7/8.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUserEdit.h"
#import "tvcUserEdit.h"
#import "BUIView.h"
#import "TSLocateView.h"
#import "County.h"
#import "State.h"
#import "UIButton+WebCache.h"
#import "UIViewController+GetAccess.h"


@interface vcUserEdit () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    NSInteger selectedIndex;        // 当前选择的table 索引
    NSInteger selectedPickIndex;    // pick选中的索引
    
    NSString *unit;                 // 当前用户的体重单位
    
    NSInteger sexFromPick;          // 用户性别0：男；1：女
    CGFloat heightFromPick;       // 转化后的  cm单位
    CGFloat weightFromPick;       // 转化后的  Kg单位
    
    NSString *sexShow;              // 显示
    NSString *heightShow;           // 显示的
    NSString *weightSHow;
    
    NSString *birthFromPick;        // 10890204
    NSDate *birthFromPickDate;      //
    
    NSInteger  country_code;         // 国家ID
    NSInteger  state_code;           // 地区ID
    NSInteger  city_code;            //        这个不用
    
    County *county_S;                // 用户穿进来的对象   （ 还没有点确定之前的存放 ）
    State  *state_S;                 // 用户穿进来的对象
    
    NSString *address;               // 数据源中 地址显示
    
    NSString * country_name;         // 国家ID
    NSString * state_name;           // 地区ID
    
    BOOL isChange;          // 是否变化
}

@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UIButton *btnImg;

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTableContentHeight;



@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UITableView                   *tabview;
@property (nonatomic, strong) NSMutableArray                *arrData;     // tableview的右侧数据源
@property (nonatomic, strong) UIDatePicker                  *datePicker;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (nonatomic, strong) TSLocateView                  *locateView;

@property (nonatomic, strong) NSMutableArray                *arrHeight;   //50 - 250
@property (nonatomic, strong) NSMutableArray                *arrWeigth;   //20 - 150
@property (nonatomic, strong) NSArray                       *arrSex;      //

@property (strong, nonatomic) SystemSettings *sst;                  // 系统设置对象

- (IBAction)btnImgClick:(id)sender;
@end

@implementation vcUserEdit

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"个人设置"];
    [self initRightButton:nil imgName:@"baocun"];
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initBigView];
    [self initPikerView];
    [self initDatePickerView];
    
    __block vcUserEdit *blockSelf = self;
    self.upLoad_Next = ^(NSString *url)
    {
        // 上传完后的回调
        if(!url.length)
        {
            NSLog(@"图片上传失败");
            LMBShowInBlock(NONetTip);
        }else
        {
            blockSelf.userInfo.user_pic_url = url;
            DBSave;
            [blockSelf saveToServer];
        }
    };
}


-(void)dealloc
{
    self.upLoad_Next = nil;
}

-(void)rightButtonClick
{
    [self save];
}


-(void)initData
{
    self.sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
    unit = [self.sst.sys_distance_unit boolValue] ? @"Kg" : @"Lb";
    
    sexFromPick = [self.userInfo.user_gender integerValue];
    heightFromPick = [self.userInfo.user_height doubleValue];
    weightFromPick = [self.userInfo.user_weight doubleValue];
    
    if ([self.sst.sys_distance_unit boolValue])
    {
        heightShow = [NSString stringWithFormat:@"%ldcm", (long)heightFromPick];
        weightSHow = [NSString stringWithFormat:@"%ldKg", (long)weightFromPick];
    }
    else
    {
        NSInteger ft = [self.userInfo.user_height doubleValue] * CmToFt;
        NSInteger iN = round(([self.userInfo.user_height doubleValue] * CmToFt - ft) * 12);
        heightShow = [NSString stringWithFormat:@"%ld'%ld''", (long)ft, (long)iN];
        
        CGFloat wei = [self.sst.sys_distance_unit boolValue] ? [self.userInfo.user_weight doubleValue] : [self.userInfo.user_weight doubleValue] / KgToLb;
        weightSHow = [NSString stringWithFormat:@"%.0f%@", round(wei), unit];
    }
    
    
    birthFromPick = [self.userInfo.user_birthday toString:@"YYYYMMdd"];
    birthFromPickDate = self.userInfo.user_birthday;
    country_code = [self.userInfo.user_country_code integerValue];
    state_code = [self.userInfo.user_state_code integerValue];
    city_code = [self.userInfo.user_city_code integerValue];

    
    self.arrHeight = [NSMutableArray new];
    self.arrWeigth = [NSMutableArray new];
    
    int begigWeight = 20;
    int endWeight = 150;
    if (![unit isEqualToString:@"Kg"]) {
        begigWeight = 44;
        endWeight = 331;
    }
    for (int i = begigWeight; i <= endWeight; i++)
        [self.arrWeigth addObject:[NSString stringWithFormat:@"%d%@", i, unit]];
    
    //   1.7  8.2
    
    if ([self.sst.sys_distance_unit boolValue])
        for (int i = 50; i <= 250; i++)
            [self.arrHeight addObject:[NSString stringWithFormat:@"%dcm", i]];
    else
        for (int i = 1; i <= 8; i++)
            for (int j = 1; j < 12; j++)
                if ((i == 1 && j >= 7) || (i == 8 && j <= 2) || (i != 1 && i != 8))
                     [self.arrHeight addObject:[NSString stringWithFormat:@"%d'%d''", i, j]];
    
    self.arrSex = @[kString(@"男"), kString(@"女")];
    self.arrData = [NSMutableArray new];
    
    // 这个一定要在这里初始化
    self.locateView = [[TSLocateView alloc] initWithTitle:@"" delegate:self];          // 读取json数据  写入数据库
    
    NSNumber *lang = @([self getPreferredLanguage]);
    County *userCounty = [[County findAllWithPredicate:[NSPredicate predicateWithFormat:@"countyID =  %@ and language = %@", self.userInfo.user_country_code, lang] inContext:DBefaultContext] firstObject];
    State *userState = [[State findAllWithPredicate:[NSPredicate predicateWithFormat:@"stateID = %@ and county.countyID = %@ and language = %@", self.userInfo.user_state_code, userCounty.countyID, lang] inContext: DBefaultContext] firstObject];
    
    address = [NSString stringWithFormat:@"%@ %@", userCounty.countyName, userState.stateName];

    [self.arrData addObject:address];
    [self.arrData addObject: [self.userInfo.user_gender boolValue] ? kString(@"女") : kString(@"男")];
    [self.arrData addObject:heightShow];
    [self.arrData addObject:weightSHow];
    NSString *strDate = [self.userInfo.user_birthday toString:@"YYYY / MM / dd"];
    [self.arrData addObject:strDate];
}

-(void)initView
{
    self.viewMainContentHeight.constant = ScreenHeight - NavBarHeight - BottomHeight + 1;
    
    self.viewTopHeight.constant = self.viewTableHeight.constant = RealHeight(70.0);
    self.viewTopContentHeight.constant = RealHeight(450.0);
    self.viewTableContentHeight.constant = RealHeight(850.0);
    
    [self.btnImg sd_setBackgroundImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url]  forState:UIControlStateNormal placeholderImage:DefaultLogoImage];
    
    self.btnImg.layer.cornerRadius = RealHeight(450.0) / 1.2 * 0.5;
    self.btnImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnImg.layer.borderWidth = 1;
    [self.btnImg.layer setMasksToBounds:YES];
    

    [self initTableview];
}



-(void)initTableview
{
    self.tabview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, RealHeight(850.0))];
    self.tabview.dataSource = self;
    self.tabview.delegate = self;
    self.tabview.scrollEnabled = NO;
    self.tabview.rowHeight = RealHeight(850.0) / 5.0;
    self.tabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabview registerNib:[UINib nibWithNibName:@"tvcUserEdit" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.viewTable addSubview: self.tabview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcUserEdit *cell = [tvcUserEdit cellWithTableView:tableView];
    cell.isShowLine = indexPath.row != 4;
    switch (indexPath.row) {
        case 0:
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"地区")];//
            break;
        case 1:
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"性别")];//;
            break;
        case 2:
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"身高")];//;
            break;
        case 3:
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"体重")];//;
            break;
        case 4:
            cell.lblTitle.text = [NSString stringWithFormat:@"%@:", kString(@"出生日期")];//;
            break;
    }
    cell.lblName.text = self.arrData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.pickView.hidden = YES;
    self.datePicker.hidden = YES;
    self.locateView.hidden = YES;
    
    switch (indexPath.row) {
        case 0:
            self.locateView.hidden = NO;
            break;
        case 1:
        {
            self.pickView.hidden = NO;
            [self.pickView selectRow:[self getPickViewIndex:1] inComponent:0 animated:NO];
            [self.pickView reloadAllComponents];
        }
            break;
        case 2:
        {
            self.pickView.hidden = NO;
            [self.pickView selectRow:[self getPickViewIndex:2] inComponent:0 animated:NO];
            [self.pickView reloadAllComponents];
        }
            break;
        case 3:
        {
            self.pickView.hidden = NO;
            [self.pickView selectRow:[self getPickViewIndex:3] inComponent:0 animated:NO];
            [self.pickView reloadAllComponents];
        }
            break;
        case 4:
            self.datePicker.hidden = NO;
            self.datePicker.date = birthFromPickDate;
            break;
            
        default:
            break;
    }
    [self pickerViewPopAnimationsRelod:NO];
}

// 获取当前的选中的内容在pickView中的索引
-(NSInteger)getPickViewIndex:(NSInteger)ind
{
    NSInteger inde = 0;
    switch (ind) {
        case 1:
        {
            inde = sexFromPick;
        }
            break;
        case 2:
        {
            for (NSInteger i = 0; i < self.arrHeight.count; i++)
            {
                if ([self.arrHeight[i] isEqualToString:heightShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 3:
        {
            for (NSInteger i = 0; i < self.arrWeigth.count; i++)
            {
                if ([self.arrWeigth[i] isEqualToString:weightSHow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
            
        default:
            break;
    }
    return  inde;
}
-(void)initBigView
{
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight - 300, self.bgView.bounds.size.width, 44)];
    toolBarView.tag = 453;
    toolBarView.backgroundColor = RGB(24, 177, 17);
    
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(pickerViewCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.frame = CGRectMake(10, 0, 80, 44);
    [toolBarView addSubview:CancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
    [confirmButton addTarget:self action:@selector(pickerViewConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:confirmButton];
    [self.bgView addSubview:toolBarView];
    [self.view addSubview:self.bgView];
    [self.locateView showInView:self.bgView];
}

-(void)initPikerView
{
    self.pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)ISIOS < 9) ? 286 : 256) - NavBarHeight)];
    self.pickView.backgroundColor = RGB(239, 239, 239);
    self.pickView.dataSource = self;
    self.pickView.delegate = self;
    [self.bgView addSubview:self.pickView];
}

//初始化DatePickerView
- (void)initDatePickerView
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256 - NavBarHeight)];
    NSInteger langIndex = [self getPreferredLanguage];
    switch (langIndex) {
        case 1:
            [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
            break;
        case 2:
            [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]];
            break;
        case 3:
            [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"fr_FR"]];
            break;
            
        default:
            break;
    }
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    self.datePicker.date = birthFromPickDate;
    self.datePicker.backgroundColor = RGB(239, 239, 239);
    self.datePicker.maximumDate = [NSDate date];
    [self.bgView addSubview:self.datePicker];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pickerViewDisappear];
}

#pragma mark PickerView取消按钮事件
- (void)pickerViewCancelButtonClick
{
    [self pickerViewDisappear];
}

#pragma mark PickerView确定按钮事件
- (void)pickerViewConfirmButton
{
    isChange = YES;
    [self pickerViewDisappear];
    switch (selectedIndex) {
        case 0:
        {
            if (county_S && state_S) {
                country_name = county_S.countyName;
                state_name = state_S.stateName;
                country_code = [county_S.countyID integerValue];
                state_code = [state_S.stateID integerValue];
                address = [NSString stringWithFormat:@"%@ %@", country_name, state_name];
                
                self.arrData[0] = address;
                [self.tabview reloadData];
            }
        }
            break;
        case 1:
        {
            NSString *sex = sexShow = self.arrSex[selectedPickIndex];
            self.arrData[1] = sex;
            sexFromPick = selectedPickIndex;
        }
            break;
        case 2:
        {
            NSString *height = self.arrHeight[selectedPickIndex];
            if ([self.sst.sys_distance_unit boolValue]) {
                self.arrData[2] = heightShow = [NSString stringWithFormat:@"%@", height];
                heightFromPick = [height integerValue];
            }
            else
            {
                self.arrData[2] = heightShow = [NSString stringWithFormat:@"%@", height];
                NSArray *arr = [height componentsSeparatedByString:@"'"];
                NSInteger ft = [arr[0] integerValue];
                NSInteger iN = [arr[1] integerValue];
                heightFromPick = (ft +  (double)iN / 12.0) / CmToFt;
            }
            
        }
            break;
        case 3:
        {
            NSString *weight = self.arrWeigth[selectedPickIndex];
            if ([self.sst.sys_distance_unit boolValue])
            {
                self.arrData[3] = weightSHow = [NSString stringWithFormat:@"%@", weight];
                weightFromPick = [weight integerValue];
            }
            else
            {
                self.arrData[3] = weightSHow = [NSString stringWithFormat:@"%@", weight];
                weightFromPick =  [weight floatValue] * KgToLb;
            }
        }
            break;
        case 4:
        {
            NSString *birth = [[self.datePicker date] toString:@"YYYY / MM / dd"];
            self.arrData[4] = birth;
            
            birthFromPickDate = [self.datePicker date] ;
            birthFromPick = [birthFromPickDate toString:@"YYYYMMdd"];
        }
            break;
            
        default:
            break;
    }
    [self.tabview reloadData];
}

//pickView弹出动画
-(void)pickerViewPopAnimationsRelod:(BOOL)isPicker
{
    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        [self.bgView setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    if (isPicker) {
        [self.pickView reloadAllComponents];
    }
}

- (void)pickerViewDisappear
{
    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.bgView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {
        self.pickView.hidden = YES;
        self.pickView.hidden = YES;
    }];
    
}


// 裁减图片
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark -- 选中图片后的方法
// 选中图片后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    // 压缩图片大小
    CGFloat compressionRatio = 1.0;
    self.imgdata = UIImageJPEGRepresentation(image,compressionRatio);
    
    self.imgType = [self typeForImageData:self.imgdata];
    NSLog(@"type : %@", self.imgType);
    if (![self.imgType isEqualToString:@"image/jpeg"] && ![self.imgType isEqualToString:@"image/png"])
    {
        LMBShow(@"不支持的图片格式");
        return;
    }
    NSUInteger length = [self.imgdata length] / 1024;
    while (length > 100) {
        compressionRatio /= 2.0;
        self.imgdata = UIImageJPEGRepresentation(image, compressionRatio);
        length = [self.imgdata length] / 1024;
    }
    [self.btnImg setBackgroundImage:image forState:UIControlStateNormal];
    
    
    // 先存在本地  等到用户点击保存的时候， 才保存在本地
    if ([self.imgType isEqualToString:@"image/jpeg"]) {
        self.imgdata = UIImageJPEGRepresentation(image, 1);
    }else
    {
        self.imgdata = UIImagePNGRepresentation(image);
    }

    [self dismissViewControllerAnimated:YES completion:^{}];
    isChange = YES;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (selectedIndex) {
        case 1:
            return 2;
            break;
        case 2:
            return  self.arrHeight.count;
            break;
        case 3:
            return  self.arrWeigth.count;
            break;
            
        default:
            break;
    }
    return  2;
}

#pragma mark UIPickerViewDataSource;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (selectedIndex) {
        case 1:
            return  self.arrSex[row];
            break;
        case 2:
            return  self.arrHeight[row];
            break;
        case 3:
            return  self.arrWeigth[row];
            break;
            
        default:
            break;
    }
    return  @"";
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedPickIndex = row;
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

- (IBAction)btnImgClick:(id)sender
{
    TAlertView *alter = [[TAlertView alloc] initWithTitle:@"修改头像" message:@"11"];
    [alter showActionCamera:^{
        [self pickImageFromCamera];
    } photoA:^{
        [self pickImageFromAlbum];
    }];
}

#pragma mark - imagepicker delegate  使用相册
-(void)pickImageFromAlbum
{
    [self getAccessNext:1 block:^{}];
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


// 保存的时候，如果有网络， 就上传，没有网络，要保存在本地
-(void)save
{
    if (isChange)
    {
        self.userInfo.user_country_code = @(country_code);
        self.userInfo.user_state_code = @(state_code);
        self.userInfo.user_gender = @(sexFromPick);
        self.userInfo.user_height = @(heightFromPick);
        self.userInfo.user_weight = @(weightFromPick);
        self.userInfo.user_birthday = birthFromPickDate;
        self.userInfo.imageData = self.imgdata;
        self.userInfo.imageType = self.imgType;
        self.userInfo.isUpate = @(NO);
        self.userInfo.update_time =  @([[NSDate date] timeIntervalSince1970] * 1000);
        DBSave;
        
        [NetTool changeType:3 isFinish:NO];
        
        if (![GetUserDefault(DNet) boolValue]) {
            LMBShow(@"个人信息更新成功");
            [self backAfterOneSecond];
        }else
        {
            MBShowAll;
            __block vcUserEdit *blockSelf = self;
            HDDAF;
            if (self.imgdata)                              // 如果用户更改了图片
                [self getTokenAndUpload];
            else
                [self saveToServer];
        }
        

        
        
//        RequestBeforeCheck
//        (
//         if (netState)
//         {
//             MBShowAll;
//             NextWait(MBHide;, 7);
//             if (self.imgdata) {                              // 如果用户更改了图片
//                 [self getTokenAndUpload];
//             }
//             else
//             {
//                 [self saveToServer];
//             }
//         }
//         else
//         {
//             LMBShowSuccess(@"个人信息更新成功");
//             NSLog(@"没有网络， 暂时存在本地，等待有网络的时候上传");
//             [self backAfterOneSecond];
//         }
//        );
    }
    else
    {
        NSLog(@"没有修改");
    }
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        MBHide;
        //self.userInfo = [[UserInfo findByAttribute:@"access" withValue:self.userInfo.access] firstObject];
        self.userInfo.update_time = @([[dic[@"update_time"] description] longLongValue]);
        self.userInfo.isUpate = @(YES);
        self.imgdata = self.userInfo.imageData = nil;     // 上传完成后，  清空
        self.imgType = self.userInfo.imageType = nil;
        DBSave;
        [NetTool changeType:3 isFinish:YES];
        LMBShow(@"个人信息更新成功");
        [self backAfterOneSecond];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TSLocateView *locateView = (TSLocateView *)actionSheet;
    TSLocation *location = locateView.locate;
    // 这里不能赋值 需要修改
    county_S = location.county_S;
    state_S = location.state_S;
}


-(void)saveToServer
{
    NSMutableDictionary *dicUp = [NSMutableDictionary new];
    [dicUp setObject:self.userInfo.access forKey:@"access"];
    [dicUp setObject:[self.userInfo.user_pic_url isEqualToString:@"touxiang"] ? @"": self.userInfo.user_pic_url  forKey:@"user_pic_url"];
    [dicUp setObject:self.userInfo.user_nick_name ? self.userInfo.user_nick_name : @"" forKey:@"user_nick_name"];
    [dicUp setObject:@(country_code) forKey:@"user_country_code"];
    [dicUp setObject:@(state_code) forKey:@"user_state_code"];
    [dicUp setObject:@(sexFromPick) forKey:@"user_gender"];
    [dicUp setObject:@(heightFromPick) forKey:@"user_height"];
    [dicUp setObject:@(weightFromPick) forKey:@"user_weight"];
    [dicUp setObject:birthFromPick  forKey:@"user_birthday"];
    
    __block vcUserEdit *blockSelf = self;
    RequestCheckNoWaring(
     [net updateUserInfo:dicUp];,
     [blockSelf dataSuccessBack_updateUserInfo:dic];)
}



//- (void)readDataFromJSON
//{
//    NSInteger langIndex = [[NSObject new] getPreferredLanguage];   // 获取当前语言
//    
//    NSNumber *language = @1;
//    switch (langIndex) {
//        case 1:
//        {
//            language = @1;
//        }
//            break;
//        case 2:
//        {
//            language = @2;
//        }
//            break;
//        case 3:
//        {
//            language = @3;
//        }
//            break;
//    }
//    
//    NSArray *countyFromLocal = [County findByAttribute:@"language" withValue:language];
//    
//    if (countyFromLocal.count == 0)
//    {
//        NSLog(@"读取json  并写入本地数据库");
//        NSData *data = [self getCountiesAndCitiesrDataFromJSON];
//        NSDictionary *dicData = (NSDictionary *)data;
//        
//        NSArray *arrCounty = dicData[@"Location"][@"CountryRegion"];
//        for (int i = 0; i < arrCounty.count; i++)
//        {
//            County *cou = [County MR_createEntityInContext:DBefaultContext];
//            cou.language = language;
//            cou.countyID = @(i);
//            cou.countyName = arrCounty[i][@"@attributes"][@"Name"];
//            cou.writeTime = [NSDate date];
//            NSMutableArray *arrSet = [NSMutableArray new];
//            
//            NSArray *arState = nil;
//            arState = arrCounty[i][@"State"];
//            if (!arState)
//            {
//                State *st = [State MR_createEntityInContext:DBefaultContext];
//                st.county = cou;
//                st.language = language;
//                st.stateID =  cou.countyID;
//                st.stateName = cou.countyName;
//                st.writeTime = [NSDate date];
//                [arrSet addObject:st];
//            }
//            else if (arState.count == 1) {
//                arState = arrCounty[i][@"State"][@"City"];
//                for (int j = 0; j < arState.count; j++) {
//                    State *st = [State MR_createEntityInContext:DBefaultContext];
//                    st.county = cou;
//                    st.language = language;
//                    st.stateID = @(j);
//                    st.stateName = arState[j][@"@attributes"][@"Name"];
//                    st.writeTime = [NSDate date];
//                    [arrSet addObject:st];
//                }
//            }
//            else
//            {
//                for (int j = 0; j < arState.count; j++) {
//                    State *st = [State MR_createEntityInContext:DBefaultContext];
//                    st.county = cou;
//                    st.language = language;
//                    st.stateID = @(j);
//                    st.stateName = arState[j][@"@attributes"][@"Name"];
//                    st.writeTime = [NSDate date];
//                    [arrSet addObject:st];
//                }
//            }
//            
//            NSSet *stateSet = [NSSet setWithArray:[arrSet mutableCopy]];
//            [cou addStates:stateSet];
//        }
//        DBSave;
//    }
//}





@end
