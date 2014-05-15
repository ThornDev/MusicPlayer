//
//  MjMusicViewController.m
//  MusicPlayer
//
//  Created by qingyun on 14-5-5.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjMusicViewController.h"
#import "DXSemiViewControllerCategory.h"
#import <AVFoundation/AVFoundation.h>

#define kLrcTableView 10001
//#define kPlaySequent 1;
//#define kPlayRandom 2;
//#define kPlayCircle 3;

static NSString *songIdentify = @"songIdentify";
@interface MjMusicViewController ()

@property (retain, nonatomic) IBOutlet UIView *controlView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,retain)AVAudioPlayer *audioPlayer;
@property (retain, nonatomic) IBOutlet UIButton *songBtn;
@property (retain, nonatomic) IBOutlet UIButton *playStyleBtn;
@property (retain, nonatomic) IBOutlet UISlider *sliderProgress;
@property (retain, nonatomic) IBOutlet UIButton *controlBtn;
@property (retain, nonatomic) IBOutlet UIButton *priorSongBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextSongBtn;
@property (retain, nonatomic) IBOutlet UILabel *labelAllTime;
@property (retain, nonatomic) IBOutlet UILabel *labelProgressTime;
@property (retain, nonatomic) IBOutlet UISlider *sliderVolume;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel;
@property (retain, nonatomic) IBOutlet UITableView *lrcTableView;


@property (nonatomic,retain)NSArray *songsDataSource;
@property (nonatomic,assign)NSInteger musicNum;
@property (nonatomic,retain)NSString *currentSong;
@property (nonatomic ,retain)UITableView *songTableView;
@property (nonatomic,retain)NSURL *soundURL;



@end


@implementation MjMusicViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.songsDataSource = @[@"光辉岁月",@"Never Give Up",@"怒放的生命",@"你给我听好",@"You Belong With Me",@"Stay Beautiful",@"我只在乎你",@"泡沫"];
       

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    controlPlayStyle = 2;
    controlPlay = 1;
    self.controlView.alpha = 0.6f;
    self.controlView.backgroundColor = [UIColor lightGrayColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBarHidden = YES;
    
    self.imageView.animationImages = @[[UIImage imageNamed:@"scene1.jpg"],
                                       [UIImage imageNamed:@"scene2.jpg"],
                                       [UIImage imageNamed:@"scene3.jpg"],
                                       [UIImage imageNamed:@"scene4.jpg"],
                                       [UIImage imageNamed:@"scene5.jpg"],
                                       ];

    self.imageView.animationDuration = 20.0;
    [self.imageView stopAnimating];
    [self.view addSubview:self.imageView];
    [self.imageView addSubview:self.songNameLabel];
    [self.imageView addSubview:self.labelProgressTime];
    [self.imageView addSubview:self.labelAllTime];
    [self.imageView addSubview:self.sliderProgress];
    [self.imageView addSubview:self.controlView];
    [self.imageView addSubview:self.lrcTableView];
    
//   为了显示歌词

    self.lrcTableView.tag = 10001;
    self.lrcTableView.backgroundColor = [UIColor clearColor];
    self.lrcTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.lrcTableView.dataSource = self;
    self.lrcTableView.delegate =self;
    lrcLineNumber = 0;
    
    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
//    初始化歌词
    [self initLRC];

    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(onTimer:)
                                   userInfo:nil repeats:YES];
    self.soundURL = [[NSBundle mainBundle] URLForResource:@"光辉岁月" withExtension:@"mp3"];
    self.musicNum = 0;
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:self.soundURL error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = 0;
    
    if (nil != error) {
        NSLog(@"Error:%@",error);
    }
    
    [self.audioPlayer prepareToPlay];
    
    [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"play"]
                               forState:UIControlStateNormal];
    [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_orderplay"]
                                 forState:UIControlStateNormal];
    self.songNameLabel.text = @"光辉岁月";
    
//    初始化Slider
    self.sliderProgress.minimumValue = 0.0;
    self.sliderProgress.maximumValue = self.audioPlayer.duration;
    [self.sliderProgress setThumbImage:[UIImage imageNamed:@"mv_voiceSliderThumb"] forState:UIControlStateNormal];
    [self.sliderVolume setThumbImage:[UIImage imageNamed:@"mv_voiceSliderThumb"] forState:UIControlStateNormal];
    //格式化label显示时间
    [self ruleTimeLabel:self.labelAllTime andTime:self.audioPlayer.duration];

    //添加UISongTableView
    CGRect songTableFrame = CGRectMake(320, 50, 300, 430);
    self.songTableView = [[UITableView alloc ]initWithFrame:songTableFrame
                                                      style:UITableViewStylePlain];
    self.songTableView.alpha = 0.6f;
    self.songTableView.dataSource = self;
    self.songTableView.delegate = self;
    [self.songTableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:songIdentify];
    
//    添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc ]
                                          initWithTarget:self
                                          action:@selector(onSingleTap:)];
    //    表示多点触摸时的手指数量
    tapGesture.numberOfTouchesRequired = 1;
    //    表示轻拍的次数，现在一个手指轻拍一次，也就是单击的动作
    tapGesture.numberOfTapsRequired = 1;
    //    为视图view添加上手势的动作处理
    [self.imageView addGestureRecognizer:tapGesture];
    

    
}

#pragma mark - 
#pragma mark dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kLrcTableView) {
        return timeArray.count;
    }else{
        return self.songsDataSource.count;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LRCCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableView.tag == kLrcTableView) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//该表格选中后没有颜色
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.row == lrcLineNumber) {
            cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
            cell.textLabel.textColor = [UIColor orangeColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        } else {
            cell.textLabel.text = LRCDictionary[timeArray[indexPath.row]];
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.text = self.songsDataSource[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
    }

    
    return cell;
    
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}



#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kLrcTableView) {
        
    }else{
    self.currentSong = self.songsDataSource[indexPath.row];
    self.musicNum = indexPath.row;
    [self initLRC];
    self.songNameLabel.text = self.songsDataSource[indexPath.row];
    self.soundURL = [[NSBundle mainBundle] URLForResource:self.currentSong withExtension:@"mp3"];
    
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        [self changeSongs];
        [self.audioPlayer play];
            }
    else
    {
        [self changeSongs];
        [self.audioPlayer play];
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"pause"]
                                   forState:UIControlStateNormal];
    }
    }
  
    
}


#pragma mark -
#pragma mark AVAudioPlayer Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

//    if (!controlPlayStyle) {
//        [self sequencePlay];
//        self.audioPlayer.delegate = self;
//        [self.audioPlayer play];
//    }else{
//        [self randomPlay];
//        self.audioPlayer.delegate = self;
//        [self.audioPlayer play];
//    }
    switch (controlPlay) {
        case 1:
            [self sequencePlay];
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
            break;
        case 2:
            [self randomPlay];
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
            break;
        case 3:
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.delegate = self;
            [self.audioPlayer play];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark 方法回调

- (void)onTimer:(NSTimer *)timer
{
    self.sliderProgress.value = self.audioPlayer.currentTime;
    [self ruleTimeLabel:self.labelProgressTime andTime:self.audioPlayer.currentTime];
//调用歌词函数
    [self displaySondWord:self.audioPlayer.currentTime];
}

- (IBAction)sliderProgressBtn:(UISlider *)sender {
    self.audioPlayer.currentTime = self.sliderProgress.value;
    self.sliderProgress.value =sender.value;
}

- (IBAction)onSliderVolumeBtn:(UISlider*)sender {
    self.audioPlayer.volume = sender.value;
}

//播放暂停控制按钮
- (IBAction)onControlBtn:(id)sender {
    if ([self.audioPlayer isPlaying]) {
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"play"]
                                   forState:UIControlStateNormal];
        [self.audioPlayer pause];
    }else{
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"pause"]
                                   forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
}

//得到歌曲列表
- (IBAction)onSongsBtn:(id)sender {
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2];
    CGRect frame = self.songTableView.frame;
    frame.origin.x = 80;
    self.songTableView.frame = frame;
    [self.view addSubview:self.songTableView];
    [UIView commitAnimations];
   
}

//上一首歌
- (IBAction)onPriorBtn:(id)sender {
    if (self.musicNum == 0) {
        self.musicNum = self.songsDataSource.count - 1;
        [self changeToPlay];
    }else{
        self.musicNum -= 1;
        [self changeToPlay];
        
    }

}

//下一首歌
- (IBAction)onNextBtn:(id)sender {
    if (self.musicNum == self.songsDataSource.count - 1) {
        self.musicNum = 0;
        [self changeToPlay];
    }else{
        self.musicNum += 1;
        [self changeToPlay];

    }
    NSLog(@"%d",self.musicNum);
}

//随机播放
- (IBAction)onSongRudomBtn:(id)sender {
//    if (controlPlayStyle == 2) {
//        controlPlayStyle = YES;
//        [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_randplay"]
//                                         forState:UIControlStateNormal];
//    }else if(controlPlayStyle == 3)
//    {
//        controlPlayStyle = NO;
//        [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_orderplay"]
//                                     forState:UIControlStateNormal];
//    }
    switch (controlPlayStyle) {
        case 1:
            [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_orderplay"]
                                         forState:UIControlStateNormal];
            controlPlay = 1;
            controlPlayStyle = 2;
            break;
        case 2:
            [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_randplay"]
                                         forState:UIControlStateNormal];
            controlPlay = 2;
            controlPlayStyle = 3;
            break;
        case 3:
            [self.playStyleBtn setBackgroundImage:[UIImage imageNamed:@"mode_repeatlist"]
                                         forState:UIControlStateNormal];
            controlPlay = 3;
            controlPlayStyle = 1;
            break;
        default:
            break;
    }
}


//手势
- (void)onSingleTap:(UITapGestureRecognizer *)singleTap
{
    [self.songTableView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imageView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.imageView stopAnimating];
}

//顺序播放
- (void)sequencePlay
{

        if (self.musicNum == self.songsDataSource.count - 1) {
            self.musicNum = 0;
            [self changeToPlay];
           
        }else{
            self.musicNum += 1;
            [self changeToPlay];
            
        }
    
}

//随机播放
- (void)randomPlay
{
//    if (self.audioPlayer.currentTime >= self.audioPlayer.duration-1.05) {
        NSInteger number = arc4random()%self.songsDataSource.count;
        self.musicNum = number;
        [self changeToPlay];
   
    
}

//切歌播放
- (void)changeToPlay
{
    self.currentSong = self.songsDataSource[self.musicNum];
    self.soundURL =[[NSBundle mainBundle] URLForResource:self.currentSong withExtension:@"mp3"];
    timeArray = [[NSMutableArray alloc] initWithCapacity:10];
    LRCDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self initLRC];
    self.songNameLabel.text = self.songsDataSource[self.musicNum];
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        [self changeSongs];
        [self.audioPlayer play];
    }else{
        [self changeSongs];
    }
    self.audioPlayer.delegate = self;
    
}


//切歌
- (void)changeSongs
{
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:self.soundURL
                                                             error:&error];

    [self ruleTimeLabel:self.labelAllTime andTime:self.audioPlayer.duration];
    self.sliderProgress.minimumValue = 0.0;
    self.sliderProgress.maximumValue = self.audioPlayer.duration;
    if (nil != error) {
        NSLog(@"Error:%@",error);
    }
    
    [self.audioPlayer prepareToPlay];
    
}

//时间格式
- (void)ruleTimeLabel:(UILabel *)label andTime:(float)time
{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"mm:ss"];
    
    label.text = [date stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    
}

#pragma mark 得到歌词
- (void)initLRC {
    NSString *LRCPath = [[NSBundle mainBundle] pathForResource:self.songsDataSource[self.musicNum] ofType:@"lrc"];
    NSString *contentStr = [NSString stringWithContentsOfFile:LRCPath encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"contentStr = %@",contentStr);
    NSArray *array = [contentStr componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [array count]; i++) {
        NSString *linStr = [array objectAtIndex:i];
        NSArray *lineArray = [linStr componentsSeparatedByString:@"]"];
        if ([lineArray[0] length] > 8) {
            NSString *str1 = [linStr substringWithRange:NSMakeRange(3, 1)];
            NSString *str2 = [linStr substringWithRange:NSMakeRange(6, 1)];
            if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                NSString *lrcStr = [lineArray objectAtIndex:1];
                NSString *timeStr = [[lineArray objectAtIndex:0] substringWithRange:NSMakeRange(1, 5)];//分割区间求歌词时间
                //把时间 和 歌词 加入词典
                [LRCDictionary setObject:lrcStr forKey:timeStr];
                [timeArray addObject:timeStr];//timeArray的count就是行数
            }
        }
    }
}
#pragma mark 动态显示歌词
- (void)displaySondWord:(NSUInteger)time {
    //    NSLog(@"time = %u",time);
    for (int i = 0; i < [timeArray count]; i++) {
        
        NSArray *array = [timeArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        if (i == [timeArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [timeArray[timeArray.count-1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            if (time > currentTime1) {
                [self updateLrcTableView:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [timeArray[0] componentsSeparatedByString:@":"];
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < currentTime2) {
                [self updateLrcTableView:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [timeArray[i+1] componentsSeparatedByString:@":"];
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime3) {
                [self updateLrcTableView:i];
                break;
            }
            
        }
    }
}

#pragma mark 动态更新歌词表歌词
- (void)updateLrcTableView:(NSUInteger)lineNumber {
    //    NSLog(@"lrc = %@", [LRCDictionary objectForKey:[timeArray objectAtIndex:lineNumber]]);
    //重新载入 歌词列表lrcTabView
    lrcLineNumber = lineNumber;
    [self.lrcTableView reloadData];
    //使被选中的行移到中间
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lineNumber inSection:0];
    [self.lrcTableView selectRowAtIndexPath:indexPath
                                   animated:YES
                             scrollPosition:UITableViewScrollPositionMiddle];
    //    NSLog(@"%i",lineNumber);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
