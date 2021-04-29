//
//  ADTPopView.m
//  ADTUIKit
//
//  Created by jdm on 6/19/20.
//

#import "ADTPopView.h"
#import <objc/runtime.h>
#import "ADTTimer.h" 

static NSString *const ADTPopViewLogTitle = @"ADTPopView日志 ---> :";
static ADTPopViewLogStyle _logStyle;


@interface ADTPopViewManager : NSObject

/** 单例 */
ADTPopViewManager *ADTPopViewM(void);

@end

@interface ADTPopViewManager ()

/** 储存已经展示popView */
@property (nonatomic,strong) NSMutableArray *popViewMarr;
/** 按顺序弹窗顺序存储已显示的 popview  */
@property (nonatomic,strong) NSPointerArray *showList;
/** 储存待移除的popView  */
@property (nonatomic,strong) NSHashTable <ADTPopView *> *removeList;
/** 内存信息View */
@property (nonatomic,strong) UILabel *infoView;

@end

@implementation ADTPopViewManager

static ADTPopViewManager *_instance;

ADTPopViewManager *ADTPopViewM() {
    return [ADTPopViewManager sharedInstance];
}

+ (instancetype)sharedInstance {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (NSArray *)getAllPopView {
    return ADTPopViewM().popViewMarr;
}
/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)parentView {
    NSMutableArray *mArr = ADTPopViewM().popViewMarr;
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        ADTPopView *popView = (ADTPopView *)obj;
        if ([popView.parentView isEqual:parentView]) {
            [resMarr addObject:obj];
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(ADTPopView *)popView {
    NSArray *mArr = [self getAllPopViewForParentView:popView.parentView];
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        ADTPopView *tPopView = (ADTPopView *)obj;
        
        if (popView.groupId == nil && tPopView.groupId == nil) {
            [resMarr addObject:obj];
            continue;
        }
        if ([tPopView.groupId isEqual:popView.groupId]) {
            [resMarr addObject:obj];
            continue;
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 读取popView */
+ (ADTPopView *)getPopViewForKey:(NSString *)key {
    if (key.length<=0) { return nil; }
    NSMutableArray *mArr = ADTPopViewM().popViewMarr;
    for (id obj in mArr) {
        ADTPopView *popView = (ADTPopView *)obj;
        if ([popView.identifier isEqualToString:key]) {
            return popView;
        }
    }
    return nil;
}

+ (void)savePopView:(ADTPopView *)popView {
    [ADTPopViewM().popViewMarr addObject:popView];
    
    //优先级排序
    [self sortingArr];
    
    if (_logStyle & ADTPopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & ADTPopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

/** 移除popView */
+ (void)removePopView:(ADTPopView *)popView {
    if (!popView) { return; }
    NSArray *arr = ADTPopViewM().popViewMarr;
    for (id obj in arr) {
        ADTPopView *tPopView = (ADTPopView *)obj;
        
        if ([tPopView isEqual:popView]) {
//            [ADTPopViewM().popViewMarr removeObject:obj];
            [tPopView dismissWithStyle:ADTDismissStyleNO];
            break;
        }
    }
    
    if (_logStyle & ADTPopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & ADTPopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key {
    if (key.length<=0) { return; }
    NSArray *arr = ADTPopViewM().popViewMarr;
    for (id obj in arr) {
        ADTPopView *tPopView = (ADTPopView *)obj;
        
        if ([tPopView.identifier isEqualToString:key]) {
//            [ADTPopViewM().popViewMarr removeObject:obj];
            [tPopView dismissWithStyle:ADTDismissStyleNO];
            break;
        }
    }
    if (_logStyle & ADTPopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & ADTPopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}
/** 移除所有popView */
+ (void)removeAllPopView {
    NSMutableArray *arr = ADTPopViewM().popViewMarr;
    if (arr.count<=0) { return;  }
    
    NSArray *popViewMarr = [NSArray arrayWithArray:ADTPopViewM().popViewMarr];
    
    [popViewMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ADTPopView *tPopView = (ADTPopView *)obj;
        
        [tPopView dismissWithStyle:ADTDismissStyleNO];
    }];
    
    if (_logStyle &  ADTPopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & ADTPopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

+ (void)removeLastPopView {
    NSPointerArray *showList =  ADTPopViewM().showList;
    for (NSInteger i = showList.count - 1; i >= 0; i --) {
        ADTPopView *popView = [showList pointerAtIndex:i];
        if (popView) {
            [self removePopView:popView];
            [showList addPointer:NULL];
            [showList compact];
            break;
        }
    }
}

#pragma mark - ***** Other 其他 *****

+ (void)setInfoData {
    ADTPopViewM().infoView.text = [NSString stringWithFormat:@"S:%zd R:%zd",ADTPopViewM().popViewMarr.count,ADTPopViewM().removeList.allObjects.count];
}

+ (void)setConsoleLog {
    ADTPVLog(@"%@ S:%zd个 R:%zd个",ADTPopViewLogTitle,ADTPopViewM().popViewMarr.count,ADTPopViewM().removeList.allObjects.count);
}

//冒泡排序
+ (void)sortingArr {
    NSMutableArray *arr = ADTPopViewM().popViewMarr;
    for (int i = 0; i < arr.count; i++) {
        for (int j = i+1; j < arr.count; j++) {
            ADTPopView *iPopView = (ADTPopView *)arr[i];
            
            ADTPopView *jPopView = (ADTPopView *)arr[j];
            
            if (iPopView.priority > jPopView.priority) {
                [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

/** 转移popView到待移除队列 */
+ (void)transferredToRemoveQueueWithPopView:(ADTPopView *)popView {
    NSArray *popViewMarr = ADTPopViewM().popViewMarr;
    
    [popViewMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ADTPopView *tPopView = (ADTPopView *)obj;
        
        if ([popView isEqual:tPopView]) {
            [ADTPopViewM().removeList addObject:obj];
            [ADTPopViewM().popViewMarr removeObject:obj];
        }
    }];
}

+ (void)destroyInRemoveQueue:(ADTPopView *)popView {
    if (ADTPopViewM().removeList.allObjects.count <= 0) {
        [self transferredToRemoveQueueWithPopView:popView];
    }
   
    if (_logStyle&ADTPopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle&ADTPopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

#pragma mark - ***** 懒加载 *****

- (UILabel *)infoView {
    if(_infoView) return _infoView;
    _infoView = [[UILabel alloc] init];
    _infoView.backgroundColor = UIColor.orangeColor;
    _infoView.textAlignment = NSTextAlignmentCenter;
    _infoView.font = [UIFont systemFontOfSize:11];
    _infoView.frame = CGRectMake(pv_ScreenWidth()-70, pv_IsIphoneX_ALL()? 40:20, 60, 10);
    _infoView.layer.cornerRadius = 1;
    _infoView.layer.masksToBounds = YES;
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    [superView addSubview:_infoView];
    return _infoView;
}

- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}

- (NSHashTable<ADTPopView *> *)removeList {
    if (_removeList) return _removeList;
    _removeList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return _removeList;
}

- (NSPointerArray *)showList {
    if (_showList) return _showList;
    _showList = [NSPointerArray pointerArrayWithOptions:(NSPointerFunctionsWeakMemory)];
    return _showList;
}

@end


static const NSTimeInterval ADTPopViewDefaultDuration = -1.0f;
// 角度转弧度
#define ADT_DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface ADTPopViewBgView : UIView

/** 是否隐藏背景 默认NO */
@property (nonatomic, assign) BOOL isHideBg;

@end

@implementation ADTPopViewBgView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && self.isHideBg){
        return nil;
    }
    return hitView;
}

@end

@interface ADTPopView () <UIGestureRecognizerDelegate>

/** 弹窗容器 默认是app UIWindow 可指定view作为容器 */
@property (nonatomic, weak) UIView *container;
/** 背景层 */
@property (nonatomic, strong) ADTPopViewBgView *backgroundView;
/** 自定义视图 */
@property (nonatomic,strong) UIView *customView;
/** 规避键盘偏移量 */
@property (nonatomic, assign) CGFloat avoidKeyboardOffset;
/** 代理池 */
@property (nonatomic, strong) NSHashTable <id<ADTPopViewProtocol>> *delegates;
/** 背景点击手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/** 自定义View滑动手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
//当前正在拖拽的是否是tableView
@property (nonatomic, assign) BOOL isDragScrollView;
/** 标记popView中是否有UIScrollView, UITableView, UICollectionView */
@property (nonatomic, weak) UIScrollView *scrollerView;
/** 记录自定义view原始Frame */
@property (nonatomic, assign) CGRect originFrame;
/** 标记dragDismissStyle是否被复制 */
@property (nonatomic, assign) BOOL isDragDismissStyle;
/** 是否弹出键盘 */
@property (nonatomic,assign,readonly) BOOL isShowKeyboard;
/** 弹出键盘的高度 */
@property (nonatomic, assign) CGFloat keyboardY;

@end

@implementation ADTPopView


#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //初始化配置
    _isClickBgDismiss = NO;
    _isObserverScreenRotation = YES;
    _bgAlpha = 0.25;
    _popStyle = ADTPopStyleFade;
    _dismissStyle = ADTDismissStyleFade;
    _popDuration = ADTPopViewDefaultDuration;
    _dismissDuration = ADTPopViewDefaultDuration;
    _hemStyle = ADTHemStyleCenter;
    _adjustX = 0;
    _adjustY = 0;
    _isClickFeedback = NO;
    _isAvoidKeyboard = YES;
    _avoidKeyboardSpace = 10;
    _bgColor = [UIColor blackColor];
    _identifier = @"";
    _isShowKeyboard = NO;
    _showTime = 0.0;
    _priority = 0;
    _isHideBg = NO;
    _isShowKeyboard = NO;
    _isImpactFeedback = NO;
    _rectCorners = UIRectCornerAllCorners;
    
    _isSingle = NO;
    
    //拖拽相关属性初始化
    _dragStyle = ADTDragStyleNO;
    _dragDismissStyle = ADTDismissStyleNO;
    _dragDistance = 0.0f;
    _dragReboundTime = 0.25;
    _dragDismissDuration = ADTPopViewDefaultDuration;
    _swipeVelocity = 1000.0f;
    
    _isDragDismissStyle = NO;
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView {
    return [self initWithCustomView:customView popStyle:ADTPopStyleNO dismissStyle:ADTDismissStyleNO];
}


+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(ADTPopStyle)popStyle
                               dismissStyle:(ADTDismissStyle)dismissStyle {
    
    return [self initWithCustomView:customView
                         parentView:nil
                           popStyle:popStyle
                       dismissStyle:dismissStyle];
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                 parentView:(UIView *)parentView
                                   popStyle:(ADTPopStyle)popStyle
                               dismissStyle:(ADTDismissStyle)dismissStyle {
    // 检测自定义视图是否存在(check customView is exist)
    if (!customView) { return nil; }
    if (![parentView isKindOfClass:[UIView class]] && parentView != nil) {
        ADTPVLog(@"parentView is error !!!");
        return nil;
    }
    
    CGRect popViewFrame = CGRectZero;
    if (parentView) {
        popViewFrame =  parentView.bounds;
    } else {
        popViewFrame =  CGRectMake(0, 0, pv_ScreenWidth(), pv_ScreenHeight());
    }
    
    ADTPopView *popView = [[ADTPopView alloc] initWithFrame:popViewFrame];
    popView.backgroundColor = [UIColor clearColor];

    popView.container = parentView? parentView : [UIApplication sharedApplication].keyWindow;

    popView.customView = customView;
    popView.backgroundView = [[ADTPopViewBgView alloc] initWithFrame:popView.bounds];
    popView.backgroundView.backgroundColor = [UIColor clearColor];
    popView.popStyle = popStyle;
    popView.dismissStyle = dismissStyle;
    
    [popView addSubview:popView.backgroundView];
    [popView.backgroundView addSubview:customView];
    
    //背景添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(popViewBgViewTap:)];
    tap.delegate = popView;
    popView.tapGesture = tap;
    [popView.backgroundView addGestureRecognizer:tap];
    
    //添加拖拽手势
    popView.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:popView action:@selector(pan:)];
    popView.panGesture.delegate = popView;
    [popView.customView addGestureRecognizer:popView.panGesture];
    
    //    [popView.backgroundView addTarget:popView action:@selector(popViewBgViewTap:) forControlEvents:UIControlEventTouchUpInside];;
    
    
    //    UILongPressGestureRecognizer *customViewLP = [[UILongPressGestureRecognizer alloc] initWithTarget:popView action:@selector(bgLongPressEvent:)];
    //    [popView.backgroundView addGestureRecognizer:customViewLP];
    
    //    UITapGestureRecognizer *customViewTap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(customViewClickEvent:)];
    //    [popView.customView addGestureRecognizer:customViewTap];
    
    //键盘将要显示
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //键盘显示完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    //键盘frame将要改变
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    //键盘frame改变完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    //键盘将要收起
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //键盘收起完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    //屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(statusBarOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    //监听customView frame
    [popView.customView addObserver:popView
                         forKeyPath:@"frame"
                            options:NSKeyValueObservingOptionOld
                            context:NULL];
    return popView;
}

- (void)dealloc {
    [self.customView removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //从待移除队列中销毁
    [ADTPopViewManager destroyInRemoveQueue:self];
    [self ADT_PopViewDidDismissForPopView:self];
    self.popViewDidDismissBlock? self.popViewDidDismissBlock():nil;
}

- (void)removeFromSuperview {

    [super removeFromSuperview];
    
    [ADTPopViewManager transferredToRemoveQueueWithPopView:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView != self.customView) {
        if(hitView == self && self.isHideBg){ return nil; }
    }
    return hitView;
}

#pragma mark - ***** 代理方法 *****
- (void)ADT_PopViewBgClickForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewBgClickForPopView:popView];
        }
    }
}

- (void)ADT_PopViewBgLongPressForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewBgLongPressForPopView:popView];
        }
    }
}

- (void)ADT_PopViewWillPopForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewWillPopForPopView:popView];
        }
    }
}

- (void)ADT_PopViewDidPopForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewDidPopForPopView:popView];
        }
    }
}

- (void)ADT_PopViewCountDownForPopView:(ADTPopView *)popView forCountDown:(NSTimeInterval)timeInterval {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewCountDownForPopView:popView forCountDown:timeInterval];
        }
    }
}

- (void)ADT_PopViewCountDownFinishForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewCountDownFinishForPopView:popView];
        }
    }
}

- (void)ADT_PopViewWillDismissForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewWillDismissForPopView:popView];
        }
    }
}

- (void)ADT_PopViewDidDismissForPopView:(ADTPopView *)popView {
    for (id<ADTPopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate ADT_PopViewDidDismissForPopView:popView];
        }
    }
}

#pragma mark - ***** 界面布局 *****

- (void)setCustomViewFrameWithHeight:(CGFloat)height {
    
    CGFloat changeY = 0;
    switch (self.hemStyle) {
        case ADTHemStyleTop ://贴顶
        {
            self.customView.pv_X = _backgroundView.pv_CenterX - _customView.pv_Size.width*0.5 + _adjustX;
            self.customView.pv_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        case ADTHemStyleLeft ://贴左
        {
            self.customView.pv_X = _adjustX;
            self.customView.pv_Y = _backgroundView.pv_CenterY - _customView.pv_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
        case ADTHemStyleBottom ://贴底
        {
            self.customView.pv_X = _backgroundView.pv_CenterX - _customView.pv_Size.width*0.5 + _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pv_Y = _backgroundView.pv_Height - _customView.pv_Height + _adjustY;
            changeY = height;
        }
            break;
        case ADTHemStyleRight ://贴右
        {
            self.customView.pv_X = _backgroundView.pv_Width - _customView.pv_Width + _adjustX;
            self.customView.pv_Y = _backgroundView.pv_CenterY - _customView.pv_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
        case ADTHemStyleTopLeft :///贴顶和左
        {
            self.customView.pv_X = _adjustX;
            self.customView.pv_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        case ADTHemStyleBottomLeft ://贴底和左
        {
            self.customView.pv_X = _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pv_Y = _backgroundView.pv_Height - _customView.pv_Height + _adjustY;
            changeY = height;
        }
            break;
        case ADTHemStyleBottomRight ://贴底和右
        {
            self.customView.pv_X = _backgroundView.pv_Width - _customView.pv_Width + _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pv_Y = _backgroundView.pv_Height - _customView.pv_Height + _adjustY;
            changeY = height;
        }
            break;
        case ADTHemStyleTopRight ://贴顶和右
        {
            self.customView.pv_X = _backgroundView.pv_Width - _customView.pv_Width + _adjustX;
            self.customView.pv_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        default://居中
        {
            self.customView.pv_X = _backgroundView.pv_CenterX - _customView.pv_Size.width*0.5 + _adjustX;
            self.customView.pv_Y = _backgroundView.pv_CenterY - _customView.pv_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
    }
    
    CGFloat originBottom = _originFrame.origin.y + _originFrame.size.height + _avoidKeyboardSpace;
    if (_isShowKeyboard && (originBottom > _keyboardY)) {//键盘已经显示
        CGFloat Y = _keyboardY - _customView.pv_Height - _avoidKeyboardSpace;
        _customView.pv_Y = Y;
        CGRect newFrame = _originFrame;
        newFrame.origin.y = newFrame.origin.y - changeY;
        newFrame.size = CGSizeMake(_originFrame.size.width, _customView.pv_Height);
        self.originFrame = newFrame;
    }else {//没有键盘显示
        self.originFrame = _customView.frame;
    }
    
    [self setCustomViewCorners];
}

- (void)setCustomViewCorners {
    
    BOOL isSetCorner = NO;
    
    if (self.rectCorners & UIRectCornerTopLeft) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerTopRight) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerBottomLeft) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerBottomRight) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerAllCorners) {
        isSetCorner = YES;
    }
    
    if (isSetCorner && self.cornerRadius>0) {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.customView.bounds byRoundingCorners:self.rectCorners cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        
        CAShapeLayer * layer = [[CAShapeLayer alloc]init];
        layer.frame = self.customView.bounds;
        layer.path = path.CGPath;
        self.customView.layer.mask = layer;
    }
    
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setPopDuration:(NSTimeInterval)popDuration {
    if (popDuration <= 0.0) { return; }
    _popDuration = popDuration;
}

- (void)setDismissDuration:(NSTimeInterval)dismissDuration {
    if (dismissDuration <= 0.0) { return; }
    _dismissDuration = dismissDuration;
}

- (void)setDragDismissDuration:(NSTimeInterval)dragDismissDuration {
    if (dragDismissDuration <= 0.0) { return; }
    _dragDismissDuration = dragDismissDuration;
}

- (void)setHemStyle:(ADTHemStyle)hemStyle {
    _hemStyle = hemStyle;
}

- (void)setAdjustX:(CGFloat)adjustX {
    _adjustX = adjustX;
//    self.customView.x = _customView.x + adjustX;
//    self.originFrame = _customView.frame;
    [self setCustomViewFrameWithHeight:0];
}

- (void)setAdjustY:(CGFloat)adjustY {
    _adjustY = adjustY;
//    self.customView.y = _customView.y + adjustY;
//    self.originFrame = _customView.frame;
    [self setCustomViewFrameWithHeight:0];
}

- (void)setIsObserverScreenRotation:(BOOL)isObserverScreenRotation {
    _isObserverScreenRotation = isObserverScreenRotation;
}

- (void)setBgAlpha:(CGFloat)bgAlpha {
    _bgAlpha = (bgAlpha <= 0.0f) ? 0.0f : ((bgAlpha > 1.0) ? 1.0 : bgAlpha);
    }

- (void)setIsClickFeedback:(BOOL)isClickFeedback {
    _isClickFeedback = isClickFeedback;
}

- (void)setIsHideBg:(BOOL)isHideBg {
    _isHideBg = isHideBg;
    self.backgroundView.isHideBg = isHideBg;
    self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
}

- (void)setShowTime:(NSTimeInterval)showTime {
    _showTime = showTime;
}

- (void)setDelegate:(id<ADTPopViewProtocol>)delegate {
    if ([self.delegates containsObject:delegate]) return;
    [self.delegates addObject:delegate];
}

- (void)setDragDismissStyle:(ADTDismissStyle)dragDismissStyle {
    _dragDismissStyle = dragDismissStyle;
    self.isDragDismissStyle = YES;
}

#pragma mark - ***** pop 弹出 *****
- (void)pop {
    [self popWithStyle:self.popStyle duration:self.popDuration];
}

- (void)popWithStyle:(ADTPopStyle)popStyle {
    [self popWithStyle:popStyle duration:self.popDuration];
}

- (void)popWithDuration:(NSTimeInterval)duration {
    [self popWithStyle:self.popStyle duration:duration];
}

- (void)popWithStyle:(ADTPopStyle)popStyle duration:(NSTimeInterval)duration {
    [self popWithPopStyle:popStyle duration:duration isOutStack:NO];
}

- (void)popWithPopStyle:(ADTPopStyle)popStyle duration:(NSTimeInterval)duration isOutStack:(BOOL)isOutStack {
    
    NSTimeInterval resDuration = [self getPopDuration:duration];
    
    [self setCustomViewFrameWithHeight:0];
    
    self.originFrame = self.customView.frame;

    BOOL startTimer = NO;
    
    if (self.isSingle) {//单显
        NSArray *popViewArr = [ADTPopViewManager getAllPopViewForPopView:self];
        for (id obj  in popViewArr) {//移除所有popView和移除定a时器
            ADTPopView *lastPopView = (ADTPopView *)obj;
            
            [lastPopView dismissWithDismissStyle:ADTDismissStyleNO duration:0.2 isRemove:YES];
        }
        startTimer = YES;
    }else {//多显
        if (!isOutStack) {//处理隐藏倒数第二个popView
            NSArray *popViewArr = [ADTPopViewManager getAllPopViewForPopView:self];
            if (popViewArr.count >= 1) {
                id obj = popViewArr[popViewArr.count - 1];
                ADTPopView *lastPopView = (ADTPopView *)obj;
                
                if (self.isStack) {//堆叠显示
                    startTimer = YES;
                }else {
                    if (self.priority >= lastPopView.priority) {//置顶显示
                        if (lastPopView.isShowKeyboard) {
                            [lastPopView endEditing:YES];
                        }
                        [lastPopView dismissWithDismissStyle:ADTDismissStyleFade duration:0.2 isRemove:NO];
                        startTimer = YES;
                    } else {//隐藏显示
                        if (!self.parentView) {
                            self.container = [UIApplication sharedApplication].keyWindow;
                        }
                        [ADTPopViewManager savePopView:self];
                        return;
                    }
                }
            } else {
                startTimer = YES;
            }
        }
    }
    
//    if (!isOutStack){
//        [self.parentView addSubview:self];
//    }
    if (!self.superview) {
        [self.container addSubview:self];
        [ADTPopViewM().showList addPointer:(__bridge void * _Nullable)self];
    }
    
    if (!isOutStack){
        [self ADT_PopViewWillPopForPopView:self];
        
        self.popViewWillPopBlock? self.popViewWillPopBlock():nil;
    }
    //动画处理
    [self popAnimationWithPopStyle:popStyle duration:resDuration];
    //震动反馈
    [self beginImpactFeedback];
    
    ADTPopViewWK(self);;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!isOutStack){
            [self ADT_PopViewDidPopForPopView:self];
            wk_self.popViewDidPopBlock? wk_self.popViewDidPopBlock():nil;
        }
        if (startTimer){ [self startTimer]; }
    });
    
    //保存popView
    if (!isOutStack) { [ADTPopViewManager savePopView:self]; }
}

- (void)popAnimationWithPopStyle:(ADTPopStyle)popStyle duration:(NSTimeInterval)duration {
    
    ADTPopViewWK(self);
    if (popStyle == ADTPopStyleFade) {//渐变出现
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        self.customView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.backgroundColor =[self getNewColorWith:self.bgColor alpha:self.bgAlpha];
            self.customView.alpha = 1.0f;
        }];
    } else if (popStyle == ADTPopStyleNO){//无动画
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundView.backgroundColor =[self getNewColorWith:self.bgColor alpha:self.bgAlpha];
        }];
        self.customView.alpha = 1.0f;
    } else {//有动画
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        [UIView animateWithDuration:duration animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:self.bgAlpha];
        }];
        //自定义view过渡动画
        [self hanlePopAnimationWithDuration:duration popStyle:popStyle];
    }
}

- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration
                             popStyle:(ADTPopStyle)popStyle {
    
    self.alpha = 0;
    [UIView animateWithDuration:duration*0.2 animations:^{
        self.alpha = 1;
    }];
    
    ADTPopViewWK(self);
    switch (popStyle) {
        case ADTPopStyleScale:// < 缩放动画，先放大，后恢复至原大小
        {
            [self animationWithLayer:_customView.layer duration:((0.3*duration)/0.7) values:@[@0.0, @1.2, @1.0]]; // 另外一组动画值(the other animation values) @[@0.0, @1.2, @0.9, @1.0]
        }
            break;
        case ADTPopStyleSmoothFromTop:
        case ADTPopStyleSmoothFromBottom:
        case ADTPopStyleSmoothFromLeft:
        case ADTPopStyleSmoothFromRight:
        case ADTPopStyleSpringFromTop:
        case ADTPopStyleSpringFromLeft:
        case ADTPopStyleSpringFromBottom:
        case ADTPopStyleSpringFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == ADTPopStyleSmoothFromTop || popStyle == ADTPopStyleSpringFromTop) {
                self.customView.layer.position = CGPointMake(startPosition.x, -_customView.pv_Height*0.5);
                
            } else if (popStyle == ADTPopStyleSmoothFromLeft || popStyle == ADTPopStyleSpringFromLeft) {
                self.customView.layer.position = CGPointMake(-_customView.pv_Width*0.5, startPosition.y);
                
            } else if (popStyle == ADTPopStyleSmoothFromBottom || popStyle == ADTPopStyleSpringFromBottom) {
                self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + _customView.pv_Height*0.5);
                
            } else {
                self.customView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + _customView.pv_Width*0.5 , startPosition.y);
            }
            
            CGFloat damping = 1.0;
            if (popStyle == ADTPopStyleSpringFromTop||
                popStyle == ADTPopStyleSpringFromLeft||
                popStyle == ADTPopStyleSpringFromBottom||
                popStyle == ADTPopStyleSpringFromRight) {
                damping = 0.65;
            }
            
            [UIView animateWithDuration:duration
                                  delay:0
                 usingSpringWithDamping:damping
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                
                wk_self.customView.layer.position = startPosition;
            } completion:nil];
        }
            break;
        case ADTPopStyleCardDropFromLeft:
        case ADTPopStyleCardDropFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == ADTPopStyleCardDropFromLeft) {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.pv_Height*0.5);
                self.customView.transform = CGAffineTransformMakeRotation(ADT_DEGREES_TO_RADIANS(15.0));
            } else {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.pv_Height*0.5);
                self.customView.transform = CGAffineTransformMakeRotation(ADT_DEGREES_TO_RADIANS(-15.0));
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                wk_self.customView.layer.position = startPosition;
            } completion:nil];
            
            [UIView animateWithDuration:duration*0.6 animations:^{
                wk_self.customView.layer.transform = CATransform3DMakeRotation(ADT_DEGREES_TO_RADIANS((popStyle == ADTPopStyleCardDropFromRight) ? 5.5 : -5.5), 0, 0, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.2 animations:^{
                    wk_self.customView.transform = CGAffineTransformMakeRotation(ADT_DEGREES_TO_RADIANS((popStyle == ADTPopStyleCardDropFromRight) ? -1.0 : 1.0));
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration*0.2 animations:^{
                        wk_self.customView.transform = CGAffineTransformMakeRotation(0.0);
                    } completion:nil];
                }];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ***** dismiss 移除 *****

- (void)dismiss {
    [self dismissWithStyle:self.dismissStyle duration:self.dismissDuration];
}

- (void)dismissWithStyle:(ADTDismissStyle)dismissStyle {
    [self dismissWithStyle:dismissStyle duration:self.dismissDuration];
}

- (void)dismissWithDuration:(NSTimeInterval)duration {
    [self dismissWithStyle:self.dismissStyle duration:duration];
}

- (void)dismissWithStyle:(ADTDismissStyle)dismissStyle duration:(NSTimeInterval)duration  {
    [self dismissWithDismissStyle:dismissStyle duration:duration isRemove:YES];
}

- (void)dismissWithDismissStyle:(ADTDismissStyle)dismissStyle
                       duration:(NSTimeInterval)duration
                       isRemove:(BOOL)isRemove {
    
    NSTimeInterval resDuration = [self getDismissDuration:duration];
    
    if (isRemove) {
        //把当前popView转移到待移除队列 避免线程安全问题
        [ADTPopViewManager transferredToRemoveQueueWithPopView:self];
    }
    
    [self ADT_PopViewWillDismissForPopView:self];
    
    self.popViewWillDismissBlock? self.popViewWillDismissBlock():nil;
    
    ADTPopViewWK(self)
    [self dismissAnimationWithDismissStyle:dismissStyle duration:resDuration];
    
    if (!self.isSingle && (isRemove && [ADTPopViewManager getAllPopViewForPopView:self].count >= 1)){//多显
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //popView出栈
            if (!self.isStack && [ADTPopViewManager getAllPopViewForPopView:self].count >= 1) {
                NSArray *popViewArr = [ADTPopViewManager getAllPopViewForPopView:self];
                id obj = popViewArr[popViewArr.count-1];
                ADTPopView *tPopView = (ADTPopView *)obj;
                if (!tPopView.superview) {
                    [tPopView.container addSubview:tPopView];
                    [ADTPopViewM().showList addPointer:(__bridge void * _Nullable)tPopView];
                }
                [tPopView popWithPopStyle:ADTPopStyleFade duration:0.25 isOutStack:YES];
            }
        });
    }
    if (isRemove) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wk_self removeFromSuperview];
        });
    }
}

- (void)dismissAnimationWithDismissStyle:(ADTDismissStyle)dismissStyle duration:(NSTimeInterval)duration {
    
    ADTPopViewWK(self);
    if (dismissStyle == ADTPopStyleFade) {
        [UIView animateWithDuration:0.2 animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
            wk_self.customView.alpha = 0.0f;
        }];
    }else if (dismissStyle == ADTPopStyleNO){
        wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        wk_self.customView.alpha = 0.0f;
    }else {//有动画
        [UIView animateWithDuration:duration*0.8 animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        }];
        [self hanleDismissAnimationWithDuration:duration withDismissStyle:dismissStyle];
    }
}

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration
                         withDismissStyle:(ADTDismissStyle)dismissStyle {
    
    [UIView animateWithDuration:duration*0.8 animations:^{
        self.alpha = 0;
    }];
    
    ADTPopViewWK(self);;
    switch (dismissStyle) {
        case ADTDismissStyleScale:
        {
            [self animationWithLayer:self.customView.layer duration:((0.2*duration)/0.8) values:@[@1.0, @0.66, @0.33, @0.01]];
        }
            break;
        case ADTDismissStyleSmoothToTop:
        case ADTDismissStyleSmoothToBottom:
        case ADTDismissStyleSmoothToLeft:
        case ADTDismissStyleSmoothToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = self.customView.layer.position;
            if (dismissStyle == ADTDismissStyleSmoothToTop) {
                endPosition = CGPointMake(startPosition.x, -(_customView.pv_Height*0.5));
                
            } else if (dismissStyle == ADTDismissStyleSmoothToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + _customView.pv_Height*0.5);
                
            } else if (dismissStyle == ADTDismissStyleSmoothToLeft) {
                endPosition = CGPointMake(-_customView.pv_Width*0.5, startPosition.y);
                
            } else {
                endPosition = CGPointMake(CGRectGetMaxX(self.frame) + _customView.pv_Width*0.5, startPosition.y);
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                wk_self.customView.layer.position = endPosition;
            } completion:nil];
        }
            break;
        case ADTDismissStyleCardDropToLeft:
        case ADTDismissStyleCardDropToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            __block CGFloat rotateEndY = 0.0f;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (dismissStyle == ADTDismissStyleCardDropToLeft) {
                    wk_self.customView.transform = CGAffineTransformMakeRotation(M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(wk_self.customView.frame.origin.y);
                    wk_self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(wk_self.frame) + startPosition.y + rotateEndY);
                } else {
                    wk_self.customView.transform = CGAffineTransformMakeRotation(-M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(wk_self.customView.frame.origin.y);
                    wk_self.customView.layer.position = CGPointMake(startPosition.x * 1.25, CGRectGetMaxY(wk_self.frame) + startPosition.y + rotateEndY);
                }
            } completion:nil];
        }
            break;
        case ADTDismissStyleCardDropToTop:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = CGPointMake(startPosition.x, -startPosition.y);
            [UIView animateWithDuration:duration*0.2 animations:^{
                wk_self.customView.layer.position = CGPointMake(startPosition.x, startPosition.y + 50.0f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.8 animations:^{
                    wk_self.customView.layer.position = endPosition;
                } completion:nil];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ***** other 其他 *****

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = CGRectNull;
        CGRect oldFrame = CGRectNull;
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            //此处为获取新的frame
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            oldFrame = [[change valueForKeyPath:@"old"] CGRectValue];
            if (!CGSizeEqualToSize(newFrame.size, oldFrame.size)) {
                [self setCustomViewFrameWithHeight:newFrame.size.height-oldFrame.size.height];
            }
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//按钮的压下事件 按钮缩小
- (void)bgLongPressEvent:(UIGestureRecognizer *)ges {
    
    //    [self.delegateMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //
    //        if ([obj respondsToSelector:@selector(ADT_PopViewBgLongPressForPopView:)]) {
    //            [obj ADT_PopViewBgLongPressForPopView:self];
    //        }
    //
    //    }];
    
    self.bgLongPressBlock? self.bgLongPressBlock():nil;

    //    switch (ges.state) {
    //        case UIGestureRecognizerStateBegan:
    //        {
    //            CGFloat scale = 0.95;
    //            [UIView animateWithDuration:0.35 animations:^{
    //                ges.view.transform = CGAffineTransformMakeScale(scale, scale);
    //            }];
    //        }
    //            break;
    //        case UIGestureRecognizerStateEnded:
    //        case UIGestureRecognizerStateCancelled:
    //        {
    //            [UIView animateWithDuration:0.35 animations:^{
    //                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    //            } completion:^(BOOL finished) {
    //            }];
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
}

- (void)customViewClickEvent:(UIGestureRecognizer *)ges {
    if (self.isClickFeedback) {
        CGFloat scale = 0.95;
        [UIView animateWithDuration:0.25 animations:^{
            ges.view.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
}

- (void)popViewBgViewTap:(UIButton *)tap {
    
    //    [self.delegateMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //
    //        if ([obj respondsToSelector:@selector(ADT_PopViewBgClickForPopView:)]) {
    //            [obj ADT_PopViewBgClickForPopView:self];
    //        }
    //
    //    }];
    
    if (self.bgClickBlock) {
        if (self.isShowKeyboard) {
            [self endEditing:YES];
        }
        self.bgClickBlock();
    }
    
    if (_isClickBgDismiss) {
        [self dismiss];
    }
}

- (NSTimeInterval)getPopDuration:(NSTimeInterval)currDuration {
    
    if (_popStyle == ADTPopStyleNO) { return 0.0f; }
    
    if (_popStyle == ADTPopStyleFade) { return 0.2f; }
    
    if (currDuration<=0) { self.popDuration = ADTPopViewDefaultDuration; }
    
    if (self.popDuration == ADTPopViewDefaultDuration) {
        NSTimeInterval defaultDuration = 0.0f;

        if (_popStyle == ADTPopStyleScale) {
            defaultDuration = 0.3f;
        }
        if (_popStyle == ADTPopStyleSmoothFromTop ||
            _popStyle == ADTPopStyleSmoothFromLeft ||
            _popStyle == ADTPopStyleSmoothFromBottom ||
            _popStyle == ADTPopStyleSmoothFromRight ||
            _popStyle == ADTPopStyleSpringFromTop ||
            _popStyle == ADTPopStyleSpringFromLeft ||
            _popStyle == ADTPopStyleSpringFromBottom ||
            _popStyle == ADTPopStyleSpringFromRight ||
            _popStyle == ADTPopStyleCardDropFromLeft ||
            _popStyle == ADTPopStyleCardDropFromRight) {
            defaultDuration = 0.6f;
        }
        return defaultDuration;
    } else {
        return currDuration;
    }
}
- (NSTimeInterval)getDismissDuration:(NSTimeInterval)currDuration {
    
    if (_dismissStyle == ADTDismissStyleNO) { return 0.0f; }
    
    if (_dismissStyle == ADTDismissStyleFade) { return 0.2f; }
    
    if (self.dismissDuration == ADTPopViewDefaultDuration) {
        NSTimeInterval defaultDuration = 0.0f;
        if (_dismissStyle == ADTDismissStyleNO) {
            defaultDuration = 0.0f;
        }
        
        if (_dismissStyle == ADTDismissStyleScale) {
            defaultDuration = 0.3f;
        }
        if (_dismissStyle == ADTDismissStyleSmoothToTop ||
            _dismissStyle == ADTDismissStyleSmoothToBottom ||
            _dismissStyle == ADTDismissStyleSmoothToLeft ||
            _dismissStyle == ADTDismissStyleSmoothToRight ||
            _dismissStyle == ADTDismissStyleCardDropToLeft ||
            _dismissStyle == ADTDismissStyleCardDropToRight ||
            _dismissStyle == ADTDismissStyleCardDropToTop) {
            defaultDuration = 0.5f;
        }
        return defaultDuration;
    } else {
        return currDuration;
    }
}
- (NSTimeInterval)getDragDismissDuration {
    if (self.dragDismissDuration ==  ADTPopViewDefaultDuration) {
        return [self getDismissDuration:self.dismissDuration];
    } else {
        return self.dragDismissDuration;
    }
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values {
    CAKeyframeAnimation *KFAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    KFAnimation.duration = duration;
    KFAnimation.removedOnCompletion = NO;
    KFAnimation.fillMode = kCAFillModeForwards;
    //    KFAnimation.delegate = self;//造成强应用 popView释放不了
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:values.count];
    for (NSUInteger i = 0; i<values.count; i++) {
        CGFloat scaleValue = [values[i] floatValue];
        [valueArr addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleValue, scaleValue, scaleValue)]];
    }
    KFAnimation.values = valueArr;
    KFAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layer addAnimation:KFAnimation forKey:nil];
}

- (UIColor *)ADT_BlackWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
}

// 改变UIColor的Alpha
- (UIColor *)getNewColorWith:(UIColor *)color alpha:(CGFloat)alpha {
    
    if (self.isHideBg) {
        return UIColor.clearColor;
    }
    if (self.bgColor == UIColor.clearColor) {
        return UIColor.clearColor;
    }
    
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat resAlpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&resAlpha];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
}

- (void)startTimer {
    if (self.showTime > 0) {
        ADTPopViewWK(self);;
        NSString *idStr = [NSString stringWithFormat:@"ADTPopView_%p",self];
        [ADTTimer addMinuteTimerForTime:self.showTime identifier:idStr handle:^(NSString * _Nonnull day, NSString * _Nonnull hour, NSString * _Nonnull minute, NSString * _Nonnull second, NSString * _Nonnull ms) {
            
            if (wk_self.popViewCountDownBlock) {
                wk_self.popViewCountDownBlock(wk_self, [second doubleValue]);
            }
            [wk_self ADT_PopViewCountDownForPopView:wk_self forCountDown:[second doubleValue]];
        } finish:^(NSString * _Nonnull identifier) {
            [wk_self ADT_PopViewCountDownFinishForPopView:wk_self];
            [self dismiss];
        } pause:^(NSString * _Nonnull identifier) {}];
    }
}

/** 删除指定代理 */
- (void)removeForDelegate:(id<ADTPopViewProtocol>)delegate {
    if (delegate) {
        if ([self.delegates containsObject:delegate]) {
            [self.delegates removeObject:delegate];
        }
    }
}

/** 删除代理池 删除所有代理 */
- (void)removeAllDelegate {
    if (self.delegates.count > 0) {
        [self.delegates removeAllObjects];
    }
}

- (void)beginImpactFeedback {
    if (self.isImpactFeedback) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [feedBackGenertor impactOccurred];
        }
    }
}

#pragma mark - ***** 横竖屏改变 *****

- (void)statusBarOrientationChange:(NSNotification *)notification {
    if (self.isObserverScreenRotation) {
        CGRect originRect = self.customView.frame;
        self.frame = CGRectMake(0, 0, pv_ScreenWidth(), pv_ScreenHeight());
        self.backgroundView.frame = self.bounds;
        self.customView.frame = originRect;
        [self setCustomViewFrameWithHeight:0];
    }
}

#pragma mark - ***** 键盘弹出/收回 *****

- (void)keyboardWillShow:(NSNotification *)notification{
    //    ADTPVLog(@"keyboardWillShow");
    _isShowKeyboard = YES;
  
    self.keyboardWillShowBlock? self.keyboardWillShowBlock():nil;
    
    if (!self.isAvoidKeyboard) { return; }
    CGFloat customViewMaxY = self.customView.pv_Bottom + self.avoidKeyboardSpace;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardMaxY = keyboardEedFrame.origin.y;
    self.isAvoidKeyboard = YES;
    self.avoidKeyboardOffset = customViewMaxY - keyboardMaxY;
    self.keyboardY = keyboardEedFrame.origin.y;
    //键盘遮挡到弹窗
    if ((keyboardMaxY<customViewMaxY) || ((_originFrame.origin.y + _customView.pv_Height) > keyboardMaxY)) {
        //执行动画
        [UIView animateWithDuration:duration animations:^{
            self.customView.pv_Y = self.customView.pv_Y - self.avoidKeyboardOffset;
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
    _isShowKeyboard = YES;
    self.keyboardDidShowBlock? self.keyboardDidShowBlock():nil;
}

- (void)keyboardWillHide:(NSNotification *)notification{
   
    _isShowKeyboard = NO;
    self.keyboardWillHideBlock? self.keyboardWillHideBlock():nil;
    if (!self.isAvoidKeyboard) {
        return;
    }
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.customView.pv_Y = self.originFrame.origin.y;
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    _isShowKeyboard = NO;
    self.keyboardDidHideBlock? self.keyboardDidHideBlock():nil;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    //    ADTPVLog(@"键盘frame将要改变");
    if (self.keyboardFrameWillChangeBlock) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.keyboardFrameWillChangeBlock(keyboardBeginFrame,keyboardEedFrame,duration);
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
    //    ADTPVLog(@"键盘frame已经改变");
    if (self.keyboardFrameDidChangeBlock) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.keyboardFrameDidChangeBlock(keyboardBeginFrame,keyboardEedFrame,duration);
    }
    
}

#pragma mark - ***** UIGestureRecognizerDelegate *****

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if(gestureRecognizer == self.panGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if([touchView isKindOfClass:[UIScrollView class]]) {
                self.isDragScrollView = YES;
                self.scrollerView = (UIScrollView *)touchView;
                break;
            } else if(touchView == self.customView) {
                self.isDragScrollView = NO;
                break;
            }
            touchView = (id)[touchView nextResponder];
        }
    }
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer == self.tapGesture) {
        //如果是点击手势
        CGPoint point = [gestureRecognizer locationInView:self.customView];
        BOOL iscontain = [self.customView.layer containsPoint:point];
        if(iscontain) {
            return NO;
        }
    } else if(gestureRecognizer == self.panGesture){
        //如果是自己加的拖拽手势
        //        ADTPVLog(@"gestureRecognizerShouldBegin");
    }
    return YES;
}

//3. 是否与其他手势共存，一般使用默认值(默认返回NO：不与任何手势共存)
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if(gestureRecognizer == self.panGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
            if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
                return YES;
            }
        }
    }
    return NO;
}

//拖拽手势
- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    self.panOffsetBlock?self.panOffsetBlock(CGPointMake(_customView.pv_X-_originFrame.origin.x, _customView.pv_Y-_originFrame.origin.y)):nil;
    
    if (self.dragStyle == ADTDragStyleNO) {return;}
    // 获取手指的偏移量
    CGPoint transP = [panGestureRecognizer translationInView:self.customView];

    CGPoint velocity = [panGestureRecognizer velocityInView:[UIApplication sharedApplication].keyWindow];
    if(self.isDragScrollView) {//含有tableView,collectionView,scrollView
        //如果当前拖拽的是tableView
        if(self.scrollerView.contentOffset.y <= 0) {
            //如果tableView置于顶端
            if(transP.y > 0) {
                //如果向下拖拽
                self.scrollerView.contentOffset = CGPointMake(0, 0);
                self.scrollerView.panGestureRecognizer.enabled = NO;
                self.isDragScrollView = NO;
                //向下拖
                self.customView.frame = CGRectMake(_customView.pv_X, _customView.pv_Y + transP.y, _customView.pv_Width, _customView.pv_Height);
            } else {
                //如果向上拖拽
            }
        }
    } else {//不含有tableView,collectionView,scrollView
        
        CGFloat customViewX = self.customView.pv_X;
        CGFloat customViewY = self.customView.pv_Y;
        //X正方向移动
        if ((self.dragStyle & ADTDragStyleX_Positive) && (customViewX >= _originFrame.origin.x)) {
            if (transP.x > 0) {
                customViewX = customViewX + transP.x;
            } else if(transP.x < 0 && customViewX > _originFrame.origin.x ){
                customViewX = (customViewX + transP.x) > _originFrame.origin.x? (customViewX + transP.x):(_originFrame.origin.x);
            }
        }
        //X负方向移动
        if ((self.dragStyle & ADTDragStyleX_Negative) && (customViewX <= self.originFrame.origin.x)) {
            if (transP.x < 0) {
                customViewX = customViewX + transP.x;
            } else if(transP.x > 0 && customViewX < _originFrame.origin.x ){
                customViewX = (customViewX + transP.x) < _originFrame.origin.x? (customViewX + transP.x):(_originFrame.origin.x);
            }
        }
        //Y正方向移动
        if (self.dragStyle & ADTDragStyleY_Positive && (customViewY >= _originFrame.origin.y)) {
            if (transP.y > 0) {
                customViewY = customViewY + transP.y;
            } else if(transP.y < 0 && customViewY > _originFrame.origin.y ){
                customViewY = (customViewY + transP.y) > _originFrame.origin.y ?(customViewY + transP.y):(_originFrame.origin.y);
            }
        }
        //Y负方向移动
        if (self.dragStyle & ADTDragStyleY_Negative&&(customViewY <= _originFrame.origin.y)) {
            if (transP.y < 0) {
                customViewY = customViewY + transP.y;
            } else if(transP.y > 0 && customViewY < _originFrame.origin.y){
                customViewY = (customViewY + transP.y) < _originFrame.origin.y?(customViewY + transP.y):(_originFrame.origin.y);
            }
        }
        self.customView.frame = CGRectMake(customViewX, customViewY, _customView.pv_Width, _customView.pv_Height);
    }
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self.customView];

    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.scrollerView) {
            self.scrollerView.panGestureRecognizer.enabled = YES;
        }

        ADTPopViewWK(self)
        //拖拽松开回位Block
        void (^dragReboundBlock)(void) = ^ {
            [UIView animateWithDuration:wk_self.dragReboundTime
                                  delay:0.1f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                CGRect frame = wk_self.customView.frame;
                frame.origin.y = wk_self.frame.size.height - wk_self.customView.frame.size.height;
                wk_self.customView.frame = wk_self.originFrame;
            } completion:^(BOOL finished) {}];
        };
        //横扫移除Block
        void (^sweepBlock)(BOOL,BOOL,BOOL,BOOL) = ^(BOOL isX_P, BOOL isX_N, BOOL isY_P, BOOL isY_N) {
            
            if (isX_P==NO && isX_N==NO && isY_P==NO && isY_N==NO) {
                dragReboundBlock();
                return;
            }
            
            if (isY_P==NO && isY_N==NO && self.sweepDismissStyle == ADTSweepDismissStyleSmooth) {//X轴可轻扫
                if (velocity.x>0) {//正向
                    [self dismissWithStyle:ADTDismissStyleSmoothToRight duration:self.dismissDuration];
                } else {//负向
                    [self dismissWithStyle:ADTDismissStyleSmoothToLeft duration:self.dismissDuration];
                }
                return;
            }
            
            if (isX_P==NO && isX_N==NO && self.sweepDismissStyle == ADTSweepDismissStyleSmooth) {//Y轴可轻扫
                if (velocity.y>0) {//正向
                    [self dismissWithStyle:ADTDismissStyleSmoothToBottom duration:self.dismissDuration];
                } else {//负向
                    [self dismissWithStyle:ADTDismissStyleSmoothToTop duration:self.dismissDuration];
                }
                return;
            }
            // 移除，以手势速度飞出
            [UIView animateWithDuration:0.5 animations:^{
                wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
                self.customView.center = CGPointMake(isX_P || isX_N?velocity.x:self.customView.pv_CenterX, isY_P||isY_N?velocity.y:self.customView.pv_CenterY);
            } completion:^(BOOL finished) {
                [wk_self dismissWithStyle:ADTDismissStyleFade duration:0.1];
            }];
        };
        
        double velocityX =  sqrt(pow(velocity.x, 2));
        double velocityY =  sqrt(pow(velocity.y, 2));
        if((velocityX >= self.swipeVelocity)||(velocityY >= self.swipeVelocity)) {//轻扫
            
            if (self.scrollerView.contentOffset.y>0) {
                return;
            }
            
            //可轻扫移除的方向
            BOOL isX_P = NO;
            BOOL isX_N = NO;
            BOOL isY_P = NO;
            BOOL isY_N = NO;
            
            if ((self.dragStyle & ADTDragStyleX_Positive) && velocity.x>0 && velocityX >= self.swipeVelocity) {
                isX_P = self.sweepStyle & ADTSweepStyleX_Positive? YES:NO;
            }
            if ((self.dragStyle & ADTDragStyleX_Negative) && velocity.x<0 && velocityX >= self.swipeVelocity) {
                isX_N = self.sweepStyle & ADTSweepStyleX_Negative? YES:NO;
            }
            
            if ((self.dragStyle & ADTDragStyleY_Positive) && velocity.y>0 && velocityY >= self.swipeVelocity) {
                isY_P = self.sweepStyle & ADTSweepStyleY_Positive? YES:NO;
            }
            if ((self.dragStyle & ADTDragStyleY_Negative) && velocity.y <0 && velocityY >= self.swipeVelocity) {
                isY_N = self.sweepStyle & ADTSweepStyleY_Negative? YES:NO;
            }
            sweepBlock(isX_P,isX_N,isY_P,isY_N);
//            ADTPVLog(@"isX=%@,isY=%@,velocityX=%lf,velocityY=%lf",isX?@"YES":@"NO",isY?@"YES":@"NO",velocityX,velocityY);
        }else {//普通拖拽
            BOOL isCanDismiss = NO;
            if (self.dragStyle & ADTDragStyleAll) {
                
                if (fabs(self.customView.frame.origin.x - self.originFrame.origin.x)>=self.dragDistance && self.dragDistance!=0) {
                    isCanDismiss = YES;
                }
                if (fabs(self.customView.frame.origin.y - self.originFrame.origin.y)>=self.dragDistance && self.dragDistance!=0) {
                    isCanDismiss = YES;
                }
                
                if (isCanDismiss) {
                    [self dismissWithStyle:_isDragDismissStyle? self.dragDismissStyle:self.dismissStyle
                                  duration:self.getDragDismissDuration];
                }else {
                    dragReboundBlock();
                }
            } else {
                dragReboundBlock();
            }
        }
    }
}

#pragma mark - ***** 懒加载 *****

- (NSHashTable<id<ADTPopViewProtocol>> *)delegates {
    if (_delegates) return _delegates;
    _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return _delegates;
}

- (UIView *)parentView {
    return self.container;
}

- (UIView *)currCustomView {
    return self.customView;
}

#pragma mark - ***** 以下是 窗口管理api *****

/** 保存popView */
+ (void)savePopView:(ADTPopView *)popView {
    [ADTPopViewManager savePopView:popView];
}

/** 获取全局(整个app内)所有popView */
+ (NSArray *)getAllPopView {
    return [ADTPopViewManager getAllPopView];
}

/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)parentView {
    return [ADTPopViewManager getAllPopViewForParentView:parentView];
}

/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(ADTPopView *)popView {
    return [ADTPopViewManager getAllPopViewForPopView:popView];
}

/**
 读取popView (有可能会跨编队读取弹窗)
 建议使用getPopViewForGroupId:forkey: 方法进行精确读取
 */
+ (ADTPopView *)getPopViewForKey:(NSString *)key {
    return [ADTPopViewManager getPopViewForKey:key];
}

/** 移除popView */
+ (void)removePopView:(ADTPopView *)popView {
    [ADTPopViewManager removePopView:popView];
}

/**
 移除popView 通过唯一key (有可能会跨编队误删弹窗)
 建议使用removePopViewForGroupId:forkey: 方法进行精确删除
 */
+ (void)removePopViewForKey:(NSString *)key {
    [ADTPopViewManager removePopViewForKey:key];
}

/** 移除所有popView */
+ (void)removeAllPopView {
    [ADTPopViewManager removeAllPopView];
}

/** 移除 最后一个弹出的 popView */
+ (void)removeLastPopView {
    return [ADTPopViewManager removeLastPopView];
}

/** 开启调试view  建议设置成 线上隐藏 测试打开 */
+ (void)setLogStyle:(ADTPopViewLogStyle)logStyle {
    _logStyle = logStyle;
    
    if (logStyle == ADTPopViewLogStyleNO) {
        [ADTPopViewM().infoView removeFromSuperview];
        ADTPopViewM().infoView = nil;
    }
}

@end



