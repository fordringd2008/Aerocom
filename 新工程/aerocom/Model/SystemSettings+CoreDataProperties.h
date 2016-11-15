//
//  SystemSettings+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SystemSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SystemSettings (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSNumber *getAddress;
@property (nullable, nonatomic, retain) NSNumber *isUpload;
@property (nullable, nonatomic, retain) NSNumber *sys_distance_unit;                     // bool 是否是公制  (体重 和 )
@property (nullable, nonatomic, retain) NSNumber *sys_notify_time_end;
@property (nullable, nonatomic, retain) NSNumber *sys_notify_time_start;
@property (nullable, nonatomic, retain) NSNumber *sys_temperature_unit;                  // bool 是否是摄氏
@property (nullable, nonatomic, retain) NSNumber *update_time;                           // 时间值

@end

NS_ASSUME_NONNULL_END
