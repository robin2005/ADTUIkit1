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


#ifdef DEBUG
#define ADTPVLog(format, ...) printf("class: <%p %s:(row %d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define ADTPVLog(format, ...)
#endif

/** 调试日志类型 */
typedef NS_ENUM(NSInteger, ADTPopViewLogStyle) {
    ADTPopViewLogStyleNO = 0,          // 关闭调试信息(窗口和控制台日志输出)
    ADTPopViewLogStyleWindow,          // 开启左上角小窗
    ADTPopViewLogStyleConsole,         // 开启控制台日志输出
    ADTPopViewLogStyleALL              // 开启小窗和控制台日志
};

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, ADTPopStyle) {
    ADTPopStyleFade = 0,               // 默认 渐变出现
    ADTPopStyleNO,                     // 无动画
    ADTPopStyleScale,                  // 缩放 先放大 后恢复至原大小
    ADTPopStyleSmoothFromTop,          // 顶部 平滑淡入动画
    ADTPopStyleSmoothFromLeft,         // 左侧 平滑淡入动画
    ADTPopStyleSmoothFromBottom,       // 底部 平滑淡入动画
    ADTPopStyleSmoothFromRight,        // 右侧 平滑淡入动画
    ADTPopStyleSpringFromTop,          // 顶部 平滑淡入动画 带弹簧
    ADTPopStyleSpringFromLeft,         // 左侧 平滑淡入动画 带弹簧
    ADTPopStyleSpringFromBottom,       // 底部 平滑淡入动画 带弹簧
    ADTPopStyleSpringFromRight,        // 右侧 平滑淡入动画 带弹簧
    ADTPopStyleCardDropFromLeft,       // 顶部左侧 掉落动画
    ADTPopStyleCardDropFromRight,      // 顶部右侧 掉落动画
};
/** 消失动画样式 */
typedef NS_ENUM(NSInteger, ADTDismissStyle) {
    ADTDismissStyleFade = 0,             // 默认 渐变消失
    ADTDismissStyleNO,                   // 无动画
    ADTDismissStyleScale,                // 缩放
    ADTDismissStyleSmoothToTop,          // 顶部 平滑淡出动画
    ADTDismissStyleSmoothToLeft,         // 左侧 平滑淡出动画
    ADTDismissStyleSmoothToBottom,       // 底部 平滑淡出动画
    ADTDismissStyleSmoothToRight,        // 右侧 平滑淡出动画
    ADTDismissStyleCardDropToLeft,       // 卡片从中间往左侧掉落
    ADTDismissStyleCardDropToRight,      // 卡片从中间往右侧掉落
    ADTDismissStyleCardDropToTop,        // 卡片从中间往顶部移动消失
};
/** 主动动画样式(开发中) */
typedef NS_ENUM(NSInteger, ADTActivityStyle) {
    ADTActivityStyleNO = 0,               /// 无动画
    ADTActivityStyleScale,                /// 缩放
    ADTActivityStyleShake,                /// 抖动
};
/** 弹窗位置 */
typedef NS_ENUM(NSInteger, ADTHemStyle) {
    ADTHemStyleCenter = 0,   //居中
    ADTHemStyleTop,          //贴顶
    ADTHemStyleLeft,         //贴左
    ADTHemStyleBottom,       //贴底
    ADTHemStyleRight,        //贴右
    ADTHemStyleTopLeft,      //贴顶和左
    ADTHemStyleBottomLeft,   //贴底和左
    ADTHemStyleBottomRight,  //贴底和右
    ADTHemStyleTopRight      //贴顶和右
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
typedef NS_ENUM(NSInteger, ADTSweepStyle) {
    ADTSweepStyleNO = 0,  //默认 不能拖拽窗口
    ADTSweepStyleX_Positive = 1<<0,   //X轴正方向拖拽
    ADTSweepStyleX_Negative = 1<<1,   //X轴负方向拖拽
    ADTSweepStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    ADTSweepStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    ADTSweepStyleX = (ADTSweepStyleX_Positive|ADTSweepStyleX_Negative),   //X轴方向拖拽
    ADTSweepStyleY = (ADTSweepStyleY_Positive|ADTSweepStyleY_Negative),   //Y轴方向拖拽
    ADTSweepStyleALL = (ADTSweepStyleX|ADTSweepStyleY)   //全向轻扫
};

/**
   可轻扫消失动画类型 对单向横扫 设置有效
   ADTSweepDismissStyleSmooth: 自动适应选择以下其一
   ADTDismissStyleSmoothToTop,
   ADTDismissStyleSmoothToLeft,
   ADTDismissStyleSmoothToBottom ,
   ADTDismissStyleSmoothToRight
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
