//
//  UIView+ADTPV.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ADTPV)

/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_X;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Y;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Width;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Height;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_CenterX;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_CenterY;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pv_Top;
/** 获取/设置view的左边坐标 */
@property (nonatomic, assign) CGFloat pv_Left;
/** 获取/设置view的底部坐标Y */
@property (nonatomic, assign) CGFloat pv_Bottom;
/** 获取/设置view的右边坐标 */
@property (nonatomic, assign) CGFloat pv_Right;
/** 获取/设置view的size */
@property (nonatomic, assign) CGSize pv_Size;


/** 是否是苹果X系列(刘海屏系列) */
BOOL pv_IsIphoneX_ALL(void);
/** 屏幕大小 */
CGSize pv_ScreenSize(void);
/** 屏幕宽度 */
CGFloat pv_ScreenWidth(void);
/** 屏幕高度 */
CGFloat pv_ScreenHeight(void);

@end

NS_ASSUME_NONNULL_END
