//
//  WeatherManager.m
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/9/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "WeatherManager.h"
#import "CurrentCondition.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WeatherManager ()

@property (nonatomic, strong) CurrentCondition *currentCondition;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WeatherManager

+ (instancetype)shareManager {
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
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
        
        [[RACObserve(self, currentLocation)
         filter:^BOOL(CLLocation *newLocation) {
             return newLocation != nil;
         }] subscribeNext:^(CLLocation *newLocation) {
             [[RACSignal merge:@[[self fetchCurrentConditions], [self fetchDailyForecast], [self fetchHourlyForecast]]] subscribeError:^(NSError *error) {
                 NSLog(@"%@",error.localizedDescription);
             }];
         }];
    }
    return self;
}

#pragma mark - Actions

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                }
            }
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (RACSignal *)fetchCurrentConditions {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] doNext:^(NSDictionary *json) {
        self.currentCondition = [MTLJSONAdapter modelOfClass:[CurrentCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecast {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] logNext];
}

- (RACSignal *)fetchDailyForecast {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] logNext];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        NSLog(@"Updated to location { %f, %f }",location.coordinate.latitude,location.coordinate.longitude);
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
        [self fetchCurrentConditions];
    }
}

@end
