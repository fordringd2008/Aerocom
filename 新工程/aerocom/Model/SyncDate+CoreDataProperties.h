//
//  SyncDate+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SyncDate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SyncDate (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSString *ambient_temperature;  // 环境温度
@property (nullable, nonatomic, retain) NSNumber *count;                // 总的数据值
@property (nullable, nonatomic, retain) NSNumber *dateValue;            // 日期值  5642
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *isUpload;
@property (nullable, nonatomic, retain) NSString *light;                // 环境光照
@property (nullable, nonatomic, retain) NSNumber *mean_ambienttem;      // 环境温度 平均值    这个是 50 + 摄氏温度  显示的时候 - 50
@property (nullable, nonatomic, retain) NSNumber *mean_light;           // 环境光照 平均值
@property (nullable, nonatomic, retain) NSNumber *mean_solimois;        // 土壤湿度 平均值
@property (nullable, nonatomic, retain) NSNumber *mean_solitem;         // 土壤温度 平均值（作废）
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSNumber *my_plant_id;
@property (nullable, nonatomic, retain) NSNumber *score;                // 得分  同步完成后的得分  24小时的数据完整后，才有得分， 并且下标是5
                                                                        // 这个会不停的覆盖掉植物表中的得分
@property (nullable, nonatomic, retain) NSString *soil_moisture;        // 土壤湿度
@property (nullable, nonatomic, retain) NSString *soli_temperature;     // 土壤温度 （作废）
@property (nullable, nonatomic, retain) NSNumber *sub;                  // 下标  一天会有6个
@property (nullable, nonatomic, retain) NSNumber *year;

@end

NS_ASSUME_NONNULL_END
