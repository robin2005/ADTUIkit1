//
//  ADTCardViewItem.h
//  ADTUIKit
//
//  Created by jdm on 4/29/20.
//

#import <UIKit/UIKit.h>

@interface ADTCardViewItem : UIView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) UIView *contentView;

@end
