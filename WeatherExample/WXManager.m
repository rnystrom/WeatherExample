//
//  WeatherManager.m
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/9/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"

@interface WXManager ()

@property (nonatomic, strong) WXCondition *currentCondition;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *hourlyForecast;
@property (nonatomic, strong) NSArray *dailyForecast;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end

@implementation WXManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _client = [[WXClient alloc] init];
        
        [[[RACObserve(self, currentLocation)
           // Don't flatten if currenLocation is nil
           ignore:nil]
          // Flatten and subscribe to all 3 signals when currentLocation updates
          flattenMap:^(CLLocation *newLocation) {
              return [RACSignal merge:@[
                                        [self updateCurrentConditions],
                                        [self updateDailyForecast],
                                        [self updateHourlyForecast]
                                        ]];
          }]
         subscribeError:^(NSError *error) {
             NSLog(@"%@",error);
         }];
    }
    return self;
}

#pragma mark - Actions

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        // Store the current condition as a property on our singleton
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        // Store the current condition as a property on our singleton
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        // Store the current condition as a property on our singleton
        self.dailyForecast = conditions;
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Ignore the first update as its usually cached
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        NSLog(@"Updated to location { %f, %f }",location.coordinate.latitude,location.coordinate.longitude);
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

@end
