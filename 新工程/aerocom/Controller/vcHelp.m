//
//  vcHelp.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcHelp.h"

#define  getFileUrlInterFaceIndex      1321


@interface vcHelp()
{
    NSString *imgNameFromLocal;  // help_zh   help_en  help_fr
    NSInteger langIndex;         // 1  2  3
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainContentHeight;
@property (nonatomic, strong) UIImageView *imv;

@end

@implementation vcHelp

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"使用帮助"];
    self.isPop = NO;
    
    [self initLeftButton:@"iosmulu"];
    
    [self initView];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(void)initData
{
    
//#warning ---------------- FIXME fo help_zh  默认为中文
    self.imv.image = [UIImage imageNamed:@"help_zh"];
    NSMutableArray *arr = GetUserDefault(HelpUrlVersion);                 // 0: 时间值  1， 版本号  2 URL  3 是否有更新  4 语言 1 2 3
    if (arr)
    {
        switch ([self getPreferredLanguage]) {
            case 1:
                langIndex = 1;
                imgNameFromLocal = @"help_zh";
                break;
            case 2:
                langIndex = 2;
                imgNameFromLocal = @"help_en";
                break;
            case 3:
                langIndex = 3;
                imgNameFromLocal = @"help_fr";
                break;
                
            default:
                break;
        }
        
        NSArray * arrUrl = arr[2];
        [self.imv sd_setImageWithURL:[NSURL URLWithString:arrUrl[langIndex - 1]] placeholderImage:IMG(imgNameFromLocal)];
    }
    
    if ([arr[3] boolValue])
    {
        __block vcHelp *blockSelf = self;
        RequestCheckNoWaring(
         [net getFileUrl:blockSelf.userInfo.access];,
         [blockSelf dataSuccessBack_getFileUrl:dic];)
    }
}

-(void)initView
{
    self.viewMainContentHeight.constant = RealWidth(8650.0) - NavBarHeight;
    self.imv = [[UIImageView alloc] init];
    self.imv.frame = CGRectMake(0, 0, ScreenWidth, RealWidth(8650.0));
    [self.viewMain addSubview:self.imv];
}

-(void)dataSuccessBack_getFileUrl:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSString *url = dic[@"file_url"];
        NSString *version = dic[@"version"];
        NSString *lastTime = dic[@"update_time"];
        
        [self.imv sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:IMG(imgNameFromLocal)];
        
        // 图片保存在本地  没有替换，  这里出现本地有两个名字一样的图片， 一个在程序中， 一个在Documens中，  
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [self saveImageToDocoment:data name:imgNameFromLocal];
        
        
        NSArray *arr = GetUserDefault(HelpUrlVersion);
        NSMutableArray *arrNew = [arr[2] mutableCopy];
        arrNew[langIndex - 1] = url;
        
        NSArray *arrVersion = [NSArray arrayWithObjects:lastTime, version, arrNew, @(NO), @(langIndex), nil];
        SetUserDefault(HelpUrlVersion, arrVersion);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}



@end
