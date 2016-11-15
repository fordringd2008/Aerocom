//
//  Remind+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Remind.h"

NS_ASSUME_NONNULL_BEGIN

@interface Remind (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSString *alarm_sub_type;
                                                    //          报警类型  温度 ： 00 低温超过极限  01 偏低  02 偏高   03  高温超过极限，
                                                    //          光照(00少光 ，01光照强) 湿度(00少水 01多水)
@property (nullable, nonatomic, retain) NSString *alarm_type;        // 提醒类型  01：拍照；02：光照异常；03：温度异常；04：湿度异常
@property (nullable, nonatomic, retain) NSNumber *flower_Id;         // 植物ID
@property (nullable, nonatomic, retain) NSNumber *isShow;            // 是否展示 （这个也暂时不用 是否展示 根据昨天的时间判断 ）
@property (nullable, nonatomic, retain) NSNumber *isUpload;
@property (nullable, nonatomic, retain) NSNumber *k_date;            // 日期时间int值  5582
@property (nullable, nonatomic, retain) NSDate *remindDate;          // 提醒的具体时间  (暂时不用  不赋值)

@end

NS_ASSUME_NONNULL_END
