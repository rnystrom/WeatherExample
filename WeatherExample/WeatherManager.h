//
//  WeatherManager.h
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/9/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CurrentCondition;

@interface WeatherManager : NSObject
<CLLocationManagerDelegate>

+ (instancetype)shareManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) CurrentCondition *currentCondition;

- (void)findCurrentLocation;

@end
