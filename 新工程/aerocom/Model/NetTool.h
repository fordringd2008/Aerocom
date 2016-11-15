//
//  NetTool.h
//  
//
//  Created by 丁付德 on 15/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetTool : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

/**
 *  初始化默认数据
 */
+ (void)initAll;

/**
 *  修改具体类型的处理结果
 *
 *  @param type
 *  @param isFinish
 */
+ (void)changeType:(NSInteger)type isFinish:(BOOL)isFinish;


/**
 *  获得指定修改类型的时间值
 *
 *  @param type type
 *
 *  @return
 */
+ (long long)getLastDateTime:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END

#import "NetTool+CoreDataProperties.h"
