//
//  aLiNet.m
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "aLiNet.h"
#import "ZipArchive.h"
#import "vcBase.h"

@interface aLiNet ()
{
    NSArray *arrAllPicture;     // 所有的图片包， 用于删除
}



@end

@implementation aLiNet

- (void)initOSSService:(NSString *)imgType imData:(NSData *)imData
{
    NSTimeInterval time= [[NSDate date] timeIntervalSince1970]*1000;
    NSString *imType = [imgType isEqualToString:@"image/jpeg"] ? @".jpg" : @".png";
    NSString *imgName = [NSString stringWithFormat:@"test%.0f%@", time, imType];
    
    self.yourUploadDataPath = my_plant_pic;
    self.yourDownloadObjectKey = sourse;
    self.yourUploadObjectKey = imgName;
    self.yourHostId = ALI_HostId;
    self.yourBucket = my_plant_pic;
    
    id<ALBBOSSServiceProtocol> ossService = [ALBBOSSServiceProvider getService];
    [ossService setGlobalDefaultBucketAcl:PUBLIC_READ_WRITE];
    [ossService setGlobalDefaultBucketHostId:self.yourHostId];
    [ossService setAuthenticationType:FEDERATION_TOKEN];
    
    [ossService setFederationTokenGetter:^OSSFederationToken *
     {
         OSSFederationToken *token = [[OSSFederationToken alloc] init];
         token.ak = self.accessKey;
         token.sk = self.secretKey;
         token.tempToken = self.securityToken;
         token.expiration = @([[self.expiration description] longLongValue]);
         return token;
     }];
    
    self.bucket = [ossService getBucket:self.yourBucket];
    self.ossDownloadData = [ossService getOSSDataWithBucket:self.bucket key:self.yourDownloadObjectKey];
    self.ossUploadData = [ossService getOSSDataWithBucket:self.bucket key:self.yourUploadObjectKey];
    NSData *uploadData = imData;
    [self.ossUploadData setData:uploadData withType:imgType];
    [self.ossUploadData enableUploadCheckMd5sum:YES];
}

-(void)uploadStart
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.ossUploadData uploadWithUploadCallback:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                //NSLog(@"上传成功");
                [self.delegate upload:YES];
            } else {
                NSLog(@"上传失败");
                NSLog(@"失败原因：%@", error);
                [self.delegate upload:NO];
            }
        } withProgressCallback:^(float progress) {
            NSLog(@"当前进度： %f", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    });
}

- (void)initAndupload:(NSString *)imgType imData:(NSData *)imData dic:(NSDictionary *)dic;
{
    self.accessKey = dic[@"accessKeyId"];
    self.secretKey = dic[@"accessKeySecret"];
    self.expiration = dic[@"expiration"];
    self.federatedUser = dic[@"federatedUser"];
    self.requestId = dic[@"requestId"];
    self.securityToken = dic[@"securityToken"];
    [self initOSSService:imgType imData:imData];
    [self uploadStart];
}

-(void)downloadStart:(void(^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.ossDownloadData getWithDataCallback:^(NSData *data, NSError *error){
            NSLog(@"成功下载数据的大小:%lu", (unsigned long)data.length);
            block();
            self.isLoadFinish = YES;
        } withProgressCallback:^(float progressFloat){
            NSLog(@"当前进度： %f", progressFloat);
            dispatch_async(dispatch_get_main_queue(), ^{});
        }];
    });
}

- (void)downloadTextFile:(NSString*)url block:(void(^)(NSData *, NSString *))block
{
    self.sharedDownloadManager = [TCBlobDownloadManager sharedDownloadManager];
    [self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:url] customPath:nil
                                       firstResponse:^(NSURLResponse *response) {
                                           NSLog(@"count = %lld", [response expectedContentLength]);
                                       } progress:^(float receivedLength, float totalLength) {
                                           NSLog(@"receivedLength = %.2f, totalLength = %.2f", receivedLength, totalLength);
                                       } error:^(NSError *error) {
                                           NSLog(@"%@", error);
                                       } complete:^(BOOL downloadFinished, NSString *pathToFile) {
                                           NSLog(@"downloadFinished :%@, pathToFile = %@", @(downloadFinished), pathToFile);
                                           
                                           NSString *tmpDir =  NSTemporaryDirectory();
                                           NSArray *arrStr =[url componentsSeparatedByString:NSLocalizedString(@"/", nil)];
                                           NSString *zipName = arrStr[arrStr.count - 1];
                                           NSString *path = [NSString stringWithFormat:@"%@%@", tmpDir, zipName];
                                           
                                           NSLog(@"这个path是zip文件的地址，解压的时候用到 : %@", path);
                                           NSData *data = [NSData dataWithContentsOfFile:path];
                                           NSLog(@"data.length = %lu", (unsigned long)data.length);
                                           block(data, zipName);
                                           
                                       }];
}

// arrAddress  0:picURL  1:jsonURL  3:version     // 新版本 遗弃
- (void)downLoadNewestData:(NSMutableArray *)arrAddress
{
//    static BOOL isLoading = YES;
//    if (!isLoading) return;
//    NextWait(isLoading = YES;, 60);
//    isLoading = NO;
//    
    if (self.isUpdataing) return;
    self.isUpdataing = YES;
    
    // 下载完成后（图片数据包 和 json数据包），  需要把本地userDefault改为现有有版本
    if (arrAddress.count != 3) {
        NSLog(@" ------------------------  这里出错了");
    }
    NSString *picURL = arrAddress[0];
    NSString *jsonURL = arrAddress[1];
    self.version_New = [arrAddress[2] integerValue];
    
    NSArray *arrPicURL = [picURL componentsSeparatedByString:NSLocalizedString(@"/", nil)];
    NSString *zipName = arrPicURL[arrPicURL.count - 1];
    
    //  已经OK 可以解压压缩包中的东西啦  NND ----------------------------------------------------------------------
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:picURL];
        NSError *error = nil;
        
        NSString *path = [self getCacheURL];                                                             // cache目录
        NSString *documentPath = [self getDomentURL];
        NSString *zipPath = [documentPath stringByAppendingPathComponent:zipName];                       // 获取刚才下载的文件路径
        
        NSData *data;
        if (![[self getFileNamesFromURL:documentPath] containsObject:zipName])
            data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        
        if(!error)
        {
            if(data) [data writeToFile:zipPath options:0 error:&error];   // 保存在Documnet文件夹中
            if(!error)
            {
                ZipArchive *za = [[ZipArchive alloc] init];
                if ([za UnzipOpenFile: zipPath])
                {
                    BOOL ret = [za UnzipFileTo: path overWrite: YES];
                    if (NO == ret){} [za UnzipCloseFile];
                    BOOL isSaveOK = YES;
                    NSArray *arrFileNames = [self getFileNamesFromURL:path];
                    for (NSString *fileName in arrFileNames)
                    {
                        // 坑爹的江华  这里去掉了后缀名   && [fileName rangeOfString:@".png"].length > 0
                        if ([fileName rangeOfString:@"icon"].length > 0)
                        {
                            NSString *imageFilePath = [path stringByAppendingPathComponent:fileName];
                            
                            if([[self getFileNamesFromURL:documentPath] containsObject:fileName])   // 说明之前已经已经保存了
                                isSaveOK = YES;
                            else
                            {
                                NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                                isSaveOK = [self saveImageToDocoment:imageData name:fileName];
                            }
                            if (isSaveOK)
                            {
                                //NSLog(@"%@ 保存成功", fileName);
                            }
                            else
                            {
                                NSLog(@"%@ ------  保存失败， 已经保存的个数 %@", fileName, @([self getFileNamesFromURL:documentPath].count));
                                
                                break;
                            }
                            // 测试
                            //NSString *strAAA = [NSString stringWithFormat:@"%@/%@", domentsPath, fileName];
                            //UIImage *imgA = [UIImage imageNamed:strAAA];
                            //NSData *daaaaa = UIImagePNGRepresentation(imgA);
                        }
                    }
                    
                    if (isSaveOK)
                    {
                        __block vcBase *blockSelf = (vcBase *)self.delegate;
                        RequestCheckNoWaring(
                         [net getNewestPlantJSONData:jsonURL];,
                         [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];)
                    }
                    else
                        NSLog(@"保存图片过程中，出现错误");
                }
            }
            else
            {
                NSLog(@"Error saving file %@",error);
            }
        }
        else
        {
            NSLog(@"Error downloading zip file: %@", error);
        }
    });
}

// arrNew 里面是字典  key:version value：picURL  再加一个  key:json value:json地址
- (void)downLoadNewestData_112:(NSMutableArray *)arrNew
{
    if (self.isUpdataing) return;
    self.isUpdataing = YES;
    
    if (arrNew.count > 1)
    {
        if(!arrAllPicture) arrAllPicture = [arrNew mutableCopy];   // 第一次进入的时候赋值
        [self downloadInFor:arrNew];
    }
    else
    {
        NSLog(@" ------------------------  这里出错了");
    }
}

-(void)downloadInFor:(NSMutableArray *)arr
{
    NSDictionary *dicNew = arr[0];
    NSString *picURL = dicNew.allValues[0];
    self.version_New = [dicNew.allKeys[0] integerValue];;
    
    NSArray *arrPicURL = [picURL componentsSeparatedByString:NSLocalizedString(@"/", nil)];
    NSString *zipName = arrPicURL[arrPicURL.count - 1];
    
    //  已经OK 可以解压压缩包中的东西啦  NND ----------------------------------------------------------------------
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:picURL];
        NSError *error = nil;
        
        NSString *path = [self getDomentURL];//[self getCacheURL];                // cache目录
        NSString *documentPath = [self getDomentURL];
        NSString *zipPath = [documentPath stringByAppendingPathComponent:zipName];    // 获取刚才下载的文件路径
        
        NSData *data;
        //NSLog(@"--- fileName %@", [self getFileNamesFromURL:documentPath]);
        if (![[self getFileNamesFromURL:documentPath] containsObject:zipName])
        {
            NSLog(@"不包含, 正在下载 %@", zipName);
            data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        }
        else
        {
            NSLog(@"包含, 就不用下载了， 直接加压就好了");
        }
        
        if(!error)
        {
            NSLog(@"zipPath %@", zipPath);
            if(data) [data writeToFile:zipPath options:0 error:&error];   // 保存在Documnet文件夹中
            
            if(!error)
            {
                ZipArchive *za = [[ZipArchive alloc] init];
                if ([za UnzipOpenFile: zipPath])
                {
                    BOOL ret = [za UnzipFileTo: path overWrite: YES];
                    if (!ret){} [za UnzipCloseFile];
                    
                    BOOL isSaveOK = YES;
                    NSArray *arrFileNames = [self getFileNamesFromURL:path];
                    for (NSString *fileName in arrFileNames)
                    {
                        // 坑爹的江华  这里去掉了后缀名   && [fileName rangeOfString:@".png"].length > 0
                        if ([fileName rangeOfString:@"icon"].length > 0)
                        {
                            NSString *imageFilePath = [path stringByAppendingPathComponent:fileName];
                            if([[self getFileNamesFromURL:documentPath] containsObject:fileName])   // 说明之前已经已经保存了
                            {
                                isSaveOK = YES;
                                NSLog(@"已经存在 名称：%@", fileName);
                            }
                            else
                            {
                                NSLog(@"不存在，正在解压");
                                NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                                isSaveOK = [self saveImageToDocoment:imageData name:fileName];
                            }
                            
                            if (isSaveOK)
                            {
                                NSLog(@"%@ 保存成功", fileName);
                            }
                            else
                            {
                                NSLog(@"%@ ------  保存失败， 已经保存的个数 %@", fileName, @([self getFileNamesFromURL:documentPath].count));
                                break;
                            }
                        }
                    }
                    
                    if (isSaveOK)
                    {
                        [arr removeObjectAtIndex:0];
                        SetUserDefault(version_Pic, @(self.version_New));

                        if (arr.count > 1)
                        {
                            [self downloadInFor:arr];
                        }
                        else
                        {
                            [self deleteZip];
                            NSDictionary *d = arr[0];
                            [self loadJson:d[@"json"]];
                        }
                    }
                    else
                    {
                        NSLog(@"------- 1 保存图片过程中，出现错误");
                        RemoveUserDefault(UpdateDataing);
                        self.isUpdataing = NO;
                    }
                }
                else
                {
                    NSLog(@"------- 2 解压失败 %@",error);
                    RemoveUserDefault(UpdateDataing);
                    self.isUpdataing = NO;
                }
            }
            else
            {
                NSLog(@" ------- 3  写入失败 %@",error);
                RemoveUserDefault(UpdateDataing);
                self.isUpdataing = NO;
            }
        }
        else
        {
            NSLog(@"------- 4  下载失败: %@", error);
            RemoveUserDefault(UpdateDataing);
            self.isUpdataing = NO;
        }
    });
}

// 这里jSon  删除 没有做
-(void)loadJson:(NSString *)jsonUrl
{
    __block vcBase *blockSelf = (vcBase *)self.delegate;
    RequestCheckBefore(
       NSLog(@"开始下载JSon文件");
       SetUserDefault(NewJsonURL, jsonUrl);
       [net getNewestPlantJSONData:jsonUrl];,
       [blockSelf dataSuccessBack_getNewestPlantJSONData:dic];,
       NSLog(@"------- 5  下载Json 失败");
       RemoveUserDefault(UpdateDataing);
       SetUserDefault(JSonFail, @YES);
       self.isUpdataing = NO;)
}

// 删除所有图片包
-(void)deleteZip
{
    for (int i = 0; i < arrAllPicture.count - 1; i++)
    {
        NSDictionary *dicNew = arrAllPicture[i];
        NSString *picURL = dicNew.allValues[0];
        NSArray *arrPicURL = [picURL componentsSeparatedByString:NSLocalizedString(@"/", nil)];
        NSString *zipName = arrPicURL[arrPicURL.count - 1];
        NSString *zipPath = [[self getDomentURL] stringByAppendingPathComponent:zipName];
        BOOL isDelete = [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
        isDelete = isDelete;
        NSLog(@"安装包：%@, 是否删除：%@", zipName, @(isDelete));
    }
}



@end
