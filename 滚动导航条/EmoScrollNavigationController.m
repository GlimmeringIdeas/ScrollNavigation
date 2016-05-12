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
#import "EmoConst.h"
static CGFloat const labelWidth = 100;
// 修改文字显示的比例
static CGFloat const radioSize = 0.6;


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
 *  添加 ScrollView，布局contentSize的尺寸和状态
 */
-(void)setupScrollViews {
    NSUInteger count = self.childViewControllers.count;
    self.scrollNavigationView.contentSize = CGSizeMake(count * labelWidth, 0);
    self.scrollNavigationView.showsHorizontalScrollIndicator = NO;
    self.scrollContentView.contentSize = CGSizeMake(count * ScreenWidth , 0);
    self.scrollContentView.pagingEnabled = YES;
    self.scrollContentView.bounces = NO;
    self.scrollContentView.showsHorizontalScrollIndicator = NO;
    self.scrollContentView.delegate = self;
}

/**
 *  添加所有子控制器的标题，创建label 并给 label 添加点击事件
 */
-(void)setupSubViewsTitle {
    NSUInteger count = self.childViewControllers.count;
    CGFloat labelX = 0;
    CGFloat labelY = 20;
    CGFloat labelHeight = 44;
    for (int i = 0;  i < count; i++) {
        UIViewController * vc = self.childViewControllers[i];
        UILabel * label = [[UILabel alloc] init];
        labelX = i * labelWidth;
        label.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        label.text = vc.title;
        label.textColor = [UIColor whiteColor];
        label.highlightedTextColor = RandColor;
        label.font = [UIFont systemFontOfSize:14];
        label.tag = i;
        label.userInteractionEnabled = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [self.subTitleLabel addObject:label];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        if (i == 0) {
            [self  titleClick:tap];
        }
        [self.scrollNavigationView addSubview:label];
    }
}

/**
 *  设置选中状态下的标题居中
 */
-(void)setupTitleCenter:(UILabel *)centerLabel {
    // 中间label的x值 = 传进来中间label的x值 - 屏幕宽度的一半
    CGFloat offsetX = centerLabel.center.x - ScreenWidth * 0.5;
    if (offsetX < 0) {  // 如果计算完之后是负数，证明
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.scrollNavigationView.contentSize.width - ScreenWidth;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.scrollNavigationView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

/**
 *  实现点击事件的方法
 */
-(void)titleClick:(UITapGestureRecognizer *)tap {
    UILabel * selectedLabel = (UILabel *)tap.view;
    [self selectedLabelTitle:selectedLabel];
    NSInteger index = selectedLabel.tag;
    CGFloat offsetX = index * ScreenWidth;
    self.scrollContentView.contentOffset = CGPointMake(offsetX, 0);
    [self showViewController:index];
    [self setupTitleCenter:selectedLabel];
}


/**
 *  设置选中 label 的颜色
 */
-(void)selectedLabelTitle:(UILabel *)label {
    self.selectedLabel.highlighted = NO;
    self.selectedLabel.transform = CGAffineTransformIdentity;
    self.selectedLabel.textColor = [UIColor whiteColor];
    label.highlighted = YES;
    // 设置初始化时，按钮的尺寸
    label.transform = CGAffineTransformMakeScale(radioSize+1, radioSize+1);
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
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * radioSize + 1, leftScale * radioSize + 1);
    rightLabel.transform = CGAffineTransformMakeScale (rightScale * radioSize + 1 , rightScale * radioSize + 1);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
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
    EmoZeroViewController *zero = [[EmoZeroViewController alloc] init];
    zero.title = @"第一个";
    [self addChildViewController:zero];
    
    EmoOneViewController *one = [[EmoOneViewController alloc] init];
    one.title = @"第二个";
    [self addChildViewController:one];
    
    EmoTwoViewController *two = [[EmoTwoViewController alloc] init];
    two.title = @"第三个";
    [self addChildViewController:two];
    
    EmoThreeViewController *three = [[EmoThreeViewController alloc] init];
    three.title = @"第四个";
    [self addChildViewController:three];
    
    EmoFourViewController *four = [[EmoFourViewController alloc] init];
    four.title = @"第五个";
    [self addChildViewController:four];
    
    EmoFiveViewController *five = [[EmoFiveViewController alloc] init];
    five.title = @"第六个";
    [self addChildViewController:five];
    
    EmoSixViewController *six = [[EmoSixViewController alloc] init];
    six.title = @"第七个";
    [self addChildViewController:six];
    
    EmoSevenViewController *seven = [[EmoSevenViewController alloc] init];
    seven.title = @"第八个";
    [self addChildViewController:seven];
    
    EmoEightViewController *eight = [[EmoEightViewController alloc] init];
    eight.title = @"第九个";
    [self addChildViewController:eight];
    
    EmoNineViewController *nine = [[EmoNineViewController alloc] init];
    nine.title = @"第十个";
    [self addChildViewController:nine];
    
}

@end
