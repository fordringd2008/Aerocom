//
//  vcIndex.m
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcIndex.h"
#import "FlowerData.h"
#import "UIButton+WebCache.h"
#import "vcMain.h"
//#import "FXLabel.h"
#import "VerticalAlignmentLabel.h"

#define imgRatio   (590.0 / 945.0)

#define buttonTag    9527
#define lableTag     9528
#define imageTag     9529

static NSString *const ID = @"image";

@interface vcIndex ()
{
    NSTimer *timer;                             //  循环检查
    BOOL isFirst;
    NSTimer *timerRefre;
    NSString *deleUuid;                         //  正在删除的植物uuidString
    
    CGFloat buttonWidth;
    CGFloat buttonHeight;
    
    BOOL isDeleteType;                          // 是否处于删除模式
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewMain;                    // 这个遗弃
@property (weak, nonatomic) IBOutlet UIScrollView *viewSrv;

@property (strong, nonatomic) NSMutableArray *arrButton;                        // button的集合
@property (strong, nonatomic) NSMutableArray *arrLabel;
@property (strong, nonatomic) NSMutableArray *arrImage;
@property (strong, nonatomic) NSMutableArray *arrData;                          // 用户关联的植物集合


@end

@implementation vcIndex

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"我的花园"];
    self.isPop = NO;
    [self initLeftButton:@"iosmulu"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
    
    [self initView];
    [self initCollectionView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self initData];
    [self refreshRightButton];
    
    [self refreshView];
    timerRefre = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshImv:) userInfo:nil repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [timerRefre stop];
    for(int i = 0; i < self.arrButton.count; i++)
    {
        UIButton *btn = self.arrButton[i];
        btn.tag = buttonTag;
        [btn sd_setImageWithURL: nil forState:UIControlStateNormal placeholderImage:DEFAULTTHTDEFAULT];
        VerticalAlignmentLabel *lbl = self.arrLabel[i];
        lbl.text = @" ";
    }
    [super viewDidDisappear:animated];
    
    
}



-(void)refreshRightButton
{
    if (self.arrData.count <  4)
    {
        [self initRightButton:nil imgName:@"iostianjia"];
    }
    else
    {
        [self initRightButton:nil imgName:nil];
    }
}

-(void)rightButtonClick
{
    if (self.arrData.count <  4)
    {
        if (self.arrData.count < 4) {
            [self performSegueWithIdentifier:@"index_to_new" sender:nil];
        }
    }
}

-(void)refreshView
{
//    if(!self.arrData.count) return;
    
    for(NSUInteger i = self.arrData.count ? self.arrData.count - 1 : 0; i < self.arrButton.count; i++)
//    for(NSUInteger i = 0; i < 4; i++)
    {
        UIButton *btn = self.arrButton[i];
        btn.tag = buttonTag;
        [btn setImage:DEFAULTIMG forState:UIControlStateNormal];
        VerticalAlignmentLabel *lbl = self.arrLabel[i];
        lbl.text = @" ";
    }
    
    //NSLog(@"---------------------------------------------------- self.arrData.count= %d", self.arrData.count);
    
    if (self.arrData.count > 0)
    {
        for (int i = 0; i < self.arrData.count; i++)
        {
            FlowerData *fd = self.arrData[i];
            UIButton *btn = self.arrButton[i];
            if ([fd.my_plant_id integerValue])
            {
                btn.tag = [fd.my_plant_id integerValue];
                // 这里如果imageData有值 首先赋值  因为可能是没有上传的
                if(fd.imageData)
                {
                    [btn setImage:[self getImageBySize:[UIImage imageWithData:fd.imageData]] forState:UIControlStateNormal];
                }
                else
                {
                    [btn setImage:DEFAULTTHTDEFAULT forState:UIControlStateNormal];
                    if (fd.my_plant_pic_url && fd.my_plant_pic_url.length)
                    {
                        [btn sd_setImageWithURL:[NSURL URLWithString:fd.my_plant_pic_url]
                                       forState:UIControlStateNormal
                               placeholderImage:DEFAULTTHTDEFAULT
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                         {
                             
                             CGFloat width = ( ScreenWidth - RealHeight(60.0) ) / 2.0;
                             CGFloat height = width / imgRatio;
                             
                             float imageW = image.size.width;  // 这里是正方形
                             float newWidth = imageW * buttonWidth / buttonHeight;
                             
                             if (newWidth < width) {
                                 imageW = height;
                                 newWidth = width;
                             }
                             
                             float posX = (imageW - imageW * buttonWidth / buttonHeight) / 2;
                             CGRect trimArea = CGRectMake(posX, 0, newWidth, imageW);
                             
                             CGImageRef srcImageRef = [image CGImage];
                             CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                             image = [UIImage imageWithCGImage:trimmedImageRef];
                             [btn setImage:image forState:UIControlStateNormal];
                         }];
                    }
                }
            }
            else                                                          // 这里证明是 没有上传的
            {
                btn.tag = [fd.my_plant_id_T integerValue];
                if (fd.imageData) {
                    [btn setImage:[self getImageBySize:[UIImage imageWithData:fd.imageData]] forState:UIControlStateNormal];
                }
                else
                {
                    btn.imageView.image = DEFAULTTHTDEFAULT;
                    [btn setImage:DEFAULTTHTDEFAULT forState:UIControlStateNormal];
                }
            }
            VerticalAlignmentLabel *lbl = self.arrLabel[i];
            lbl.text = fd.my_plant_name;
        }
    }
    [self refreshImv:nil];
    
    // 这里 执行  多操作， 可能需要断开某一些
    [self resetTimerAutoLink];
}

-(void)refreshImv:(NSTimer *)timerF
{
    for (int i = 0; i < 4; i++)
    {
        UIImageView *imv = self.arrImage[i];
        imv.image = nil;
    }
    for (int j = 0; j < self.arrData.count; j++)
    {
        FlowerData *fd = self.arrData[j];
        UIImageView *imv = self.arrImage[j];
        if (!fd.bind_device_mac || fd.bind_device_mac.length < 36)
            imv.image = nil;
        else if([self.Bluetooth.dicConnected.allKeys containsObject:fd.bind_device_mac] && [GetUserDefault(BLEisON) boolValue])
            imv.image = IMG(@"ioslanya");
        else
            imv.image = IMG(@"ioslanya2");
    }
}


-(void)initView
{
    if (IPhone4) {
        self.viewMainHeight.constant = ScreenHeight + 1;
    }else
    {
        self.viewMainHeight.constant = ScreenHeight - NavBarHeight - BottomHeight + 1;
    }
    
//    Border(self.viewMain, DRed);
}

-(void)initCollectionView
{
    self.arrButton = [NSMutableArray new];
    self.arrLabel = [NSMutableArray new];
    self.arrImage =  [NSMutableArray new];
    
    for (UIView *vie in self.viewMain.subviews)
    {
        [vie removeFromSuperview];
    }
    
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;

    width = ( ScreenWidth - RealHeight(60.0) ) / 2.0;
    height = width / imgRatio;
    
    buttonWidth = width;
    buttonHeight = height;
    
    for (int i = 0; i < 4 ; i++)
    {
        x = i % 2 == 0 ? RealHeight(20.0) : RealHeight(40.0) + width;
        y = i <= 1 ? RealHeight(20.0) : RealHeight(40.0) + height;
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
//        button.tintColor= [UIColor clearColor];
//        [button setTitleColor:DClear forState:UIControlStateHighlighted];
        
        
        
        VerticalAlignmentLabel *lbl = [[VerticalAlignmentLabel alloc] initWithFrame:CGRectMake(x, y + height - 30, width, 30)];
        lbl.verticalAlignment = VerticalAlignmentMiddle;

        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(x - 5 + width * (920.0 / 1020.0), y + (920.0 / 1020.0) * height + 2, width * (70.0 / 1020.0) , width * (100.0 / 1020.0) )];
        [button sd_setImageWithURL: nil forState:UIControlStateNormal placeholderImage:DEFAULTIMG];
        button.tag = buttonTag;
        button.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress:)];
        [button addGestureRecognizer:lp];
        
        button.backgroundColor = [UIColor lightGrayColor];
        [button setBackgroundImage:[UIImage imageFromColor:RGBA(0, 0, 0, 0.1)] forState:UIControlStateHighlighted];
        
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.arrButton addObject:button];
        [self.viewSrv addSubview:button];

        button.layer.borderWidth = 5;
        button.layer.borderColor = DBorder.CGColor;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 21, 5);
        
        lbl.layer.borderWidth = 2;
        lbl.layer.borderColor = DBorder.CGColor;
        lbl.layer.cornerRadius = 5;
        lbl.layer.masksToBounds = YES;
        lbl.tag = lableTag;
        lbl.textColor = [UIColor whiteColor];
//        lbl.backgroundColor = [UIColor clearColor];
        lbl.backgroundColor = DBorder;
        lbl.textAlignment = NSTextAlignmentCenter;
        [lbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [self.arrLabel addObject:lbl];
        [self.viewSrv addSubview:lbl];
        
        imv.tag = imageTag;
        imv.image = [UIImage imageNamed:@"ioslanya2"];
        [self.arrImage addObject:imv];
//        [self.viewMain addSubview:imv];
        [self.viewSrv insertSubview:imv aboveSubview:lbl];
    }
//    self.viewMain.backgroundColor = [UIColor redColor];
}

-(void)longpress:(UILongPressGestureRecognizer* )lp
{
    if (isDeleteType)return;
    if(!isDeleteType)
    {
        isDeleteType = YES;
        NSInteger tag = lp.view.tag;  // BUTTON 的 tag
        if (tag == buttonTag) {
            isDeleteType = NO;
            return;
        }
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定要删除该植物？"];
        [alert showWithActionSure:^
         {
             isDeleteType = NO;
             [self deletePlant: tag];
         } cancel:^{
             isDeleteType = NO;
         }];
    }
}

-(void)deletePlant:(NSInteger)tag
{
    FlowerData * fd;
    for (int i = 0; i < self.arrData.count; i++){
        fd = self.arrData[i];
        if ([fd.my_plant_id integerValue] == tag || [fd.my_plant_id_T integerValue] == tag) {
            break;
        }
    }
    [self.arrData removeObject:fd];
    
    NSString *plantID = [[fd.my_plant_id description] mutableCopy];         // 保留副本
    if(fd.bind_device_mac && fd.bind_device_mac.length == 36 && [self.Bluetooth.dicConnected.allKeys containsObject:fd.bind_device_mac])
    {
        self.Bluetooth.isNotSearch = YES;
        [self.Bluetooth stopLink:self.Bluetooth.dicConnected[fd.bind_device_mac]];
        __block vcIndex *blockSelf = self;
        NextWait(
                 blockSelf.Bluetooth.isNotSearch = NO;
                 , 3);
        [self refreshImv:nil];
        [self.Bluetooth.dicSysEnd removeObjectForKey:fd.bind_device_mac];
        [self.Bluetooth.dicSysIng removeObjectForKey:fd.bind_device_mac];
    }
    [fd MR_deleteEntityInContext:DBefaultContext];
    [self refreshRightButton];
    
    
    [NetTool changeType:1 isFinish:NO];
    DBSave;
    // 这里要删除所有这个植物相关的数据， 同步数据， 相册数据， 提醒数据
    [SyncDate MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and my_plant_id == %@", self.userInfo.access, plantID] inContext:DBefaultContext];
    [Album MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and flowerID == %@", self.userInfo.access, plantID] inContext:DBefaultContext];
    [Remind MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and flower_Id ==%@", self.userInfo.access, plantID] inContext:DBefaultContext];
    
    if (plantID && ![plantID isEqualToString:@"0"])             // 如果my_plant_id不为 0 或者 nil 说明， 是服务器已经有的
    {
        
        __block vcIndex *blockSelf = self;
        RequestCheckNoWaring(
             [net deleteOneMyPlantInfo:blockSelf.userInfo.access plantID:plantID];,
             [blockSelf dataSuccessBack_deletePlant:dic];)
    }
    
    [self refreshView];
}

-(void)initData
{
    //self.arrData = [[FlowerData findAllSortedBy:@"my_plant_id" ascending:NO withPredicate: inContext:DBefaultContext] mutableCopy];
    
    self.arrData = [[FlowerData findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext] mutableCopy];
    [self refreshView];
    
    static BOOL isRequest = YES;
    if (!isRequest) return;
    NextWait(isRequest = YES;, 10);
    isRequest = NO;
    
    __block vcIndex *blockSelf = self;
    NextWait(
             RequestCheckNoWaring(
              [net getMyPlantInfo:blockSelf.userInfo.access];,
              [blockSelf dataSuccessBack_getPlant:dic];)
             , 0.3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

-(void)buttonClick:(UIButton *)btn
{
    if (self.isJumpLock) {
        return;
    }
    self.isJumpLock = YES;
    
    //NSLog(@"-----tag: %ld",(long)btn.tag);
    if (btn.tag == buttonTag)
    {
        [self performSegueWithIdentifier:@"index_to_new" sender:nil];
    }else
    {
        FlowerData *fd;
        for (int i = 0; i < self.arrData.count; i++) {
            fd = self.arrData[i];
            if ([fd.my_plant_id integerValue] == btn.tag)
            {
                break;
            }
        }
        [self performSegueWithIdentifier:@"index_to_main" sender:fd];
    }
    __block vcIndex *blockSelf = self;
    NextWait(blockSelf.isJumpLock = NO;, 0.5);
}



-(void)dataSuccessBack_getPlant:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        [self.arrData removeAllObjects];
        NSArray *arrPlantData = dic[@"my_plant_arr"];
        for (int i = 0; i < arrPlantData.count; i++)
        {
            NSDictionary * dicFdFromServer = arrPlantData[i];
            
            //NSArray *arr  = [FlowerData findAll];
            FlowerData * fdFromLocal = [[FlowerData findByAttribute:@"my_plant_id" withValue:dicFdFromServer[@"my_plant_id"]] firstObject];
            if (!fdFromLocal)
            {
                fdFromLocal = [FlowerData MR_createEntityInContext:DBefaultContext];
                fdFromLocal.access = self.userInfo.access;
            }
            fdFromLocal.alarm_set = [dicFdFromServer[@"alarm_set"] description];
            fdFromLocal.bind_device_mac = dicFdFromServer[@"bind_device_mac"];
            fdFromLocal.bind_device_name = dicFdFromServer[@"bind_device_name"];
            fdFromLocal.camera_alert = @([dicFdFromServer[@"camera_alert"] integerValue]);
            fdFromLocal.my_plant_id = @([dicFdFromServer[@"my_plant_id"] integerValue]);
            fdFromLocal.my_plant_latitude = @([dicFdFromServer[@"my_plant_latitude"] doubleValue]);
            fdFromLocal.my_plant_longitude = @([dicFdFromServer[@"my_plant_longitude"] doubleValue]);
            fdFromLocal.my_plant_name = dicFdFromServer[@"my_plant_name"];
            fdFromLocal.my_plant_pic_url = dicFdFromServer[@"my_plant_pic_url"];
            fdFromLocal.my_plant_pot = @([dicFdFromServer[@"my_plant_pot"] isEqualToString:@"01"]);
            fdFromLocal.my_plant_room = @([dicFdFromServer[@"my_plant_room"] isEqualToString:@"01"]);
            fdFromLocal.plant_id = @([dicFdFromServer[@"plant_id"] integerValue]);
            fdFromLocal.isUpdate = @YES;
            NSLog(@"--- > %@ ---- > %@", fdFromLocal.my_plant_name, dicFdFromServer[@"my_plant_name"]);
            DBSave;
            [self.arrData addObject:fdFromLocal];
        }
        
        NSArray *arrDataFromLocal = [FlowerData findByAttribute:@"access" withValue:self.userInfo.access];
        if (arrDataFromLocal.count > arrPlantData.count && arrPlantData)
        {
            for (int i = 0; i < arrDataFromLocal.count; i++)
            {
                FlowerData *fdFromLocal = arrDataFromLocal[i];
                if (![self.arrData containsObject:fdFromLocal]) {
                    [fdFromLocal MR_deleteEntityInContext:DBefaultContext];
                }
            }
            DBSave;
        }
        
        
        [self refreshView];
        [self refreshRightButton];
    }
}

-(void)dataSuccessBack_deletePlant:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSLog(@"删除成功");
        LMBShow(@"删除成功");
        [self refreshView];
    }
}

// 进行裁剪
-(UIImage *)getImageBySize:(UIImage *)image
{
    float imageW = image.size.width;  // 这里是正方形
    float newWidth = imageW * buttonWidth / buttonHeight;
    float posX = (imageW - imageW * buttonWidth / buttonHeight) / 2;
    CGRect trimArea = CGRectMake(posX, 0, newWidth, imageW);
    
    CGImageRef srcImageRef = [image CGImage];
    CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
    image = [UIImage imageWithCGImage:trimmedImageRef];
    return image;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"index_to_main"])
    {
        vcMain *vc = (vcMain *)segue.destinationViewController;
        vc.flower = sender;
    }
}


@end
