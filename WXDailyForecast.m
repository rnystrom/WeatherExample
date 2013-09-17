//
//  WXDailyForecast.m
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/12/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

// Use the super class's method and extend for a custom API call
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    return paths;
}

@end
