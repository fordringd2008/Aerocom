//
//  aLiNet.h
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALBB_OSS_IOS_SDK/OSSService.h>
#import "TCBlobDownloadManager.h"
#import "NetManager.h"

@protocol aLiNetDelegate <NSObject>

-(void)upload:(BOOL)isOver;

@end

@interface aLiNet : NSObject <TCBlobDownloadDelegate>

@property (nonatomic, strong) OSSBucket *       bucket;
@property (nonatomic, strong) OSSData *         ossDownloadData;
@property (nonatomic, strong) OSSData *         ossUploadData;

@property (nonatomic, strong) NSString *        accessKey;
@property (nonatomic, strong) NSString *        secretKey;
@property (nonatomic, strong) NSString *        yourBucket;
@property (nonatomic, strong) NSString *        yourDownloadObjectKey;
@property (nonatomic, strong) NSString *        yourUploadObjectKey;
@property (nonatomic, strong) NSString *        yourUploadDataPath;
@property (nonatomic, strong) NSString *        yourHostId;
@property (nonatomic, strong) NSString *        expiration;
@property (nonatomic, strong) NSString *        federatedUser;
@property (nonatomic, strong) NSString *        requestId;
@property (nonatomic, strong) NSString *        securityToken;

@property (nonatomic, assign) BOOL              isLoadFinish;               // 是否下载完毕
@property (nonatomic, assign) NSInteger         loadIndex;                  // 下载的序号

@property (nonatomic, strong) NetManager*       netManager;
@property (nonatomic, assign) NSInteger         version_New;                // 正在处理的最新数据包


@property (nonatomic , unsafe_unretained)       TCBlobDownloadManager *sharedDownloadManager;                 // 大数据下载帮助类实例

@property (nonatomic, strong)                   id<aLiNetDelegate>    delegate;


@property (nonatomic, assign) BOOL              isUpdataing;                // 是否正在下 失败后 防止同时下载

- (void)initOSSService:(NSString *)imgType imData:(NSData *)imData;
- (void)uploadStart;

- (void)initAndupload:(NSString *)imgType imData:(NSData *)imData dic:(NSDictionary *)dic;

//- (void)downloadStart;

- (void)downLoadNewestData:(NSMutableArray *)arrAddress;

- (void)downLoadNewestData_112:(NSMutableArray *)arrNew;

//- (void)deleteZip;

@end
