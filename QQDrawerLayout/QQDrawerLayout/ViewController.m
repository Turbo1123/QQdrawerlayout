//
//  ViewController.m
//  QQDrawerLayout
//
//  Created by 李云龙 on 15/8/11.
//  Copyright (c) 2015年 hihilong. All rights reserved.
//

#import "ViewController.h"

// _mainV frame
// _main.frame
// 在宏的参数前加上一个#，宏的参数会自动转换成c语言的字符串
#define LYLkeyPath(objc,keyPath) @(((void)objc.keyPath, #keyPath))

@interface ViewController ()


@property (nonatomic, weak) UIView *leftV;
@property (nonatomic, weak) UIView *rightV;
@property (nonatomic, weak) UIView *mainV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional  setup after loading the view, typically from a nib.
    
    // 添加所有的子控件
    [self setUpAllChildView];
    
    // 添加pan手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    [self.view addGestureRecognizer:pan];
    
    // 利用KVO时刻监听mainV.frame改变
    
    [_mainV addObserver:self forKeyPath:LYLkeyPath(_mainV, frame) options:NSKeyValueObservingOptionNew context:nil];
    
}

// 只要监听的属性有新值的时候，只要main.frame一改变就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",NSStringFromCGRect(_mainV.frame));
    
    // 当手指往右移动，显示左边视图
    if (_mainV.frame.origin.x > 0) { // 往右，显示左边
        _rightV.hidden = YES;
    }else if (_mainV.frame.origin.x < 0){ // 往左，显示右边
        _rightV.hidden = NO;
    }
}

// 当对象销毁的时候，移除观察者
- (void)dealloc
{
    [_mainV removeObserver:self forKeyPath:@"frame"];
}


#define targetR 250
#define targetL -250

- (void)pan:(UIPanGestureRecognizer *)pan
{
    // 获取X轴偏移量
    CGFloat offsetX = [pan translationInView:self.view].x;
    
    // 根据x轴计算当前mainV的frame
    _mainV.frame = [self frameWithOffsetX:offsetX];
    
    // 复位
    [pan setTranslation:CGPointZero inView:self.view];
    
    
    
    if (pan.state == UIGestureRecognizerStateEnded) { // 手指抬起
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        // 定位
        // 当mainV.x > screenW * 0.5 ,定位到右边某个点
        // 当max(mainV.x) < screenW * 0.5 定位到左边某个点
        CGFloat target = 0;
        if (_mainV.frame.origin.x > screenW * 0.5) {
            target = targetR;
        }else if (CGRectGetMaxX(_mainV.frame) < screenW * 0.5){
            target = targetL;
        }
        
        CGFloat offsetX = target - _mainV.frame.origin.x;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _mainV.frame = [self frameWithOffsetX:offsetX];
        }];
    }
    
}

#define kMaxY 100

// 根据x轴偏移量计算出当前mainV的frame
- (CGRect)frameWithOffsetX:(CGFloat)offsetX
{
    
    // 获取屏幕的宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 获取屏幕的高度
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    // 修改红色的frame
    CGRect frame = _mainV.frame;
    
    // 计算当前的x
    CGFloat x = frame.origin.x + offsetX;
    
    // 计算当前的y
    CGFloat y = x * kMaxY / screenW;
    
    if (_mainV.frame.origin.x < 0) { // 往左移动
        y = -y;
    }
    
    // 获取当前的高度
    CGFloat h = screenH - 2 * y;
    
    // 计算高度的缩放比例
    CGFloat scale = h / screenH;
    
    // 计算当前宽度
    CGFloat w = screenW * scale;
    
    return CGRectMake(x, y, w, h);
}

- (void)setUpAllChildView
{
    
    // left
    UIView *leftV = [[UIView alloc] initWithFrame:self.view.bounds];
    
    leftV.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:leftV];
    
    _leftV = leftV;
    
    // right
    
    UIView *rightV = [[UIView alloc] initWithFrame:self.view.bounds];
    
    rightV.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:rightV];
    
    _rightV = rightV;
    
    
    //main
    
    UIView *mainV = [[UIView alloc] initWithFrame:self.view.bounds];
    
    mainV.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:mainV];
    
    _mainV = mainV;
    
}

@end
