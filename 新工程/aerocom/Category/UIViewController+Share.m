
//
//  UIViewController+Share.m
//  FitTu
//
//  Created by 丁付德 on 15/6/3.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "UIViewController+Share.h"

@implementation UIViewController (Share)

//-(void)share:(int)shareType
//{
//    ShareType type = 0;
//    switch (shareType) {
//        case 1:
//            type = ShareTypeSinaWeibo;
//            break;
//        case 2:
//            type = ShareTypeQQSpace;
//            break;
//            
//        default:
//            break;
//    }
//    
//    //1.定制分享的内容
//    NSString* path = [[NSBundle mainBundle]pathForResource:@"ShareSDK" ofType:@"jpg"];
//    path = @"http://img0.bdstatic.com/img/image/4a75a05f8041bf84df4a4933667824811426747915.jpg";
//    
//    UIImage *shareimage = [self imageFromView:self.view];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    // APPID 来自
//    // https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa
//    NSString *sharUrl = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d", AerocomAPPID];
//    
//    NSString *shareContent = [NSString stringWithFormat:@"%@%@",ShareContent, sharUrl];
//    
//    id<ISSContent> publishContent = [ShareSDK content:shareContent defaultContent:nil image:[ShareSDK pngImageWithImage:shareimage] title:@"分享" url:ShareUrl description:shareContent mediaType:SSPublishContentMediaTypeNews];
//    //2.分享
//    [ShareSDK showShareViewWithType:type container:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)
//    {
//        //如果分享成功
//        if (state == SSResponseStateSuccess) {
//            
//            NSLog(@"分享成功");
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showSuccess:@"分享成功" toView:self.view];
//        }
//        //如果分享失败
//        if (state == SSResponseStateFail)
//        {
//            NSLog(@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]);
//            NSString *str = [NSString stringWithFormat:@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]];
//            //[MBProgressHUD showSuccess:str toView:self.view];
//            
//            MBHide;
//            MBShow(str);
//        }
//        if (state == SSResponseStateCancel){
//            
//            NSLog(@"分享取消");
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showSuccess:@"分享取消" toView:self.view];
//        }
//    }];
//}

- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)ShowShareActionSheet
{
    //[UIViewController CancelAuthWithAll];
    //1.定制分享的内容
    //NSString* path = [[NSBundle mainBundle]pathForResource:@"ShareSDK" ofType:@"jpg"];
    UIImage *shareimage = [self imageFromView:self.view];
    
    id<ISSContent> publishContent = [ShareSDK content:ShareContent defaultContent:nil image:[ShareSDK pngImageWithImage:shareimage] title:kString(@"分享") url:ShareUrl description:ShareDescription mediaType:SSPublishContentMediaTypeImage];
    //2.调用分享菜单分享
    [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)
    {
        //如果分享成功
        if (state == SSResponseStateSuccess)
        {
            NSLog(@"分享成功");
            LMBShow(@"分享成功");
            
        }
        //如果分享失败
        if (state == SSResponseStateFail)
        {
            NSLog(@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]);
            LMBShow(@"分享失败");
        }
        if (state == SSResponseStateCancel)
        {
            NSLog(@"分享取消");
            // LMBShow(@"分享取消");
        }
    }];
}

+ (void)CancelAuthWithAll
{
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeTencentWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeRenren];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
    [ShareSDK cancelAuthWithType:ShareTypeQQSpace]; // ShareTypeQQ
    [ShareSDK cancelAuthWithType:ShareTypeQQ];      // ShareTypeQQ
    [ShareSDK cancelAuthWithType:ShareTypeFacebook];
    [ShareSDK cancelAuthWithType:ShareTypeTwitter];
}













@end
