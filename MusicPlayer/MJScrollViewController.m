//
//  MJScrollViewController.m
//  UICataSample
//
//  Created by qingyun on 14-5-1.
//  Copyright (c) 2014年 马到成功. All rights reserved.
//

#import "MJScrollViewController.h"
#import "MjMusicViewController.h"


@interface MJScrollViewController ()
@property (nonatomic,retain)UIScrollView *scrollView;
@end

@implementation MJScrollViewController

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
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.directionalLockEnabled  =YES;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 5, self.view.bounds.size.height);
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _scrollView.minimumZoomScale = 0.25;
    _scrollView.maximumZoomScale = 1;
    
    for (int index = 1; index < 6; index ++) {
        NSString *imageName = [NSString stringWithFormat:@"music%d.jpg",index];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width * (index -1), 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        imageView.image = [UIImage imageNamed:imageName];
        [self.scrollView addSubview:imageView];
    }
    
    UIPageControl *pageController = [[UIPageControl alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height - 30, 220, 30)];
    pageController.numberOfPages = 5;
    pageController.tag = 10001;
    pageController.pageIndicatorTintColor = [UIColor grayColor];
    pageController.currentPageIndicatorTintColor = [UIColor blackColor];
    [pageController addTarget:self action:@selector(onPageControl:) forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:pageController];
    
    
}


//在这里可以设置滑动视图来改变page的值，以达到同步
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSString *strOffSet = NSStringFromCGPoint(scrollView.contentOffset);
//    
    NSInteger page = scrollView.contentOffset.x/scrollView.bounds.size.width;
    UIPageControl *pageCtrl = (UIPageControl *)([self.view viewWithTag:10001]);
    [pageCtrl setCurrentPage:page];
    
    if ((scrollView.contentOffset.x -320*4) >80) {
        MjMusicViewController *musicViewController = [[MjMusicViewController alloc]init];
        [self.navigationController pushViewController:musicViewController animated:YES];
    }
}
//通过page来切换视图
- (void)onPageControl:(UIPageControl *)sender
{
//    UIPageControl *pageChange = (UIPageControl *)sender;
    
//    在这里拿到page改变的值
    NSInteger pageValue = sender.currentPage;
//    在这里是设置了一个坐标值，用当前page的值乘以每个页面的宽度作为点击page页面切换的大小
    CGPoint offSetPoint = CGPointMake(pageValue * 320, 0);
//  将设置的坐标值传给scrollView，用于显示切换后的页面
    [self.scrollView setContentOffset:offSetPoint animated:YES];
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
