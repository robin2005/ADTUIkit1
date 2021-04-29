//
//  ADTPopView.h
//  ADTUIKit
//
//  Copyright (c) 2020 robin2005 - https://github.com/robin005
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//
 

#import <UIKit/UIKit.h>
#import "ADTPopViewProtocol.h"
#import "UIView+ADTFrame.h"


#define ADTPopViewWK(object)  __weak typeof(object) wk_##object = object;
#define ADTPopViewSS(object)  __strong typeof(object) object = weak##object;


NS_ASSUME_NONNULL_BEGIN

@interface ADTPopView : UIView

/** 弹窗位置 默认Center */
@property (nonatomic, assign) ADTPostionStyle hemStyle;
/** 显示时动画弹窗样式 默认ADTPopAnimationStyleNO */
@property (nonatomic, assign) ADTPopAnimationStyle popStyle;
/** 移除时动画弹窗样式 默认ADTPopDismissStyleNO */
@property (nonatomic, assign) ADTPopDismissStyle dismissStyle;
/** 显示时动画时长，> 0。不设置则使用默认的动画时长 设置成ADTPopAnimationStyleNO, 该属性无效 */
@property (nonatomic, assign) NSTimeInterval popDuration;
/** 隐藏时动画时长，>0。不设置则使用默认的动画时长  设置成ADTPopDismissStyleNO, 该属性无效 */
@property (nonatomic, assign) NSTimeInterval dismissDuration;
/** 弹窗水平方向(X)偏移量校准 默认0 */
@property (nonatomic, assign) CGFloat adjustX;
/** 弹窗垂直方向(Y)偏移量校准 默认0 */
@property (nonatomic, assign) CGFloat adjustY;
/** 背景颜色 默认rgb(0,0,0) 透明度0.3 */
@property (nullable,nonatomic,strong) UIColor *bgColor;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.3 */
@property (nonatomic, assign) CGFloat bgAlpha;
/** 是否隐藏背景 默认NO */
@property (nonatomic, assign) BOOL isHideBg;
/** 显示时点击背景是否移除弹窗，默认为NO。 */
@property (nonatomic, assign) BOOL isClickBgDismiss;
/** 是否监听屏幕旋转，默认为YES */
@property (nonatomic, assign) BOOL isObserverScreenRotation;
/** 是否支持点击回馈 默认NO (暂时关闭) */
@property (nonatomic, assign) BOOL isClickFeedback;
/** 是否规避键盘 默认YES */
@property (nonatomic, assign) BOOL isAvoidKeyboard;
/** 弹窗和键盘的距离 默认10 */
@property (nonatomic, assign) CGFloat avoidKeyboardSpace;
/** 显示多长时间 默认0 不会消失 */
@property (nonatomic, assign) NSTimeInterval showTime;
/** 自定view圆角方向设置  默认UIRectCornerAllCorners  当cornerRadius>0时生效*/
@property (nonatomic, assign) UIRectCorner rectCorners;
/** 自定义view圆角大小 */
@property (nonatomic, assign) CGFloat cornerRadius;
/** 弹出震动反馈 默认NO iOS10+ 系统才有此效果 */
@property (nonatomic, assign) BOOL isImpactFeedback;

/** 代理 支持多代理 */
@property (nonatomic, weak) id<ADTPopViewProtocol> _Nullable delegate;
/** 标识 默认为空 */
@property (nonatomic, copy) NSString *_Nullable identifier;
/** 弹窗容器 */
@property (nonatomic, readonly) UIView *parentView;
/** 自定义view */
@property (nonatomic, readonly) UIView *currCustomView;

//************ 群组相关属性 ****************
/** 群组标识 统一给弹窗编队 方便独立管理 默认为nil,统一全局处理 */
@property (nullable,nonatomic,strong) NSString *groupId;
/** 是否堆叠 默认NO  如果是YES  priority优先级不生效*/
@property (nonatomic,assign) BOOL isStack;
/** 单显示 默认NO  只会显示优先级最高的popView   */
@property (nonatomic, assign) BOOL isSingle;
/** 优先级 范围0~1000 (默认0,遵循先进先出) isStack和isSingle为NO的时候生效 */
@property (nonatomic, assign) CGFloat priority;
//****************************************

//************ 拖拽手势相关属性 ****************
/** 拖拽方向 默认 不可拖拽  */
@property (nonatomic, assign) ADTDragStyle dragStyle;
/** X轴或者Y轴拖拽移除临界距离 范围(0 ~ +∞)  默认0 不拖拽移除  基使用于dragStyle  */
@property (nonatomic, assign) CGFloat dragDistance;
/** 拖拽移除动画类型 默认同dismissStyle  */
@property (nonatomic, assign) ADTPopDismissStyle dragDismissStyle;
/** 拖拽消失动画时间 默认同 dismissDuration  */
@property (nonatomic, assign) NSTimeInterval dragDismissDuration;
/** 拖拽复原动画时间 默认0.25s */
@property (nonatomic, assign) NSTimeInterval dragReboundTime;

/** 轻扫方向 默认 不可轻扫  前提开启dragStyle */
@property (nonatomic, assign) ADTPopSweepStyle sweepStyle;
/** 轻扫速率 控制轻扫移除 默认1000  基于使用sweepStyle */
@property (nonatomic, assign) CGFloat swipeVelocity;
/** 轻扫移除的动画 默认ADTSweepDismissStyleVelocity  */
@property (nonatomic, assign) ADTSweepDismissStyle sweepDismissStyle;



/** 点击背景 */
@property (nullable, nonatomic, copy) void(^bgClickBlock)(void);
/** 长按背景 */
@property (nullable, nonatomic, copy) void(^bgLongPressBlock)(void);

/** 弹窗pan手势偏移量  */
@property (nullable, nonatomic, copy) void(^panOffsetBlock)(CGPoint offset);


//以下键盘弹出/收起 第三方键盘会多次回调(百度,搜狗测试得出), 原生键盘回调一次
/** 键盘将要弹出 */
@property (nullable, nonatomic, copy) void(^keyboardWillShowBlock)(void);
/** 键盘弹出完毕 */
@property (nullable, nonatomic, copy) void(^keyboardDidShowBlock)(void);
/** 键盘frame将要改变 */
@property (nullable, nonatomic, copy) void(^keyboardFrameWillChangeBlock)(CGRect beginFrame,CGRect endFrame,CGFloat duration);
/** 键盘frame改变完毕 */
@property (nullable, nonatomic, copy) void(^keyboardFrameDidChangeBlock)(CGRect beginFrame,CGRect endFrame,CGFloat duration);
/** 键盘将要收起 */
@property (nullable, nonatomic, copy) void(^keyboardWillHideBlock)(void);
/** 键盘收起完毕 */
@property (nullable, nonatomic, copy) void(^keyboardDidHideBlock)(void);

//************ 生命周期回调(Block) ************
/** 将要显示 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillPopBlock)(void);
/** 已经显示完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidPopBlock)(void);
/** 将要开始移除 回调 */
@property (nullable, nonatomic, copy) void(^popViewWillDismissBlock)(void);
/** 已经移除完毕 回调 */
@property (nullable, nonatomic, copy) void(^popViewDidDismissBlock)(void);
/** 倒计时 回调 */
@property (nullable, nonatomic, copy) void(^popViewCountDownBlock)(ADTPopView *popView,NSTimeInterval timeInterval);
//********************************************


/*
 以下是构建方法
 customView: 已定义view
 popStyle: 弹出动画
 dismissStyle: 移除动画
 parentView: 弹窗父容器
 */
+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView;

+ (nullable instancetype)initWithCustomView:(UIView *)customView
                                   popStyle:(ADTPopAnimationStyle)popStyle
                               dismissStyle:(ADTPopDismissStyle)dismissStyle;

+ (nullable instancetype)initWithCustomView:(UIView *)customView
                                 parentView:(UIView *_Nullable)parentView
                                   popStyle:(ADTPopAnimationStyle)popStyle
                               dismissStyle:(ADTPopDismissStyle)dismissStyle;
/*
  以下是弹出方法
  popStyle: 弹出动画 优先级大于全局的popStyle 局部起作用
  duration: 弹出时间 优先级大于全局的popDuration 局部起作用
*/
- (void)pop;
- (void)popWithStyle:(ADTPopAnimationStyle)popStyle;
- (void)popWithDuration:(NSTimeInterval)duration;
- (void)popWithStyle:(ADTPopAnimationStyle)popStyle duration:(NSTimeInterval)duration;


/*
  以下是弹出方法
  dismissStyle: 弹出动画 优先级大于全局的dismissStyle 局部起作用
  duration: 弹出时间 优先级大于全局的dismissDuration 局部起作用
*/
- (void)dismiss;
- (void)dismissWithStyle:(ADTPopDismissStyle)dismissStyle;
- (void)dismissWithDuration:(NSTimeInterval)duration;
- (void)dismissWithStyle:(ADTPopDismissStyle)dismissStyle duration:(NSTimeInterval)duration;


/** 删除指定代理 */
- (void)removeForDelegate:(id<ADTPopViewProtocol>)delegate;
/** 删除代理池 删除所有代理 */
- (void)removeAllDelegate;
 

#pragma mark - ***** 以下是 窗口管理api *****

/** 获取全局(整个app内)所有popView */
+ (NSArray *)getAllPopView;
/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)parentView;
/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(UIView *)popView;
/**
    读取popView (有可能会跨编队读取弹窗)
    建议使用getPopViewForGroupId:forkey: 方法进行精确读取
 */
+ (ADTPopView *)getPopViewForKey:(NSString *)key;
/** 移除popView */
+ (void)removePopView:(ADTPopView *)popView;
/**
   移除popView 通过唯一key (有可能会跨编队误删弹窗)
   建议使用removePopViewForGroupId:forkey: 方法进行精确删除
*/
+ (void)removePopViewForKey:(NSString *)key;
/** 移除所有popView */
+ (void)removeAllPopView;
/** 移除 最后一个弹出的 popView */
+ (void)removeLastPopView;


/** 开启调试view  建议设置成 线上隐藏 测试打开 */
+ (void)setLogStyle:(ADTPopViewLogStyle)logStyle;


@end

NS_ASSUME_NONNULL_END