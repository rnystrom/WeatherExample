//
//  CurrentCondition.m
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/9/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#define MPS_TO_MPH 2.23694f

#import "CurrentCondition.h"

@implementation CurrentCondition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"date": @"dt",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"locationName": @"name",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return @(str.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return [NSString stringWithFormat:@"%f",speed.floatValue/MPS_TO_MPH];
    }];
}

@end
