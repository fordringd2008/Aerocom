//
//  NetTool+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NetTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetTool (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateTime;                       // 操作的时间
@property (nullable, nonatomic, retain) NSNumber *flower_id;                    // 植物ID
@property (nullable, nonatomic, retain) NSNumber *isFinish;                     // 当前操作 是否已经处理过
@property (nullable, nonatomic, retain) NSNumber *type;                         // 操作类型
                                                                                // 0为植物添加 植物修改
                                                                                // 1为植物删除
                                                                                // 2为同步数据
                                                                                // 3为个人信息修改
                                                                                // 4为系统信息修改
                                                                                // 5为提醒上传
                                                                                //
                                                                                //
@property (nullable, nonatomic, retain) NSString *user_id;                      // 用户ID

@end

NS_ASSUME_NONNULL_END
