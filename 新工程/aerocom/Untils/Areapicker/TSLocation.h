//
//  DDLocate.h
//  DDMates
//
//  Created by ShawnMa on 12/27/11.
//  Copyright (c) 2011 TelenavSoftware, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "County.h"
#import "State.h"

@interface TSLocation : NSObject


@property (strong, nonatomic) County *county_S;
@property (strong, nonatomic) State *state_S;

@end
