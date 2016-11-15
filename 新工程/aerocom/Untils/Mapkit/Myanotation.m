//
//  anotation.m
//  mapkit
//
//  Created by huangzhenyu on 15/5/19.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "Myanotation.h"

#import "locationGPS.h"
#import "LocationManager.h"


@interface Myanotation ()
@end

@implementation Myanotation


+(NSMutableArray *)getLatitudeAndLongitude
{
    locationGPS *loc = [locationGPS sharedlocationGPS];
    [loc getAuthorization];//授权
    [loc startLocation];//开始定位
    
    NSMutableArray *arrData = [loc getData];
    return  arrData;
}

+(void)resetLatitudeAndLongitude
{
    NSMutableArray * arrLatitudeAndLongitude = [self getLatitudeAndLongitude];
    if (arrLatitudeAndLongitude)
    {
        NSDate *lastDate = arrLatitudeAndLongitude[2];
        NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:lastDate];
        if (ti > 1 * 60 * 60) {
            [self resetLatitudeAndLongitude];
        }
        else
        {
            SetUserDefault(Latitude_Longitude, arrLatitudeAndLongitude);
        }
    }   
}

@end
