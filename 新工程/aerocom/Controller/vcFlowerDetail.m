//
//  vcFlowerDetail.m
//  aerocom
//
//  Created by 丁付德 on 15/7/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFlowerDetail.h"
#import "SHLUILabel.h"
#import "vcNew.h"

@interface vcFlowerDetail ()
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblNameEn;

@property (weak, nonatomic) IBOutlet UIView *viewLight;
@property (weak, nonatomic) IBOutlet UIView *viewSoli;
@property (weak, nonatomic) IBOutlet UILabel *lblTemp;


@property (weak, nonatomic) IBOutlet UIView *viewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLabelContentHeight;


@end

@implementation vcFlowerDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"花草分类详情"];
    
    [self initRightButton:nil imgName:@"baocun"];
    
    [self initView];
}

-(void)initView
{
    // 572 429
    
    [self initImv];
    
    self.lblName.text = self.model.name;
    self.lblNameEn.text = self.model.scientificname;
    self.lblTemp.text = [NSString stringWithFormat:@"%@°C ~ %@°C", self.model.temperatureLow, self.model.temperatureHeight];
    
    SHLUILabel *lblDescrip = [[SHLUILabel alloc] init];
    lblDescrip.lineBreakMode = NSLineBreakByWordWrapping;
    lblDescrip.numberOfLines = 0;
    lblDescrip.font = [UIFont systemFontOfSize:14];
    lblDescrip.text = self.model.descript;
    CGFloat titleHeight = [ lblDescrip getAttributedStringHeightWidthValue:ScreenWidth - 40 ];
    lblDescrip.frame = CGRectMake(0, 0, ScreenWidth - 40, titleHeight);
    [self.viewLabel addSubview:lblDescrip];

    self.viewLabelContentHeight.constant = titleHeight;
    self.viewMainContentHeight.constant = 250 + RealWidth(570) / (572 / 429) + titleHeight; // - NavBarHeight;

    
    
    for (int i = 0 ; i < 5; i++)
    {
        UIImageView *imgLight = self.viewLight.subviews[i];
        UIImageView *imgSoli = self.viewSoli.subviews[i];
        if ([self.model.light integerValue] > i) {
            imgLight.image = [UIImage imageNamed:@"sun1"];
        }
        
        if ([self.model.soli integerValue] > i) {
            imgSoli.image = [UIImage imageNamed:@"shidu1"];
        }
    }
}

-(void)initImv
{
    CGFloat imvRadio = 572 / 429.0;
    
    CGFloat resultWidth = ScreenWidth * (572/1242.0);
    CGFloat resultHeigth = resultWidth / imvRadio;
    
    UIImage *image = ImageFromLocal(self.model.icon);
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    
    CGFloat width, heigth;
    if (imageW / imageH >= imvRadio)
    {
        width = resultWidth;
        heigth = resultWidth * imageH / imageW;
    }
    else
    {
        heigth = resultHeigth;
        width = resultHeigth * imageW / imageH;
    }
    
    NSLog(@"%f,%f", width, heigth);
    
    UIImageView *imvNew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, heigth)];
    imvNew.image = image;
    
    imvNew.center = CGPointMake(ScreenWidth / 2, 20 + resultHeigth / 2);
    [self.viewMain addSubview:imvNew];
}

-(void)rightButtonClick
{
    // 一次性跳转回主界面
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[vcNew class]])
        {
            vcNew *vc_ = (vcNew *)vc;
            vc_.ftModel = self.model;
            vc_.isChange = YES;
            [self.navigationController popToViewController:vc_ animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
 #pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"detail_to_new"]) {
         vcNew *vc = (vcNew *)segue.destinationViewController;
         vc.ftModel = sender;
     }
 }

@end
