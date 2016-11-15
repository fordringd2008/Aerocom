//
//  Album+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Album.h"

NS_ASSUME_NONNULL_BEGIN

@interface Album (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;                        // 用户ID
@property (nullable, nonatomic, retain) NSDate *datetime;                        // 拍照的时间      （ 用于 提醒表比较 ）
@property (nullable, nonatomic, retain) NSNumber *flowerID;                      // 关联的植物ID   （ 可能是临时ID ）
@property (nullable, nonatomic, retain) NSNumber *imgID;                         // 相片的ID
@property (nullable, nonatomic, retain) NSString *imgName;                       // 名称

@end

NS_ASSUME_NONNULL_END
