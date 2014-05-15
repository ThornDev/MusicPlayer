//
//  MjJudgeViewController.m
//  MusicPlayer
//
//  Created by qingyun on 14-5-5.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjJudgeViewController.h"
#import "MJScrollViewController.h"
#import "MjMusicViewController.h"

@interface MjJudgeViewController ()

@end

@implementation MjJudgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([MjStdUsrDefault boolForKey:@"firstLaunch"]) {
        MJScrollViewController *scrollViewController = [[MJScrollViewController alloc]init];
        [self.navigationController pushViewController:scrollViewController animated:YES];
    }else {
        MjMusicViewController *musicViewController = [[MjMusicViewController alloc]init];
        [self.navigationController pushViewController:musicViewController animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
