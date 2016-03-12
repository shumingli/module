//
//  LookBackView.m
//  sealTime
//
//  Created by mac on 15/12/29.
//  Copyright © 2015年 visalar. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MyPlayerView.h"

#define SCreenWidth [[UIScreen mainScreen] bounds].size.width
#define SCreenHeight [[UIScreen mainScreen] bounds].size.height
#define BTN_WIDTH 35
#define BTN_HEIGHT 35

@interface MyPlayerView() {
    UIButton *_pauseBtn;
    UIView *_tapView;
    UIImageView *_playImgView;
    
    PlayerView *_playerView;
    NSString *_totalTime;
    
    UITapGestureRecognizer *tap;
    
    UILabel *_line;
    UIView *_coverView;
    UIVisualEffectView *_visualEffectView;
}

@end

@implementation MyPlayerView

- (id)initWithFrame:(CGRect)frame withUrl:(NSURL *)url{
    if (self = [super initWithFrame:frame]) {
        [self addItemsWithUrl:url];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withUrl:(NSURL *)url withDelegate:(id<PlayerViewDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        [self addItemsWithUrl:url];
    }
    return self;
}

- (void)addBgView{
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_bgView];
}

- (void)addCoverView{
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
    [_coverView addSubview:_visualEffectView];
    [self addSubview:_coverView];
}

- (void)addItemsWithUrl:(NSURL *)url{
    self.backgroundColor = [UIColor darkGrayColor];
    [self addCoverView];
    
    [self addBgView];
    [self addPlayerWithUrl:url];
    [self addUI];
}

- (void)addUI{
    [self addPauseBtn];
    [self addTimeLabel];
    [self addProgressView];
    [self addSliderView];
    [self addGenstureRec];

    [self addBigPlay];
    
    [self addSpeedTimeTip];
    
    [self addCacheTipLabel];
}
- (void)addCacheTipLabel{
    _cacheTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _cacheTipLabel.font=[UIFont boldSystemFontOfSize:12];
    _cacheTipLabel.textColor = [UIColor whiteColor];
    _cacheTipLabel.text = @"正在缓冲,请稍后...";
    _cacheTipLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:_cacheTipLabel];
    _cacheTipLabel.hidden = YES;
}

- (void)addSpeedTimeTip{
    CGSize size = CGSizeMake(100, 40);
    _timeTipView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-size.width)/2.0, (self.frame.size.height-size.height)/2-100, size.width, size.height)];
    _timeTipView.alpha = 0.5;
    _timeTipView.layer.cornerRadius = 8.0f;
    _timeTipView.backgroundColor = [UIColor blackColor];
    [_bgView addSubview:_timeTipView];
    
    _speedTime=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _speedTime.font=[UIFont boldSystemFontOfSize:16];
    _speedTime.textColor = [UIColor whiteColor];
    _speedTime.text = @"00:00:00";
    _speedTime.textAlignment = NSTextAlignmentCenter;
    [_timeTipView addSubview:_speedTime];
    _timeTipView.hidden = YES;
}

- (void)addBigPlay{
    UIImage *img = [UIImage imageNamed:@"Play—button.png"];
    _playImgView = [[UIImageView alloc] initWithImage:img];
    _playImgView.frame = CGRectMake((self.frame.size.width-img.size.width)/2, (self.frame.size.height-img.size.height)/2, img.size.width, img.size.height);
    [_bgView addSubview:_playImgView];
    _playImgView.hidden = YES;
}

- (void)addTimeLabel{
//    UILabel *line =[[UILabel alloc]initWithFrame:CGRectMake(_curTimeLabel.frame.origin.x+_curTimeLabel.frame.size.width,_curTimeLabel.frame.origin.y,5,height)];
//    line.text=@"/";
//    line.backgroundColor = [UIColor clearColor];
//    line.textColor = [UIColor whiteColor];
//    line.textAlignment = NSTextAlignmentCenter;
//    line.font=[UIFont boldSystemFontOfSize:10];
//    [_bgView addSubview:line];
//    _line = line;
    [self addCurTimeLabel];
    [self addTotalTimeLabel];
}

- (void)addCurTimeLabel{
    CGFloat width = 50;
    CGFloat height = 12;
    
    _curTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_pauseBtn.frame.origin.x+_pauseBtn.frame.size.width+10,_pauseBtn.frame.origin.y+(_pauseBtn.frame.size.height-height)/2,width,height)];
    _curTimeLabel.text=@"00:00:00";
    _curTimeLabel.backgroundColor = [UIColor clearColor];
    _curTimeLabel.textColor =  [UIColor whiteColor];
    _curTimeLabel.textAlignment = NSTextAlignmentLeft;
    _curTimeLabel.font=[UIFont boldSystemFontOfSize:10];
    [_bgView addSubview:_curTimeLabel];
}
- (void)addTotalTimeLabel{
    _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCreenWidth-_curTimeLabel.frame.size.width-10,_curTimeLabel.frame.origin.y,_curTimeLabel.frame.size.width,_curTimeLabel.frame.size.height)];
    _totalTimeLabel.text=@"00:00:00";
    _totalTimeLabel.backgroundColor = [UIColor clearColor];
    _totalTimeLabel.textColor = [UIColor whiteColor];;
    _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    _totalTimeLabel.font=[UIFont boldSystemFontOfSize:10];
    [_bgView addSubview:_totalTimeLabel];
}

- (void)addPauseBtn{
    UIImage *norImage = [UIImage imageNamed:@"Pause"];
    UIImage *selImage = [UIImage imageNamed:@"Pause"];
    
    _pauseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _pauseBtn.frame=CGRectMake(20, SCreenHeight-25-norImage.size.width,norImage.size.width,norImage.size.height);
    [_pauseBtn setImage:norImage forState:UIControlStateNormal];
    [_pauseBtn setImage:selImage forState:UIControlStateHighlighted];
    [_pauseBtn addTarget:_delegate action:@selector(pauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_pauseBtn];
}
- (void)addProgressView{
    CGRect curTimeFrame = _curTimeLabel.frame;
    CGFloat offsetX = curTimeFrame.origin.x + curTimeFrame.size.width;
    CGFloat width = _totalTimeLabel.frame.origin.x - offsetX-10;
    CGRect rect = CGRectMake(offsetX, curTimeFrame.origin.y-8, width, 30);
    _loadedProgress = [[UISlider alloc] initWithFrame:rect];
    _loadedProgress.maximumTrackTintColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:0.98];
    _loadedProgress.minimumTrackTintColor  = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:0.98];
    _loadedProgress.thumbTintColor = [UIColor clearColor];
    [_loadedProgress setThumbImage:[UIImage imageNamed:@"null.png"] forState:UIControlStateNormal];
    [_bgView addSubview:_loadedProgress];
}
- (void)addSliderView{
    _currentProgress = [[UISlider alloc] initWithFrame:_loadedProgress.frame];
    _currentProgress.minimumTrackTintColor = [UIColor colorWithRed:238/255.0 green:174/255.0 blue:14/255.0 alpha:0.98];
    _currentProgress.maximumTrackTintColor = [UIColor clearColor];
    _currentProgress.thumbTintColor = [UIColor clearColor];
     
    [_currentProgress setThumbImage:[UIImage imageNamed:@"Circles"] forState:UIControlStateNormal];
    [_currentProgress setThumbImage:[UIImage imageNamed:@"Circles"] forState:UIControlStateSelected];
    [_currentProgress setThumbImage:[UIImage imageNamed:@"Circles"] forState:UIControlStateHighlighted];
    [_currentProgress addTarget:_delegate action:@selector(startDragSlider:) forControlEvents:UIControlEventTouchDown];
    [_currentProgress addTarget:_delegate action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [_currentProgress addTarget:_delegate action:@selector(endDragSlider:) forControlEvents:UIControlEventTouchUpInside];
    [_currentProgress addTarget:_delegate action:@selector(endDragSlider:) forControlEvents:UIControlEventTouchUpOutside];

    [_bgView addSubview:_currentProgress];
}

- (void)addGenstureRec{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, self.frame.size.height-200)];
    v.backgroundColor = [UIColor clearColor];
    [_bgView addSubview:v];
    _tapView = v;

    tap = [[UITapGestureRecognizer alloc] init];
    [v addGestureRecognizer:tap];
}

- (void)changeToPlayBtn{
    UIImage *norImage = [UIImage imageNamed:@"Play"];
    UIImage *selImage = [UIImage imageNamed:@"Play"];
    [_pauseBtn setImage:norImage forState:UIControlStateNormal];
    [_pauseBtn setImage:selImage forState:UIControlStateHighlighted];
    
    _playImgView.hidden = NO;
}
- (void)changeToPauseBtn{
    UIImage *norImage = [UIImage imageNamed:@"Pause"];
    UIImage *selImage = [UIImage imageNamed:@"Pause"];
    [_pauseBtn setImage:norImage forState:UIControlStateNormal];
    [_pauseBtn setImage:selImage forState:UIControlStateHighlighted];
    
    _playImgView.hidden = YES;
}

- (void)setDelegate:(id<PlayerViewDelegate>)delegate{
    _delegate = delegate;
    _player.delegate = delegate;
  
    [tap addTarget:_delegate action:@selector(pauClick:)];
}

#pragma 播放器 start

- (void)addPlayerWithUrl:(NSURL *)url{
    //创建视频播放器
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [SCPlayer player];
    [_player setItem:_playerItem];
    _player.loopEnabled = NO;
    _playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_playerView setPlayer:_player];
    [_bgView addSubview:_playerView];
    _player.delegate = _delegate;
    [_player beginSendingPlayMessages];
    [_player play];
}

#pragma 播放器 end

- (void)deviceOrientationWithOrientation:(UIDeviceOrientation)orientation withFrame:(CGRect)frame{
    
    CGSize size = frame.size;

    self.frame = CGRectMake(0, 0, size.width, size.height);
    
    _coverView.frame = CGRectMake(0, 0, size.width, size.height);
    _visualEffectView.frame = CGRectMake(0, 0, size.width, size.height);
    
    _playerView.frame = CGRectMake(0, 0, size.width, size.height);
    _bgView.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGRect rect1 = _pauseBtn.frame;
    _pauseBtn.frame = CGRectMake(10,size.height - 10 -rect1.size.height ,rect1.size.width,rect1.size.height);
    
    _tapView.frame = CGRectMake(0, 100, size.width, size.height-200);
    CGRect prect = _playImgView.frame;
    _playImgView.frame = CGRectMake((size.width-prect.size.width)/2, (size.height-prect.size.height)/2, prect.size.width, prect.size.height);
    
    _curTimeLabel.frame = CGRectMake(_pauseBtn.frame.origin.x+_pauseBtn.frame.size.width+10,_pauseBtn.frame.origin.y+(_pauseBtn.frame.size.height-_curTimeLabel.frame.size.height)/2,_curTimeLabel.frame.size.width,_curTimeLabel.frame.size.height);
     _totalTimeLabel.frame = CGRectMake(size.width-_curTimeLabel.frame.size.width-10,_curTimeLabel.frame.origin.y,_curTimeLabel.frame.size.width,_curTimeLabel.frame.size.height);
   
    CGRect curTimeFrame = _curTimeLabel.frame;
    CGFloat offsetX = curTimeFrame.origin.x + curTimeFrame.size.width;
    CGFloat width = _totalTimeLabel.frame.origin.x - offsetX-10;
    CGRect rect = CGRectMake(offsetX, curTimeFrame.origin.y-8, width, 30);
    
    _loadedProgress.frame = rect; //loadedProgress
    _currentProgress.frame = _loadedProgress.frame;
    
   


    _timeTipView.frame = CGRectMake((size.width-_timeTipView.frame.size.width)/2.0, (size.height-_timeTipView.frame.size.height)/2-100, _timeTipView.frame.size.width, _timeTipView.frame.size.height);
    _cacheTipLabel.frame = CGRectMake(0, 0, size.width, size.height);
    
}


@end
