    //
//  vcNew.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcNew.h"
#import "tvcNewPlant.h"
#import "BUIView.h"
#import "vcBind.h"
#import "vcWain.h"
#import "Myanotation.h"
#import "vcHistory.h"
#import "UIViewController+GetAccess.h"
#import "LNNotificationsUI.h"
//#warning 测试
//#import "GUAAlertView.h"

static const NSArray                *roomAndOut;
static const NSArray                *earthAndFlowerpot;


@interface vcNew() <UITableViewDelegate, UITableViewDataSource, tvcNewPlantDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, vcWainDelegate, vcBindDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
{
    //NSString                              // 这里要增加  植物大类模型
    NSString *      roomOrOut;              // 室内室外
    NSString *      earthOrFlowerpot;       // 大地花盆
    NSInteger       alter_day;              // 拍照提醒的天数
    
    NSString *      nameFromCell;           // 用户输入的名字
    
    BOOL            isFirstIn;              // 第一次进入
    
    UITextField *   txfFromCell;            // 传进来的输入框
    NSString *      imgUrlFromServer;       // 上传后，服务器返回的图片名称
    
    NSInteger       selectedPickIndex;      // pick选中的索引
    BOOL            isSaveToServerOK;       // 是否保存服务器成功
    BOOL            isLock;                 // 锁定右键
    NSString *      oldUUUIDString;         // 待处理的外设UUID 旧的
    NSString *      newUUUIDString;         // 待处理的外设UUID 新的
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;

@property (weak, nonatomic) IBOutlet UIView               *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView          *imv;
@property (strong, nonatomic) UITableView                   *tabview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint   *imgTop;

@property (strong, nonatomic) NSMutableArray                *arrDataTitle;
@property (strong, nonatomic) NSMutableArray                *arrDataValue;

@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (strong, nonatomic) NSMutableArray                *arrWarnDay;

- (IBAction)btnBigClick:(id)sender;
- (IBAction)btnImgClick:(UIButton *)sender;

@end

@implementation vcNew

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.flower)
    {
        [self setNavTitle:self title:@"新增植物"];
    }else
    {
        [self setNavTitle:self title:self.flower.my_plant_name];
    }
    
    isFirstIn = YES;
    self.isPop = YES;
    
    [self initRightButton:nil imgName:@"baocun"];
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isFirstIn = NO;
    self.arrDataValue = [NSMutableArray arrayWithObjects:
                         self.ftModel? self.ftModel.name : @"",         // 大类选择页面回来的数据
                         roomOrOut,
                         earthOrFlowerpot,
                         @(alter_day + 1),
                         self.per ? self.per.perName : @"",
                         nil];
    [self.tabview reloadData];
    
    // 这里 检查一下
    if (!self.flower && [[FlowerData numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access = %@", self.userInfo.access] inContext:DBefaultContext] integerValue] > 3)
    {
        NSLog(@"尼玛，这里越界了。");
    }
    
    __block vcNew *blockSelf = self;
    self.upLoad_Next = ^(NSString *url)
    {
        if(!url.length)
        {
            NSLog(@"图片上传失败");
            LMBShowInBlock(NONetTip);
        }else
        {
            imgUrlFromServer = url;
            [blockSelf saveDataToServerAfterImage];
        }
    };
}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
}


-(void)dealloc
{
    self.upLoad_Next = nil;
}

-(void)rightButtonClick
{
//    [self alertBecauseFirstBind];return;
    [self save];
}


-(void)initData
{
    self.arrWarnDay = [NSMutableArray new];
    for (int i = 1; i < 32; i++)
    {
        [self.arrWarnDay addObject:@(i)];
    }
    
    roomAndOut = @[ kString(@"室内"), kString(@"室外") ];
    earthAndFlowerpot = @[ kString(@"花盆"), kString(@"大地") ];
    nameFromCell = @"";
    
    if (self.flower)
    {
        if(self.flower.imageData)
        {
            UIImage *img = [UIImage imageWithData:self.flower.imageData];
            self.imv.image = img;
        }
        else if(self.flower.my_plant_pic_url && self.flower.my_plant_pic_url.length)
        {
            [self.imv sd_setImageWithURL:[NSURL URLWithString:self.flower.my_plant_pic_url] placeholderImage: DEFAULTTHTDEFAULT];
            
            self.imv.image = DEFAULTTHTDEFAULT;
            [self.imv sd_setImageWithURL:[NSURL URLWithString:self.flower.my_plant_pic_url]
                        placeholderImage:DEFAULTTHTDEFAULT
                                 options:SDWebImageProgressiveDownload
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   float imageW = image.size.width;
                                   float imageH = image.size.height;
                                   
                                   float tag = imageW > imageH ? imageH : imageW;
                                   float posX = (imageW - tag) / 2;
                                   float posY = (imageH - tag) / 2;
                                   CGRect trimArea = CGRectMake(posX, posY, tag, tag);
                                   CGImageRef srcImageRef = [image CGImage];
                                   CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                                   image = [UIImage imageWithCGImage:trimmedImageRef];
                                   self.imv.image = [self getImageBySize:image width:ScreenWidth * (950 / 1242.0) height:ScreenWidth * (950 / 1242.0) * 0.75 ];
                               }];
        }
        
        nameFromCell = self.flower.my_plant_name;
        roomOrOut = [self.flower.my_plant_room      boolValue] ? roomAndOut[0] : roomAndOut[1];
        earthOrFlowerpot = [self.flower.my_plant_pot  boolValue] ? earthAndFlowerpot[0] : earthAndFlowerpot[1];
        alter_day = [self.flower.camera_alert integerValue];
        
        self.warnStrig = self.flower.alarm_set;
//        NSLog(@"--- >  self.warnStrig : %@",  self.warnStrig);
        
        if (self.flower.bind_device_mac.length == 36) {
            self.per = [Per new];
            self.per.perName = self.flower.bind_device_name;
            self.per.perUUIDString = self.flower.bind_device_mac;
            self.per.isBind = YES;
        }
        self.ftModel = [[FlowerType findByAttribute:@"iD" withValue:self.flower.plant_id ] firstObject];
        
    }else
    {
        roomOrOut = roomAndOut[0];
        earthOrFlowerpot = earthAndFlowerpot[0];
        alter_day = 6;                                  //  默认索引为6
        self.warnStrig = @"1-1-1-1";
    }
    
    self.arrDataTitle = [NSMutableArray arrayWithObjects:kString(@"名称:"), kString(@"花草分类:"), kString(@"室内/室外:"), kString(@"花盆/大地:"), kString(@"拍照提醒间隔(天):"), kString(@"植物绑定设备:"), kString(@"提醒设置:") ,nil];
}

-(void)initView
{
//    self.contentHeight.constant = ScreenHeight - (IPhone4 ? 0 : (NavBarHeight - 1));
//    self.contentHeight.constant = (IPhone4 ? RealHeight(960) : RealHeight(800))  + 40 * 8;
    if (IPhone4) {
        self.contentHeight.constant = RealHeight(960) + 40 * 8;
    }else
    {
        self.contentHeight.constant = ScreenHeight - NavBarHeight - (IPhone5?0:BottomHeight) + 1;
    }
    
    self.imgTop.constant = RealHeight(40.0);
    
    self.tabview = [[UITableView alloc] initWithFrame:CGRectMake(RealWidth(40.0), IPhone4 ? RealHeight(960) : RealHeight(800) , ScreenWidth - RealWidth(80.0), 40 * 7)];
    
    self.tabview.delegate = self;
    self.tabview.dataSource = self;
    self.tabview.rowHeight = 40;
    self.tabview.scrollEnabled = NO;
    self.tabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabview registerNib:[UINib nibWithNibName:@"tvcNewPlant" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [self.viewMain addSubview:self.tabview];
    
    self.imv.layer.borderWidth = 5;
    self.imv.layer.borderColor = DBorder.CGColor;
    self.imv.layer.cornerRadius = 5;
    self.imv.layer.masksToBounds = YES;
    
    
    [self initBigView];
    [self initPikerView];
}

-(void)initBigView
{
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 300, self.bgView.bounds.size.width, 44)];
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
}

-(void)initPikerView
{
    //self.pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256 - NavBarHeight)];
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)ISIOS < 9) ? 286 : 256) - NavBarHeight)];
    self.pickView.backgroundColor = RGB(239, 239, 239);
    self.pickView.dataSource = self;
    self.pickView.delegate = self;
    [self.pickView setHidden:NO];
}


#pragma mark PickerView取消按钮事件
- (void)pickerViewCancelButtonClick
{
    [self pickerViewDisappear];
}

#pragma mark PickerView确定按钮事件
- (void)pickerViewConfirmButton
{
    [self pickerViewDisappear];
    alter_day = selectedPickIndex ;                      // 这里  0 天 就是 1 天  坑爹的江华
    self.arrDataValue[3] = @(alter_day + 1);
    self.isChange = YES;
    [self.tabview reloadData];
}

//pickView弹出动画
-(void)pickerViewPopAnimationsRelod:(BOOL)isPicker
{
    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.bgView setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {
        
    }];
    if (isPicker) {
        [self.pickView reloadAllComponents];
    }
}

- (void)pickerViewDisappear
{
    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.bgView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {
        [self.pickView removeFromSuperview];
    }];
    
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return  31;
}

#pragma mark UIPickerViewDataSource;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return  [self.arrWarnDay[row] description];
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedPickIndex = row;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcNewPlant *cell = [tvcNewPlant cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblTitle.text = self.arrDataTitle[indexPath.row];
    
    cell.tagIndex = indexPath.row;
    cell.delegate = self;
    switch (indexPath.row) {
        case 0:
        {
            cell.txfvalue.placeholder = kString(@"请输入昵称");
            [cell.stcSwitch setHidden: YES];
            [cell.imvRight setHidden:YES];
            if (self.flower && isFirstIn) {
                cell.txfvalue.text = self.flower.my_plant_name;
            }else
            {
                cell.txfvalue.text = nameFromCell;
            }
        }
            break;
        case 1:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.stcSwitch setHidden: YES];
            cell.txfvalue.text = self.arrDataValue[0];
            //cell.txfvalue.text = kString(<#_S#>)
            
        }
            break;
        case 2:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.imvRight setHidden:YES];
            
            [cell.stcSwitch setTitle:roomAndOut[0] forSegmentAtIndex:0];
            [cell.stcSwitch setTitle:roomAndOut[1]  forSegmentAtIndex:1];
            
            if (isFirstIn && self.flower) {
                cell.txfvalue.text = @""; //kString(@"室内");                 // TODO
            }
            else
            {
                cell.txfvalue.text = roomOrOut;
                if ([roomOrOut isEqualToString:roomAndOut[1]]) {
                    cell.stcSwitch.selectedSegmentIndex = 1;
                }
            }
            
        }
            break;
        case 3:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.imvRight setHidden:YES];
            
            [cell.stcSwitch setTitle:earthAndFlowerpot[0] forSegmentAtIndex:0];
            [cell.stcSwitch setTitle:earthAndFlowerpot[1]  forSegmentAtIndex:1];
            
            if (isFirstIn && self.flower) {
                cell.txfvalue.text = @""; //                // TODO
            }
            else
            {
                cell.txfvalue.text = earthOrFlowerpot;
                if ([earthOrFlowerpot isEqualToString:earthAndFlowerpot[1]]) {
                    cell.stcSwitch.selectedSegmentIndex = 1;
                }
            }
        }
            break;
        case 4:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.stcSwitch setHidden: YES];
            [cell.imvRight setHidden:YES];
            cell.lblTilteWidth.constant = 135;
            cell.lblValue.text = [self.arrDataValue[3] description];
            
        }
            break;
        case 5:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.stcSwitch setHidden: YES];
            cell.txfvalue.text = self.per ?  self.per.perName : @"";
        }
            break;
        case 6:
        {
            [cell.txfvalue setEnabled:NO];
            [cell.stcSwitch setHidden: YES];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [txfFromCell resignFirstResponder];
    [self viewMove:NO];
    switch (indexPath.row)
    {
        case 1:
            NSLog(@"点击");
            [self performSegueWithIdentifier:@"new_to_flowerList" sender:nil];
            break;
        case 4:
        {
            [self.bgView addSubview:self.pickView];
            [self pickerViewPopAnimationsRelod:NO];
        }
            break;
        case 5:
            [self performSegueWithIdentifier:@"new_to_bind" sender:nil];
            break;
        case 6:
            [self performSegueWithIdentifier:@"new_to_warn" sender:nil];
            break;
            
        default:
            break;
    }
}




#pragma mark tvcNewPlantDelegate
-(void)stcChange:(NSInteger)index tadex:(NSInteger)tadex
{
    self.isChange = YES;
    NSLog(@"tag: %ld  index : %ld", (long)tadex, (long)index);
    switch (tadex) {
        case 2:
        {
            roomOrOut = roomAndOut[index];
        }
        break;
        case 3:
        {
            earthOrFlowerpot = earthAndFlowerpot[index];
        }
        break;
        
        default:
        break;
    }
    [self.tabview reloadData];
}

-(void)txfChange:(UITextField *)txf
{
    self.isChange = YES;
    txfFromCell = txf;
    nameFromCell = txf.text;
    if (IPhone4) [self viewMove:YES];
}

-(void)btnReturnClick
{
    [txfFromCell resignFirstResponder];
    [self viewMove:NO];
}

-(void)viewMove:(BOOL)top       //  4s  存在遮挡输入框  上移
{
    if (top)
    {
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewMain setFrame:CGRectMake(0 , - NavBarHeight - 20, ScreenWidth, ScreenHeight)];
         } completion:^(BOOL finished) {
             
         }];
    }else
    {
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewMain setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
         } completion:^(BOOL finished) {
             
         }];
    }
}

- (IBAction)btnBigClick:(id)sender {
    [txfFromCell resignFirstResponder];
    [self viewMove:NO];
}

- (IBAction)btnImgClick:(UIButton *)sender
{
    [txfFromCell resignFirstResponder];
    TAlertView *alter = [[TAlertView alloc] initWithTitle:@"修改头像" message:@"11"];
    
    [alter showActionCamera:^{
        [self pickImageFromCamera];
    } photoA:^{
        [self pickImageFromAlbum];
    }];
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
    
    self.imv.image = image;
    self.imv.image = [self getImageBySize:image width:ScreenWidth * (950 / 1242.0) height:ScreenWidth * (950 / 1242.0) * 0.75 ];
    
    self.isChange = YES;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(UIImage *)getImageBySize:(UIImage *)image width:(CGFloat)width height:(CGFloat)height
{
    float imageW = image.size.width;  // 这里是正方形
    float nexHight = imageW * height / width;
    float posY = (imageW - nexHight) / 2;
    CGRect trimArea = CGRectMake(0, posY, imageW, nexHight);
    CGImageRef srcImageRef = [image CGImage];
    CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
    image = [UIImage imageWithCGImage:trimmedImageRef];
    return image;
}

#pragma mark - imagepicker delegate  使用相册
-(void)pickImageFromAlbum
{
    __block vcNew *blockSelf = self;
    [self getAccessNext:1 block:^
     {
         UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
         imagePicker.delegate = blockSelf;
         imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
         imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         imagePicker.allowsEditing = YES;
         [blockSelf.navigationController presentViewController:imagePicker animated:YES completion:NULL];
     }];
    
//    
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    imagePicker.allowsEditing = YES;
//    [self.navigationController presentViewController:imagePicker animated:YES completion:^{}];
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

-(void)save
{
    if (isLock) return;
    if (txfFromCell.resignFirstResponder) {
        [txfFromCell resignFirstResponder];
        return;
    }
    
    NSLog(@"%@", nameFromCell);
    if (!nameFromCell.length) {
        LMBShow(@"花草名不能为空");
        return;
    }
    
    if ([nameFromCell rangeOfString:@"\\"].length || [NSString isHaveEmoji:nameFromCell]) {
        LMBShow(@"花草名不能包含特殊字符");
        return;
    }
    
    if (!self.ftModel)
    {
        LMBShow(@"花草分类必须选择");
        return;
    }
    
    isLock = YES;
    if (!self.flower)
    {
        self.flower = [FlowerData MR_createEntityInContext:DBefaultContext];
        self.flower.my_plant_id_T = @((arc4random() % 1000000) + 9000000);                 // 临时ID  一百万 - 一千万
    }
    
    if(self.isChange)
    {
        if(self.per.perUUIDString)
        {
            NSLog(@"新昵称:%@, 老昵称:%@, 是否一样：%@", nameFromCell, self.flower.my_plant_name, @([self.flower.my_plant_name isEqualToString:nameFromCell]));
            
            
            
            NSArray *arr = [FlowerData findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and bind_device_mac == %@", self.userInfo.access, self.per.perUUIDString] inContext:DBefaultContext];
            for (int i = 0; i < arr.count; i++) {
                FlowerData *ffff = arr[i];
                NSLog(@"%@, %@", ffff.access, ffff.bind_device_mac);
            }
            
            //[[FlowerData numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and bind_device_mac == %@", self.userInfo.access, self.per.perUUIDString] inContext:DBefaultContext] intValue];
            if (arr.count > 1) {
                LMBShow(@"该植物已经被绑定了");
                isLock = NO;
                return;
            }
        }
        [NetTool changeType:0 isFinish:NO];
        self.flower.access = self.userInfo.access;
        self.flower.my_plant_name = nameFromCell;
        self.flower.alarm_set = self.warnStrig;    // 这里崩溃一次
        self.flower.plant_id = self.ftModel.iD;
        
        self.flower.my_plant_room = @([roomOrOut isEqualToString:roomAndOut[0]]);
        self.flower.my_plant_pot = @([earthOrFlowerpot isEqualToString:earthAndFlowerpot[0]]);
        self.flower.camera_alert = @(alter_day);

        oldUUUIDString = self.flower.bind_device_mac;
        if (self.per)
        {
            self.flower.bind_device_name = self.per.perName;
            self.flower.bind_device_mac = self.per.perUUIDString;
            [self alertBecauseFirstBind];
        }
        else    // 这里可能是 解绑了
        {
            self.flower.bind_device_name = @"";
            self.flower.bind_device_mac = @"";
        }
        newUUUIDString = self.flower.bind_device_mac;
        
        self.flower.last_photo_time = [NSDate date];
        self.flower.isUpdate = @NO;
        self.flower.imageData = self.imgdata;
        self.flower.imageType = self.imgType;
        self.flower.update_time = @([[NSDate date] timeIntervalSince1970] * 1000);
        
        DBSave;
        [self nextConnect];
        [NetTool changeType:0 isFinish:NO];
        SystemSettings *sst = [[SystemSettings findByAttribute:@"access" withValue:self.userInfo.access andOrderBy:@"update_time" ascending:NO] firstObject];
        if ([sst.getAddress boolValue]) [Myanotation resetLatitudeAndLongitude];
        isLock = NO;
//        NSLog(@"-------- 8 %@", [NSDate date]);
        
        
        if ([GetUserDefault(DNet) intValue])
        {
            MBShowAll;
            __block vcNew *blockSelf = self;
            HDDAF;
            if(self.imgdata)
                [self getTokenAndUpload];
            else
                [self saveDataToServerAfterImage];
        }
        else
        {
            isLock = NO;
            [self nextConnect];
            NSLog(@"暂时存在本地");
            if ([self.flower.my_plant_id integerValue])
                LMBShow(@"修改成功");
            else
                LMBShow(@"添加成功");
            [self backAfterOneSecond];
        }
    }
    else
    {
        NSLog(@"没有修改");
        [self back];
    }
}

-(void)nextConnect
{
    if (oldUUUIDString && [self.Bluetooth.dicConnected.allKeys containsObject:oldUUUIDString])
    {
        if (![self.per.perUUIDString isEqualToString:oldUUUIDString])
            [self.Bluetooth stopLink:self.Bluetooth.dicConnected[oldUUUIDString]];
        if ([self.Bluetooth.dicSysIng.allKeys containsObject:oldUUUIDString])
            [self.Bluetooth.dicSysIng removeObjectForKey:oldUUUIDString];
        if ([self.Bluetooth.dicSysEnd.allKeys containsObject:oldUUUIDString])
            [self.Bluetooth.dicSysEnd removeObjectForKey:oldUUUIDString];
    }
    oldUUUIDString = nil;
    
    if (newUUUIDString && ![self.Bluetooth.dicConnected.allKeys containsObject:newUUUIDString] && [self.per.perUUIDString isEqualToString:newUUUIDString]) {
        [self.Bluetooth retrievePeripheral:newUUUIDString];
        [self.Bluetooth.dicSysIng setObject:self.per forKey:newUUUIDString];
    }
    newUUUIDString = nil;
}

-(void)saveDataToServerAfterImage
{
//    NSLog(@"-------- 6 %@", [NSDate date]);
    self.flower.my_plant_pic_url = imgUrlFromServer ? imgUrlFromServer : self.flower.my_plant_pic_url;
    NSMutableArray *arrLatitudeAndLongtude = GetUserDefault(Latitude_Longitude);
    if (arrLatitudeAndLongtude) {
        self.flower.my_plant_longitude = arrLatitudeAndLongtude[0];
        self.flower.my_plant_latitude = arrLatitudeAndLongtude[1];
    }
    else
    {
        self.flower.my_plant_longitude = @(0);
        self.flower.my_plant_latitude = @(0);
    }
    DBSave;
    
    NSMutableDictionary *dicR = [NSMutableDictionary new];
    [dicR setObject:self.userInfo.access forKey:@"access"];
    if ([self.flower.my_plant_id integerValue])
        [dicR setObject:self.flower.my_plant_id  forKey:@"my_plant_id"];
    [dicR setObject:self.flower.my_plant_name forKey:@"my_plant_name"];
    [dicR setObject:self.flower.plant_id forKey:@"plant_id"];
    [dicR setObject:[self.flower.my_plant_room boolValue] ? @"01" : @"02" forKey:@"my_plant_room"];
    [dicR setObject:[self.flower.my_plant_pot boolValue] ?   @"01" : @"02" forKey:@"my_plant_pot"];
    [dicR setObject:self.flower.camera_alert forKey:@"camera_alert"];
    [dicR setObject:self.flower.bind_device_name forKey:@"bind_device_name"];
    [dicR setObject:self.flower.bind_device_mac forKey:@"bind_device_mac"];
    [dicR setObject:self.flower.alarm_set forKey:@"alarm_set"];
    [dicR setObject:self.flower.my_plant_pic_url ? self.flower.my_plant_pic_url : @"" forKey:@"my_plant_pic_url"];
    
    //  这里需要获取经纬度
    [dicR setObject:self.flower.my_plant_longitude forKey:@"my_plant_longitude"];
    [dicR setObject:self.flower.my_plant_latitude forKey:@"my_plant_latitude"];

//     NSLog(@"-------- 7 %@", [NSDate date]);
    __block vcNew *blockSelf = self;
    RequestCheckNoWaring(
         [net updateMyPlantInfo:dicR];,
         [blockSelf dataSuccessBack_updateMyPlantInfo:dic];)
}

-(void)dataSuccessBack_updateMyPlantInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        isLock = NO;
        isSaveToServerOK = YES;
        if ([self.flower.my_plant_id integerValue])
        {
            //LMBShow(@"修改成功");
            // 上传成功后， 一定要把它关联的相册表， 还有同步数据表中的  临时ID 改为新的ID  还有提醒表
            NSArray *arrAlbum = [Album findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and flowerID = %@", self.userInfo.access, self.flower.my_plant_id_T] inContext:DBefaultContext];
            for (Album *ab in arrAlbum) {
                ab.flowerID = self.flower.my_plant_id;
            }
            
            NSArray *arrSysData = [SyncDate findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and my_plant_id = %@", self.userInfo.access, self.flower.my_plant_id_T] inContext:DBefaultContext];
            for (SyncDate *sd in arrSysData) {
                sd.my_plant_id = self.flower.my_plant_id;
            }
            
            NSArray *arrRemind = [Remind findAllWithPredicate:[NSPredicate predicateWithFormat:@"access = %@ and flower_Id = %@", self.userInfo.access, self.flower.my_plant_id_T] inContext:DBefaultContext];
            for (Remind *rd in arrRemind) {
                rd.flower_Id = self.flower.my_plant_id;
            }
        }
        else
        {
            //LMBShow(@"添加成功");
            //如果是添加，  就应该重新同步数据
            //SetUserDefault(isFirstSys, @1);                           //  同步完成
        }
        
        self.flower.isUpdate = @YES;
        self.flower.update_time = @([dic[@"update_time"] longLongValue]);
        self.flower.my_plant_id = @([dic[@"my_plant_id"] integerValue]);
        self.flower.my_plant_id_T = @0;                                                  // 上传后， 临时ID 设置为0
        self.imgdata = self.flower.imageData = nil;                                      // 上传完成后，  清空
        self.imgType = self.flower.imageType = nil;
        
        
        DBSave;
        MBHide;
        LMBShow(@"保存成功");
        [self nextConnect];
        [self backAfterOneSecond];
    }
//    else
//    {
//        LMBShow(NONetTip);
//    }
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"new_to_bind"])
    {
        vcBind *vc = (vcBind *)segue.destinationViewController;
        vc.delegate = self;
        if (self.flower)
        {
            if (self.flower.bind_device_mac.length == 36)
            {
                Per *per = [Per new];
                per.perName = self.flower.bind_device_name;
                per.perUUIDString = self.flower.bind_device_mac;
                per.isBind = YES;
                vc.per = per;
            }
        }
    }
    else if([segue.identifier isEqual:@"new_to_warn"])
    {
        vcWain *vc = (vcWain *)segue.destinationViewController;
        vc.delegate = self;
        vc.wariString = self.warnStrig;
    }
    else if([segue.identifier isEqual:@"main_to_history"])
    {
        vcHistory *vc = (vcHistory *)segue.destinationViewController;
        vc.flower = self.flower;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pickerViewDisappear];
}


#pragma mark vcWainDelegate
-(void)chaneIsWain:(NSString *)warnString
{
    self.isChange = YES;
    self.warnStrig = warnString;
}

#pragma  mark vcBindDelegate
-(void)bind:(Per *)per
{
    self.isChange = YES;
    NSLog(@"per : %@", per);
    if (per)
        self.per = per;
    else
        self.per = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


@end
