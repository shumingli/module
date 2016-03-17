//
//  ViewController.h
//  MyPlayer
//
//  Created by mac on 16/3/8.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PVDirection) {
    PVDirectionNone,
    PVDirectionX,  //x方向滑动
    PVDirectionY,  //y方向滑动
} NS_DEPRECATED_IOS(3_2, 9_0) __TVOS_PROHIBITED;

@interface ViewController : UIViewController

@property (nonatomic,strong) NSURL *url;

@end

