//
//  MjMusicViewController.h
//  MusicPlayer
//
//  Created by qingyun on 14-5-5.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MjMusicViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
{
    NSInteger controlPlayStyle;
    NSInteger controlPlay;
    NSMutableArray *timeArray;
    NSMutableDictionary *LRCDictionary;
    NSUInteger lrcLineNumber;
}

@end
