//
//  anotation.h
//  mapkit
//
//  Created by huangzhenyu on 15/5/19.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Myanotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+(NSMutableArray *)getLatitudeAndLongitude;

+(void)resetLatitudeAndLongitude;

@end
