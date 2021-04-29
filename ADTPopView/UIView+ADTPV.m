//
//  UIView+ADTPV.m
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

#import "UIView+ADTPV.h"

@implementation UIView (ADTPV)


- (void)setPv_X:(CGFloat)pv_X {
    CGRect frame = self.frame;
    frame.origin.x = pv_X;
    self.frame = frame;
}

- (CGFloat)pv_X {
    return self.frame.origin.x;
}

- (void)setPv_Y:(CGFloat)pv_Y {
    CGRect frame = self.frame;
    frame.origin.y = pv_Y;
    self.frame = frame;
}

- (CGFloat)pv_Y {
    return self.frame.origin.y;
}

- (void)setPv_Width:(CGFloat)pv_Width {
    CGRect frame = self.frame;
    frame.size.width = pv_Width;
    self.frame = frame;
}

- (CGFloat)pv_Width {
    return self.frame.size.width;
}

- (void)setPv_Height:(CGFloat)pv_Height {
    CGRect frame = self.frame;
    frame.size.height = pv_Height;
    self.frame = frame;
}

- (CGFloat)pv_Height {
    return self.frame.size.height;
}

- (void)setPv_Size:(CGSize)pv_Size {
    CGRect frame = self.frame;
    frame.size = pv_Size;
    self.frame = frame;
}

- (CGSize)pv_Size {
    return self.frame.size;
}

- (void)setPv_CenterX:(CGFloat)pv_CenterX {
    CGPoint center = self.center;
    center.x = pv_CenterX;
    self.center = center;
}

- (CGFloat)pv_CenterX {
    return self.center.x;
}

- (void)setPv_CenterY:(CGFloat)pv_CenterY {
    CGPoint center = self.center;
    center.y = pv_CenterY;
    self.center = center;
}

- (CGFloat)pv_CenterY {
    return self.center.y;
}

- (void)setPv_Top:(CGFloat)pv_Top {
    CGRect newframe = self.frame;
    newframe.origin.y = pv_Top;
    self.frame = newframe;
}

- (CGFloat)pv_Top {
    return self.frame.origin.y;
}

- (void)setPv_Left:(CGFloat)pv_Left {
    CGRect newframe = self.frame;
    newframe.origin.x = pv_Left;
    self.frame = newframe;
}

- (CGFloat)pv_Left {
    return self.frame.origin.x;
}

- (void)setPv_Bottom:(CGFloat)pv_Bottom {
    CGRect newframe = self.frame;
    newframe.origin.y = pv_Bottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)pv_Bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setPv_Right:(CGFloat)pv_Right {
    CGFloat delta = pv_Right - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (CGFloat)pv_Right {
    return self.frame.origin.x + self.frame.size.width;
}

/** 是否是苹果X系列(刘海屏系列) */
BOOL pv_IsIphoneX_ALL(void) {
    BOOL isPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
    }
    return isPhoneX;
}

CGSize pv_ScreenSize(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size;
}

CGFloat pv_ScreenWidth(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width;
}

CGFloat pv_ScreenHeight(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.height;
}

@end
