//
//  ViewController.m
//  panDemo
//
//  Created by 尹东博 on 16/4/25.
//  Copyright © 2016年 尹东博. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<
UIGestureRecognizerDelegate
>{
    NSInteger totalNumber;
    
    // 开始拖动的view的下一个view的CGPoint（如果开始位置是0 结束位置是4 nextPoint值逐个往下算）
    CGPoint nextPoint;
    
    // 用于赋值CGPoint
    CGPoint valuePoint;
    
    BOOL _haveLongPress;
}
@property(nonatomic,strong)UILabel * label;
@property(nonatomic,strong)UIView * aView;
@end

#define KBase_tag     10
#define IphoneWidth   [UIScreen mainScreen].bounds.size.width
#define IphoneHeight  [UIScreen mainScreen].bounds.size.height

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    totalNumber = 9;
    
    _aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_aView];
    _haveLongPress = NO;
    
    // 创建9宫格
    CGFloat btW = (IphoneWidth-20*5)/4;
    CGFloat btH = btW;
    
    for (NSInteger i = 0; i<totalNumber; i++) {
        
        UIButton * bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.frame = CGRectMake(20+(20+btW)*(i%4), 220 + (i/4)*(btH+20), btW, btH);
        bt.backgroundColor = [UIColor redColor];
        bt.tag = KBase_tag+i;
        [bt setTitle:[NSString stringWithFormat:@"tag值%ld",bt.tag] forState:UIControlStateNormal];
        //        [bt addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        [bt setBackgroundImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
        [_aView addSubview:bt];
        
        // 添加拖拽手势
        //        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        ////        [pan setMaximumNumberOfTouches:1]; // 最小手指数
        //        [pan setMaximumNumberOfTouches//
        
        // 长按手势
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.delegate = self;
        [bt addGestureRecognizer:longPress];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/**
 *  长按手势
 */
-(void)longPress:(UIGestureRecognizer*)recognizer{
    UIButton *recognizerView = (UIButton *)recognizer.view;
    // 禁用其他按钮的拖拽手势
    for (UIButton * bt in _aView.subviews) {
        if (bt!=recognizerView) {
            bt.userInteractionEnabled = NO;
        }
    }
    
    // 长按视图在父视图中的位置（触摸点的位置）
    CGPoint recognizerPoint = [recognizer locationInView:_aView];
    NSLog(@"_____%@",NSStringFromCGPoint(recognizerPoint));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 开始的时候改变拖动view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            recognizerView.alpha = 0.7;
        }];
        
        // 把拖动view放到最上层
        [_aView bringSubviewToFront:recognizerView];
        // valuePoint保存最新的移动位置
        valuePoint = recognizerView.center;
        return;
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        // 更新pan.view的center
        recognizerView.center = recognizerPoint;
        
        /**
         * 可以创建一个继承UIButton的类(MyButton)，这样便于扩展，增加一些属性来绑定数据
         * 如果在self.view上加其他控件拖拽会奔溃，可以在下面方法里面加判断MyButton，也可以把所有按钮放到一个全局变量的UIView上来替换self.view
         
         */
        for (UIButton * bt in _aView.subviews) {
            // 判断是否移动到另一个view区域
            // CGRectContainsPoint(rect,point) 判断某个点是否被某个frame包含
            if (CGRectContainsPoint(bt.frame, recognizerView.center)&&bt!=recognizerView)
            {
                NSLog(@"bt_______%@",bt);
                // 开始位置
                NSInteger fromIndex = recognizerView.tag - KBase_tag;
                
                // 需要移动到的位置
                NSInteger toIndex = bt.tag - KBase_tag;
                NSLog(@"开始位置=%ld  结束位置=%ld",fromIndex,toIndex);
                
                // 往后移动
                if ((toIndex-fromIndex)>0) {
                    // 从开始位置移动到结束位置
                    // 把移动view的下一个view移动到记录的view的位置(valuePoint)，并把下一view的位置记为新的nextPoint，并把view的tag值-1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex+1; i<=toIndex; i++) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            nextBt.tag--;
                            //                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        //                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                        
                    }];
                    
                }
                // 往前移动
                else{
                    // 从开始位置移动到结束位置
                    // 把移动view的上一个view移动到记录的view的位置(valuePoint)，并把上一view的位置记为新的nextPoint，并把view的tag值+1,依次类推
                    [UIView animateWithDuration:0.2 animations:^{
                        for (NSInteger i = fromIndex-1; i>=toIndex; i--) {
                            UIButton * nextBt = (UIButton*)[self.view viewWithTag:KBase_tag+i];
                            nextPoint = nextBt.center;
                            nextBt.center = valuePoint;
                            valuePoint = nextPoint;
                            nextBt.tag++;
                            //                            [nextBt setTitle:[NSString stringWithFormat:@"tag值%ld",nextBt.tag] forState:UIControlStateNormal];
                        }
                        recognizerView.tag = KBase_tag + toIndex;
                        //                        [recognizerView setTitle:[NSString stringWithFormat:@"tag值%ld",recognizerView.tag] forState:UIControlStateNormal];
                    }];
                }
            }
        }
        return;
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        _haveLongPress = NO;
        // 恢复其他按钮的拖拽手势
        for (UIButton * bt in _aView.subviews) {
            if (bt!=recognizerView) {
                bt.userInteractionEnabled = YES;
            }
        }
        
        // 结束时候恢复view的外观（放大，改变颜色等）
        [UIView animateWithDuration:0.2 animations:^{
            recognizerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            recognizerView.alpha = 1;
            recognizerView.center = valuePoint;
        }];
        return;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (_haveLongPress) {
        return NO;
    }else{
        _haveLongPress = YES;
    }
    NSLog(@"gestureRecognizerShouldBegin");
    return YES;
}

@end
