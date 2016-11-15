//
//  NetTool.m
//  
//
//  Created by 丁付德 on 15/11/14.
//
//

#import "NetTool.h"

@implementation NetTool

// Insert code here to add functionality to your managed object subclass


+ (void)initAll
{
    // 首先检查当前用户表下， 有没有基础数据
    NSInteger num = [[NetTool numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"user_id = %@", myUserInfo.access] inContext:DBefaultContext] integerValue];
    if (num == 10) {
        return;
    }
    
    // 默认给10种操作类型  在后续操作中， 只需修改这个就OK
    for (int i = 0; i < 10; i ++)
    {
        NetTool *nt = [NetTool MR_createEntityInContext:DBefaultContext];
        nt.user_id = myUserInfo.access;
        nt.type = @(i);
        nt.isFinish = @(YES);
        DBSave;
    }
}

// 0为植物添加 植物修改
// 1为植物删除
// 2为同步数据
// 3为个人信息修改
// 4为系统信息修改
// 5为提醒上传
//
//
+ (void)changeType:(NSInteger)type isFinish:(BOOL)isFinish
{
    [NetTool initAll];
    NetTool *nt = [NetTool findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user_id = %@ and type = %@", myUserInfo.access, @(type)] inContext:DBefaultContext];
    nt.dateTime = [NSDate date];
    nt.isFinish = @(isFinish);
    DBSave;
}

+(long long)getLastDateTime:(NSInteger)type
{
    NetTool *nt = [NetTool findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user_id = %@ and type = %@", myUserInfo.access, @(type)] inContext:DBefaultContext];
    long long dateValue = [nt.dateTime timeIntervalSince1970] * 1000;
    return dateValue;
}


@end
