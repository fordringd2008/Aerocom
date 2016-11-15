//
//  FlowerData+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlowerData.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowerData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSString *alarm_set;             // 提醒 是否开启  报警设置    0-0-0-0  光照，温度，湿度, 拍照
@property (nullable, nonatomic, retain) NSString *bind_device_mac;
@property (nullable, nonatomic, retain) NSString *bind_device_name;
@property (nullable, nonatomic, retain) NSNumber *camera_alert;          // 拍照提醒的天数
@property (nullable, nonatomic, retain) NSData *  imageData;
@property (nullable, nonatomic, retain) NSString *imageType;             // 图片格式
@property (nullable, nonatomic, retain) NSNumber *isUpdate;
@property (nullable, nonatomic, retain) NSDate *last_photo_time;         // 上次拍照的日期 （ 服务器没有， 存在本地 ）
@property (nullable, nonatomic, retain) NSNumber *my_plant_id;
@property (nullable, nonatomic, retain) NSNumber *my_plant_id_T;         // 上传后， 临时ID 设置为0
                                                                         // @((arc4random() % 1000000) + 9000000);  // 临时ID  一百万 - 一千万
@property (nullable, nonatomic, retain) NSNumber *my_plant_latitude;     // 纬度
@property (nullable, nonatomic, retain) NSNumber *my_plant_longitude;    // 经度
@property (nullable, nonatomic, retain) NSString *my_plant_name;
@property (nullable, nonatomic, retain) NSString *my_plant_pic_url;
@property (nullable, nonatomic, retain) NSNumber *my_plant_pot;          // bool 是否是花盆
@property (nullable, nonatomic, retain) NSNumber *my_plant_room;         // bool 是否是室内
@property (nullable, nonatomic, retain) NSNumber *plant_id;
@property (nullable, nonatomic, retain) NSNumber *score;                 // 昨天的分数   （ 这个在每天的第一次同步完成后， 拿取昨天的数据算出 ）
                                                                         // 这个在同步完成后， 会不停的替换掉前一天的得分
@property (nullable, nonatomic, retain) NSNumber *update_time;           // 上次更新日期  (long long)

@end

NS_ASSUME_NONNULL_END
