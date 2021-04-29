//
//  ADTCardViewItem.m
//  ADTUIKit
//
//  Created by jdm on 4/29/20.
//

#import "ADTCardViewItem.h"

@interface ADTCardViewItem ()

@end

@implementation ADTCardViewItem

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}


- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

@end
