//
//  NSString+toDate.h
//  aerocom
//
//  Created by 丁付德 on 15/7/1.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (toDate)


/**
 *  NSString 转化 NSDate
 *
 *  @param str NSString
 *
 *  @return NSDate
 */
- (NSDate *)toDate;

/**
 *  NSString 转化 NSDate
 *
 *  @param intString 19890302
 *
 *  @return NSDate
 */
- (NSDate *)toDate: (NSString *)intString;


@end
