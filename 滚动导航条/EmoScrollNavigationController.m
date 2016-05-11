//
//  EmoScrollNavigationController.m
//  滚动导航条
//
//  Created by Emo_Lin on 15/1/12.
//  Copyright © 2015年 linweida_emo. All rights reserved.
//

#import "EmoScrollNavigationController.h"
#import "EmoZeroViewController.h"
#import "EmoOneViewController.h"
#import "EmoTwoViewController.h"
#import "EmoThreeViewController.h"
#import "EmoFourViewController.h"
#import "EmoFiveViewController.h"
#import "EmoSixViewController.h"
#import "EmoSevenViewController.h"
#import "EmoEightViewController.h"
#import "EmoNineViewController.h"

static CGFloat const labelWidth = 100;
static CGFloat const radioSize = 1.3;
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface EmoScrollNavigationController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollNavigationView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContentView;
@property (nonatomic, strong) NSMutableArray * subTitleLabel;
@property (weak , nonatomic) UILabel *selectedLabel;
@end

@implementation EmoScrollNavigationController

-(NSMutableArray *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [NSMutableArray array];
    }
    return _subTitleLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpChildViewController];
    [self setupSubViewsTitle];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupScrollViews];
}

/**
 *  添加 ScrollView
 */
-(void)setupScrollViews {
    NSUInteger count = self.childViewControllers.count;
    self.scrollNavigationView.contentSize = CGSizeMake(count * labelWidth, 0);
    self.scrollNavigationView.showsHorizontalScrollIndicator = NO;
    self.scrollContentView.contentSize = CGSizeMake(count * ScreenWidth , 0);
    self.scrollContentView.pagingEnabled = YES;
    self.scrollContentView.showsHorizontalScrollIndicator = NO;
    self.scrollContentView.delegate = self;
}

/**
 *  添加所有子控制器的标题
 */
-(void)setupSubViewsTitle {
    NSUInteger count = self.childViewControllers.count;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelHeight = 64;
    for (int i = 0;  i < count; i++) {
        UIViewController * vc = self.childViewControllers[i];
        UILabel * label = [[UILabel alloc] init];
        labelX = i * labelWidth;
        label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        label.text = vc.title;
        label.highlightedTextColor = [UIColor redColor];
        label.tag = i;
        label.userInteractionEnabled = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [self.subTitleLabel addObject:label];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        if (i == 0) {
            [self  titleClick:tap];
        }
        [self.scrollNavigationView addSubview:label];
    }
}

-(void)titleClick:(UITapGestureRecognizer *)tap {
    UILabel * selectedLabel = (UILabel *)tap.view;
    [self selectedLabelTitle:selectedLabel];
    NSInteger index = selectedLabel.tag;
    CGFloat offsetX = index * ScreenWidth;
    self.scrollContentView.contentOffset = CGPointMake(offsetX, 0);
    [self showViewController:index];
    [self setupTitleCenter:selectedLabel];
}

// 设置标题居中
-(void)setupTitleCenter:(UILabel *)centerLabel {
    CGFloat offsetX = centerLabel.center.x - ScreenWidth * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.scrollNavigationView.contentSize.width - ScreenWidth;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.scrollNavigationView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// 选中的标题变色
-(void)selectedLabelTitle:(UILabel *)label {
    self.selectedLabel.highlighted = NO;
    self.selectedLabel.transform = CGAffineTransformIdentity;
    self.selectedLabel.textColor = [UIColor blackColor];
    label.highlighted = YES;
    label.transform = CGAffineTransformMakeScale(radioSize, radioSize);
    self.selectedLabel = label;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat curPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger leftIndex = curPage;
    NSInteger rightIndex = leftIndex + 1;
    UILabel * leftLabel = self.subTitleLabel[leftIndex];
    UILabel * rightLabel;
    if (rightIndex < self.subTitleLabel.count - 1) {
        rightLabel = self.subTitleLabel[rightIndex];
    }
    CGFloat rightScale = curPage - leftIndex;
    CGFloat leftScale = 1 - rightScale;
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3 + 1);
    rightLabel.transform = CGAffineTransformMakeScale (rightScale * 0.3 + 1 , rightScale * 0.3 + 1);
    leftLabel.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    rightLabel.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
//    CGFloat offsetX = scrollView.contentOffset.x;
    [self showViewController:index];
    UILabel * selectedLabel = self.subTitleLabel[index];
    [self selectedLabelTitle:selectedLabel];
    [self setupTitleCenter:selectedLabel];
}

-(void)showViewController:(NSInteger)index {
    CGFloat offsetX = index * ScreenWidth;
    UIViewController * vc = self.childViewControllers[index];
    if (vc.isViewLoaded) {
        return;
    }
    [self.scrollContentView addSubview:vc.view];
    vc.view.frame = CGRectMake(offsetX, 0, ScreenWidth, ScreenHeight);
}

- (void)setUpChildViewController
{
    // 头条
    EmoZeroViewController *zero = [[EmoZeroViewController alloc] init];
    zero.title = @"第一个";
    [self addChildViewController:zero];
    
    // 热点
    EmoOneViewController *one = [[EmoOneViewController alloc] init];
    one.title = @"第二个";
    [self addChildViewController:one];
    
    // 视频
    EmoTwoViewController *two = [[EmoTwoViewController alloc] init];
    two.title = @"第三个";
    [self addChildViewController:two];
    
    // 社会
    EmoThreeViewController *three = [[EmoThreeViewController alloc] init];
    three.title = @"第四个";
    [self addChildViewController:three];
    
    // 阅读
    EmoFourViewController *four = [[EmoFourViewController alloc] init];
    four.title = @"第五个";
    [self addChildViewController:four];
    
    // 科技
    EmoFiveViewController *five = [[EmoFiveViewController alloc] init];
    five.title = @"第六个";
    [self addChildViewController:five];
    
    // 视频
    EmoSixViewController *six = [[EmoSixViewController alloc] init];
    six.title = @"第七个";
    [self addChildViewController:six];
    
    // 社会
    EmoSevenViewController *seven = [[EmoSevenViewController alloc] init];
    seven.title = @"第八个";
    [self addChildViewController:seven];
    
    // 阅读
    EmoEightViewController *eight = [[EmoEightViewController alloc] init];
    eight.title = @"第九个";
    [self addChildViewController:eight];
    
    // 科技
    EmoNineViewController *nine = [[EmoNineViewController alloc] init];
    nine.title = @"第十个";
    [self addChildViewController:nine];
    
}

@end
