//
//  ADTPopViewProtocol.h
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

#import <Foundation/Foundation.h>
@class ADTPopView; 

/** 调试日志类型 */
typedef NS_ENUM(NSInteger, ADTPopViewLogStyle) {
    ADTPopViewLogStyleNO = 0,          // 关闭调试信息(窗口和控制台日志输出)
    ADTPopViewLogStyleWindow,          // 开启左上角小窗
    ADTPopViewLogStyleConsole,         // 开启控制台日志输出
    ADTPopViewLogStyleALL              // 开启小窗和控制台日志
};

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, ADTPopAnimationStyle) {
    ADTPopAnimationStyleFade = 0,               // 默认 渐变出现
    ADTPopAnimationStyleNO,                     // 无动画
    ADTPopAnimationStyleScale,                  // 缩放 先放大 后恢复至原大小
    ADTPopAnimationStyleSmoothFromTop,          // 顶部 平滑淡入动画
    ADTPopAnimationStyleSmoothFromLeft,         // 左侧 平滑淡入动画
    ADTPopAnimationStyleSmoothFromBottom,       // 底部 平滑淡入动画
    ADTPopAnimationStyleSmoothFromRight,        // 右侧 平滑淡入动画
    ADTPopAnimationStyleSpringFromTop,          // 顶部 平滑淡入动画 带弹簧
    ADTPopAnimationStyleSpringFromLeft,         // 左侧 平滑淡入动画 带弹簧
    ADTPopAnimationStyleSpringFromBottom,       // 底部 平滑淡入动画 带弹簧
    ADTPopAnimationStyleSpringFromRight,        // 右侧 平滑淡入动画 带弹簧
    ADTPopAnimationStyleCardDropFromLeft,       // 顶部左侧 掉落动画
    ADTPopAnimationStyleCardDropFromRight,      // 顶部右侧 掉落动画
};
/** 消失动画样式 */
typedef NS_ENUM(NSInteger, ADTPopDismissStyle) {
    ADTPopDismissStyleFade = 0,             // 默认 渐变消失
    ADTPopDismissStyleNO,                   // 无动画
    ADTPopDismissStyleScale,                // 缩放
    ADTPopDismissStyleSmoothToTop,          // 顶部 平滑淡出动画
    ADTPopDismissStyleSmoothToLeft,         // 左侧 平滑淡出动画
    ADTPopDismissStyleSmoothToBottom,       // 底部 平滑淡出动画
    ADTPopDismissStyleSmoothToRight,        // 右侧 平滑淡出动画
    ADTPopDismissStyleCardDropToLeft,       // 卡片从中间往左侧掉落
    ADTPopDismissStyleCardDropToRight,      // 卡片从中间往右侧掉落
    ADTPopDismissStyleCardDropToTop,        // 卡片从中间往顶部移动消失
};
/** 主动动画样式(开发中) */
typedef NS_ENUM(NSInteger, ADTActivityStyle) {
    ADTActivityStyleNO = 0,               /// 无动画
    ADTActivityStyleScale,                /// 缩放
    ADTActivityStyleShake,                /// 抖动
};
/** 弹窗位置 */
typedef NS_ENUM(NSInteger, ADTPostionStyle) {
    ADTPostionStyleCenter = 0,   //居中
    ADTPostionStyleTop,          //贴顶
    ADTPostionStyleLeft,         //贴左
    ADTPostionStyleBottom,       //贴底
    ADTPostionStyleRight,        //贴右
    ADTPostionStyleTopLeft,      //贴顶和左
    ADTPostionStyleBottomLeft,   //贴底和左
    ADTPostionStyleBottomRight,  //贴底和右
    ADTPostionStyleTopRight      //贴顶和右
};
/** 拖拽方向 */
typedef NS_ENUM(NSInteger, ADTDragStyle) {
    ADTDragStyleNO = 0,  //默认 不能拖拽窗口
    ADTDragStyleX_Positive = 1<<0,   //X轴正方向拖拽
    ADTDragStyleX_Negative = 1<<1,   //X轴负方向拖拽
    ADTDragStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    ADTDragStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    ADTDragStyleX = (ADTDragStyleX_Positive|ADTDragStyleX_Negative),   //X轴方向拖拽
    ADTDragStyleY = (ADTDragStyleY_Positive|ADTDragStyleY_Negative),   //Y轴方向拖拽
    ADTDragStyleAll = (ADTDragStyleX|ADTDragStyleY)   //全向拖拽
};
///** 可轻扫消失的方向 */
typedef NS_ENUM(NSInteger, ADTPopSweepStyle) {
    ADTPopSweepStyleNO = 0,  //默认 不能拖拽窗口
    ADTPopSweepStyleX_Positive = 1<<0,   //X轴正方向拖拽
    ADTPopSweepStyleX_Negative = 1<<1,   //X轴负方向拖拽
    ADTPopSweepStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    ADTPopSweepStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    ADTPopSweepStyleX = (ADTPopSweepStyleX_Positive|ADTPopSweepStyleX_Negative),   //X轴方向拖拽
    ADTPopSweepStyleY = (ADTPopSweepStyleY_Positive|ADTPopSweepStyleY_Negative),   //Y轴方向拖拽
    ADTPopSweepStyleALL = (ADTPopSweepStyleX|ADTPopSweepStyleY)   //全向轻扫
};

/**
   可轻扫消失动画类型 对单向横扫 设置有效
   ADTSweepDismissStyleSmooth: 自动适应选择以下其一
   ADTPopDismissStyleSmoothToTop,
   ADTPopDismissStyleSmoothToLeft,
   ADTPopDismissStyleSmoothToBottom ,
   ADTPopDismissStyleSmoothToRight
 */
typedef NS_ENUM(NSInteger, ADTSweepDismissStyle) {
    ADTSweepDismissStyleVelocity = 0,  //默认加速度 移除
    ADTSweepDismissStyleSmooth = 1     //平顺移除
};


NS_ASSUME_NONNULL_BEGIN

@protocol ADTPopViewProtocol <NSObject>


/** 点击弹窗 回调 */
- (void)ADT_PopViewBgClickForPopView:(ADTPopView *)popView;
/** 长按弹窗 回调 */
- (void)ADT_PopViewBgLongPressForPopView:(ADTPopView *)popView;




// ****** 生命周期 ******
/** 将要显示 */
- (void)ADT_PopViewWillPopForPopView:(ADTPopView *)popView;
/** 已经显示完毕 */
- (void)ADT_PopViewDidPopForPopView:(ADTPopView *)popView;
/** 倒计时进行中 timeInterval:时长  */
- (void)ADT_PopViewCountDownForPopView:(ADTPopView *)popView forCountDown:(NSTimeInterval)timeInterval;
/** 倒计时倒计时完成  */
- (void)ADT_PopViewCountDownFinishForPopView:(ADTPopView *)popView;
/** 将要开始移除 */
- (void)ADT_PopViewWillDismissForPopView:(ADTPopView *)popView;
/** 已经移除完毕 */
- (void)ADT_PopViewDidDismissForPopView:(ADTPopView *)popView;
//***********************

@end

NS_ASSUME_NONNULL_END
