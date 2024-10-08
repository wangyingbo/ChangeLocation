//
//  ViewController.m
//  ChangeLocation
//
//  Created by wyb on 2018/1/26.
//  Copyright © 2018年 wyb. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ChangeLoction.h"



#ifndef weakify
#define weakify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(self) __weak_##self##__ = self; \
_Pragma("clang diagnostic pop")
#endif
#ifndef strongify
#define strongify( self ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(self) self = __weak_##self##__; \
_Pragma("clang diagnostic pop")
#endif



@interface ViewController ()<CLLocationManagerDelegate>

@property(nonatomic ,strong) CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet UILabel *location2DLable;
@property (weak, nonatomic) IBOutlet UILabel *locationLable;
@property (nonatomic, strong) CLGeocoder *geoCoder;

@end

@implementation ViewController

#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initLocationManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - initData

- (void)initData {
    //如果要想知道任意位置的坐标
    //1.去高德地图http://lbs.amap.com/console/show/picker，选中自己坐标
    //杭州  120.211963,30.274602
    //奥北中心北区  40.059262,116.409936
    //恒泰中心  39.866242,116.306313
    //石家庄   38.01,114.47
    
    //2.在进行坐标转换
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(39.866242, 116.306313);
    CLLocationCoordinate2D WGSlocation2D = [ChangeLoction gcj02ToWgs84:location2D];
    NSLog(@"转换后的：纬度：%f,经度：%f",WGSlocation2D.latitude , WGSlocation2D.longitude);
    //纬度：30.277029,经度：120.207428
    //3.去Location1.gpx修改经纬度
}

- (void)initLocationManager {
    _manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
//    [self.manager requestAlwaysAuthorization];
    [self.manager requestWhenInUseAuthorization];
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 1.0;
    
    [self.manager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    //1.如果打卡地点是这里，当前的经纬度。
    //2.直接copy下面的经纬度，无需转换
    //3.去Location1.gpx修改经纬度
    //当前的经纬度
    NSLog(@"当前的经纬度 %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    self.location2DLable.text = [NSString stringWithFormat:@"当前  纬度:%f,经度:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    self.location2DLable.textColor = [UIColor blackColor];
    
    //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
    if (!_geoCoder) {
        CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
        _geoCoder = geoCoder;
    }
    
    @weakify(self);
    [self.geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            NSLog(@"错误：%@",error);
        }
        if (placemarks.count >0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (!currentCity) {
                currentCity = @"无法定位当前城市";
            }
            //看需求定义一个全局变量来接收赋值
            NSLog(@"当前国家 - %@",placeMark.country);//当前国家
            NSLog(@"当前城市 - %@",currentCity);//当前城市
            NSLog(@"当前位置 - %@",placeMark.subLocality);//当前位置
            NSLog(@"当前街道 - %@",placeMark.thoroughfare);//当前街道
            NSLog(@"具体地址 - %@",placeMark.name);//具体地址
            self.locationLable.text = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",placeMark.country,currentCity,placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
            self.locationLable.textColor = [UIColor redColor];
            self.locationLable.textAlignment = NSTextAlignmentCenter;
        }
    }];
}
    
    
    
    
    
/**
 
 <wpt lat="39.865161" lon="116.300313">
 <name>恒泰广场</name>
 <time>2018-10-19T08:55:37Z</time>
 </wpt>
 
 <wpt lat="39.865160" lon="116.300314">
 <name>恒泰广场</name>
 <time>2018-10-19T08:56:37Z</time>
 </wpt>
 
 */
    
    
    
@end
