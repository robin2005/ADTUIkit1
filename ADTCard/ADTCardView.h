//
//  ADTCardView.h
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

//左滑右滑卡片
@class ADTCardView,ADTCardViewItem;

//卡片滑动方向
typedef enum {
    
    ADTCardViewDragDirectionLeftType   = 0 << 0,
    ADTCardViewDragDirectionRightType  = 1 << 0,
    ADTCardViewDragDirectionTopType    = 2 << 0,
    ADTCardViewDragDirectionBottomType = 3 << 0
    
}ADTCardViewDragDirectionType;

//卡片滑动事件
typedef enum {
    
    ADTCardViewDragByClick  = 0 << 0,
    ADTCardViewDragByHand   = 1 << 0
    
}ADTCardViewDragMode;

@protocol ADTCardViewDeletagte <NSObject>
@optional

/**
 卡片开始滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)handleView:(ADTCardView *)handleView beginMoveDirection:(ADTCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(ADTCardViewDragMode)dragMode;
/**
 卡片成功滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 */
- (void)handleView:(ADTCardView *)handleView effectiveDragDirection:(ADTCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(ADTCardViewDragMode)dragMode;

/**
 取消卡片滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 */
- (void)handleView:(ADTCardView *)handleView cancelDrag:(ADTCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(ADTCardViewDragMode)dragMode;
/**
 点击当前卡片
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(ADTCardView *)handleView didClickItemAtIndex:(NSInteger)index;
/**
 卡片正在滑动
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(ADTCardView *)handleView cardDidScroll:(ADTCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(ADTCardViewDragMode)dragMode;
/**
 卡片结束滑动
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(ADTCardView *)handleView cardEndScroll:(ADTCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(ADTCardViewDragMode)dragMode;
@end

@protocol ADTCardViewDataSource <NSObject>

@required

/**
 卡片Item
 
 @param handleView <#handleView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (__kindof ADTCardViewItem *)handleView:(ADTCardView *)handleView itemForIndex:(NSInteger)index;

/**
 数据源个数
 
 @param handleView <#handleView description#>
 @return <#return value description#>
 */
- (NSInteger)handleViewPageCountForView:(ADTCardView *)handleView;
@optional

- (CGSize)handleViewSizeForItem:(ADTCardView *)handleView;
- (CGFloat)handleViewTopInsetForItem:(ADTCardView *)handleView;

@end

@interface ADTCardView : UIView


- (__kindof ADTCardViewItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)class forItemReuseIdentifier:(NSString *)identifier;
//- (void)registerNib:(UINib *)nib forItemReuseIdentifier:(NSString *)identifier;
- (void)reloadData;

/**
 手动滑动
 
 @param direction <#direction description#>
 */
- (void)excuteSlide:(ADTCardViewDragDirectionType)direction;

@property (nonatomic, weak) id<ADTCardViewDataSource> dataSource;
@property (nonatomic, weak) id<ADTCardViewDeletagte> delegate;

/**
 当前索引
 */
@property (nonatomic, assign,readonly) NSInteger currentIndex;
@property (nonatomic, assign) BOOL enable;

- (UIView *)currentView;

@end

