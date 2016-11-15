//
//  UIViewController+GetAccess.m
//  Coasters
//
//  Created by 丁付德 on 15/12/18.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "UIViewController+GetAccess.h"
#import <AssetsLibrary/AssetsLibrary.h>             // 相册
//#import <AVFoundation/AVCaptureDevice.h>            // 这两个是 摄像头
//#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVFoundation.h>               // 麦克风

@implementation UIViewController (GetAccess)

#pragma mark  判断是否含有权限  当有权限的时候 进行操作  1: 相册  2: 摄像头  3:麦克风 4:   5:
- (void)getAccessNext:(int)typeSub block:(void(^)())block
{
    switch (typeSub) {
        case 1:
        {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            NSLog(@"照片访问权限 --> %ld", (long)author);
            switch (author)
            {
                //case ALAuthorizationStatusNotDetermined:
                case ALAuthorizationStatusRestricted:
                case ALAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"请在“设置-隐私-照片“选项中,允许Aerocom访问你的照片") delegate:self cancelButtonTitle:nil otherButtonTitles:kString(@"好"), nil] show];
                    });
                }
                    break;
                default:
                {
                    block();
                }
                    break;
            }
        }
            break;
        case 2:
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            NSLog(@"相机访问权限 --> %ld", (long)authStatus);
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"请在“设置-隐私-相机“选项中,允许Aerocom访问你的相机") delegate:self cancelButtonTitle:nil otherButtonTitles:kString(@"好"), nil] show];
                });
                
            }else{
                block();
            }
        }
            break;
        case 3:
        {
            AVAudioSession *avSession = [AVAudioSession sharedInstance];
            if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
            {
                [avSession requestRecordPermission:^(BOOL available)
                 {
                     if (available) {
                         NSLog(@"获得权限");
                         block();
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [[[UIAlertView alloc] initWithTitle:kString(@"无法录音") message:kString(@"请在“设置-隐私-麦克风“选项中,允许HMPillow访问你的麦克风") delegate:nil cancelButtonTitle:kString(@"好") otherButtonTitles:nil] show];
                         });
                     }
                 }];
            }
        }
            break;
        case 4:
            
            break;
        case 5:
            
            break;
            
        default:
            break;
    }
}


@end
