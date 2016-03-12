//
//  PlayerView.h
//  sealTime
//
//  Created by mac on 15/12/30.
//  Copyright © 2015年 visalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPlayer.h"

@interface PlayerView : UIView{

}

@property (nonatomic ,strong) SCPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@end
