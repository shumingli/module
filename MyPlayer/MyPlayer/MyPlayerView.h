//
//  LookBackView.h
//  sealTime
//
//  Created by mac on 15/12/29.
//  Copyright © 2015年 visalar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@protocol PlayerViewDelegate <NSObject,SCPlayerDelegate>
@required
- (void)pauseBtnClick:(UIButton *)sender;
//- (void)fullScreenClick:(UIButton *)sender;

- (void)startDragSlider:(UISlider *)slider;
- (void)endDragSlider:(UISlider *)slider;
- (void)changeValue:(UISlider *)slider;
- (void)pauClick:(UITapGestureRecognizer *)e;
- (void)touchScreen:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@interface MyPlayerView : UIView{

}
@property (nonatomic,assign) id<PlayerViewDelegate> delegate;
@property (nonatomic,readonly) SCPlayer *player;
@property (nonatomic,readonly) PlayerView *playerView;
@property (nonatomic,readonly) AVPlayerItem *playerItem;
@property (nonatomic,readonly) UISlider *currentProgress;
@property (nonatomic,readonly) UILabel *curTimeLabel;
@property (nonatomic,readonly) UILabel *totalTimeLabel;
@property (nonatomic,readonly) UISlider *loadedProgress;
@property (nonatomic,readonly) UIView *bgView;
@property (nonatomic,readonly) UIView *timeTipView;
@property (nonatomic,readonly) UILabel *speedTime;
@property (nonatomic,readonly) UILabel *cacheTipLabel;

- (id)initWithFrame:(CGRect)frame withUrl:(NSURL *)url;
- (void)changeToPlayBtn;
- (void)changeToPauseBtn;
- (CGFloat)getVolume;
- (void)setVolume:(CGFloat)volume;
- (void)deviceOrientationWithOrientation:(UIDeviceOrientation)orientation withFrame:(CGRect)frame;

@end
