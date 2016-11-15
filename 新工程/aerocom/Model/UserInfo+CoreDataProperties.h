//
//  UserInfo+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSNumber *distanceSwitch;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *file_url;
@property (nullable, nonatomic, retain) NSNumber *help_pic_update_time;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) NSString *imageType;
@property (nullable, nonatomic, retain) NSNumber *info_end;
@property (nullable, nonatomic, retain) NSNumber *info_start;
@property (nullable, nonatomic, retain) NSNumber *isUpate;
@property (nullable, nonatomic, retain) NSString *moblie;
@property (nullable, nonatomic, retain) NSNumber *my_plant_update_time;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSNumber *plant_data_max_version;
@property (nullable, nonatomic, retain) NSNumber *temperatureSwitch;
@property (nullable, nonatomic, retain) NSNumber *update_time;
@property (nullable, nonatomic, retain) NSDate *user_birthday;
@property (nullable, nonatomic, retain) NSNumber *user_city_code;
@property (nullable, nonatomic, retain) NSNumber *user_country_code;
@property (nullable, nonatomic, retain) NSNumber *user_gender;
@property (nullable, nonatomic, retain) NSNumber *user_height;               // doubleValue
@property (nullable, nonatomic, retain) NSNumber *user_info_update_time;
@property (nullable, nonatomic, retain) NSString *user_nick_name;
@property (nullable, nonatomic, retain) NSString *user_pic_url;
@property (nullable, nonatomic, retain) NSNumber *user_state_code;
@property (nullable, nonatomic, retain) NSNumber *user_weight;               // doubleValue

@end

NS_ASSUME_NONNULL_END
