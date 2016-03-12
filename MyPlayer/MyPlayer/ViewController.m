//
//  ViewController.m
//  MyPlayer
//
//  Created by mac on 16/3/8.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"
#import "MyPlayerView.h"

#define SCreenWidth [[UIScreen mainScreen] bounds].size.width
#define SCreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<SCPlayerDelegate,PlayerViewDelegate>{
    MyPlayerView *_myPlayerView;
    NSTimeInterval _totalTime;
    BOOL _startSpeed;  //开始拖动精度条
    BOOL _isPause;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addMyPlayerView];
}

- (void)orientChange:(NSNotification *)noti{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    CGFloat angle = 0.0f;
    switch (orient){
        case UIDeviceOrientationPortrait:{
            angle = 0.0f;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            angle = 0.0f;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:{
            angle = 90.0f;
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            angle = -90.0f;
        }
            break;
        default:
            break;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationCallBack)];
    self.view.transform = CGAffineTransformMakeRotation(angle * (M_PI/180.0f));
    self.view.frame = CGRectMake(0, 0, SCreenWidth, SCreenHeight);
    CGRect rect = CGRectMake(0, 0, SCreenWidth, SCreenHeight);
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight) {
        rect = CGRectMake(0, 0, SCreenHeight, SCreenWidth);
    }
    [_myPlayerView deviceOrientationWithOrientation:orient withFrame:rect];
    [UIView commitAnimations];
}

- (void)endAnimationCallBack{

}
//AVPlayerItemDidPlayToEndTimeNotification
- (void)addMyPlayerView{
    self.url = [NSURL URLWithString:@"http://7xj11m.com1.z0.glb.clouddn.com/2016-01-16_569a131f0d3e8.mp4"];
    
    _myPlayerView = [[MyPlayerView alloc] initWithFrame:CGRectMake(0, 0, SCreenWidth, SCreenHeight) withUrl:self.url];
    _myPlayerView.delegate = self;
    [self.view addSubview:_myPlayerView];
    
    [_myPlayerView.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [_myPlayerView.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
}

//视频总时间
- (CGFloat)getTotalSecond{
    CGFloat totalSecond =  CMTimeGetSeconds(_myPlayerView.playerItem.duration);
    return totalSecond;
}
//当前播放时间
- (CGFloat)getCurrentSecond{
    CGFloat currentSecond = CMTimeGetSeconds(_myPlayerView.playerItem.currentTime);
    return currentSecond;
}
//计算缓冲
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_myPlayerView.playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
    Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            _totalTime = [self getTotalSecond];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"loadedTimeRanges:%f",timeInterval);
        NSTimeInterval totalInterval = [self getTotalSecond];
        [_myPlayerView.loadedProgress setValue:timeInterval/totalInterval animated:YES];
    }
}

- (NSString *)convertTime:(NSInteger)second{
    if (second < 0) {
        second = 0;
    }
    NSInteger seconds = second % 60;
    NSInteger minutes = (second / 60) % 60;
    NSInteger hours = second / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}
#pragma 协议方法
- (void)setPlayerSeekToTime{
    CMTime time = _myPlayerView.playerItem.currentTime;
    NSTimeInterval secondScale = _totalTime * _myPlayerView.currentProgress.value;
    _myPlayerView.curTimeLabel.text = [NSString stringWithFormat:@"%@",[self convertTime:secondScale]];
    CMTimeValue value = time.timescale * secondScale;
    time.value = value;

    [_myPlayerView.playerItem seekToTime:time];
}
- (void)pauseBtnClick:(UIButton *)sender{
    [self checkPauseOrPlay];
}
- (void)startDragSlider:(UISlider *)slider{
    _startSpeed = YES;
    if (!_isPause) { //判断是否在暂停状态
        [_myPlayerView.player pause];
    }
    
}
//快进
- (void)changeValue:(UISlider *)slider{
    [self setPlayerSeekToTime];
}
- (void)endDragSlider:(UISlider *)slider{
    _startSpeed = NO;
    if (!_isPause) {
        [_myPlayerView.player play];
    }
}
- (void)checkPauseOrPlay{
    if ([_myPlayerView.player isPlaying]) {
        [_myPlayerView.player pause];
        [_myPlayerView changeToPlayBtn];
        _isPause = YES;
    }else{
        [_myPlayerView.player play];
        [_myPlayerView changeToPauseBtn];
        _isPause = NO;
    }
}
//点击屏幕暂停或播放
- (void)pauClick:(UITapGestureRecognizer *)e{
    [self checkPauseOrPlay];
}
- (void)player:(SCPlayer*)player didPlay:(CMTime)currentTime loopsCount:(NSInteger)loopsCount{
    CGFloat currentSecond = [self getCurrentSecond];
    CGFloat totalSecond = [self getTotalSecond];
    _myPlayerView.curTimeLabel.text = [NSString stringWithFormat:@"%@",[self convertTime:currentSecond]];
    _myPlayerView.totalTimeLabel.text = [NSString stringWithFormat:@"%@",[self convertTime:totalSecond]];
    if (!_startSpeed) {
        CGFloat progress = currentSecond/totalSecond;
        _myPlayerView.currentProgress.value = progress;
    }
}
- (void)player:(SCPlayer *)player didChangeItem:(AVPlayerItem*)item{

}
//播放结束回调
- (void)player:(SCPlayer *)player didReachEndForItem:(AVPlayerItem *)item{
    [_myPlayerView changeToPlayBtn];
    [_myPlayerView.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
