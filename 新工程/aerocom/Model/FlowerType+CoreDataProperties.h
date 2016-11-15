//
//  FlowerType+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlowerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowerType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *descript;                      //  简介
@property (nullable, nonatomic, retain) NSString *icon;                          //  图标
@property (nullable, nonatomic, retain) NSNumber *iD;                            //  序号
@property (nullable, nonatomic, retain) NSNumber *light;                         //  光照等级
@property (nullable, nonatomic, retain) NSNumber *light_highest_time;            //  光照最高报警时间
@property (nullable, nonatomic, retain) NSNumber *light_lowest_time;             //  光照最低报警时间
@property (nullable, nonatomic, retain) NSString *name;                          //  名称
@property (nullable, nonatomic, retain) NSString *otherName;                     //  别名
@property (nullable, nonatomic, retain) NSString *scientificname;                //  学术名
@property (nullable, nonatomic, retain) NSNumber *soli;                          //  湿度等级
@property (nullable, nonatomic, retain) NSString *startLetter;                   //  排序
@property (nullable, nonatomic, retain) NSString *temp1;                         //  备用
@property (nullable, nonatomic, retain) NSString *temp2;
@property (nullable, nonatomic, retain) NSString *temp3;
@property (nullable, nonatomic, retain) NSString *temp4;
@property (nullable, nonatomic, retain) NSNumber *temperature;                   //  温度等级  (没用)
@property (nullable, nonatomic, retain) NSNumber *temperatureHeight;             //  适合的最高温度
@property (nullable, nonatomic, retain) NSNumber *temperatureHeightEST;          //  最高极限温度
@property (nullable, nonatomic, retain) NSNumber *temperatureLow;                //  适合的最低温度
@property (nullable, nonatomic, retain) NSNumber *temperatureLowEST;             //  最低的极限温度

@end

NS_ASSUME_NONNULL_END
