//
//  ADTTimer.m
//  ADTUIKit
//
//  Created by jdm on 6/19/20.
//

#import "ADTTimer.h"


#define ADTPopViewTimerPath(name)  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"ADTTimer_%@_Timer",name]]

@interface ADTPopViewTimerModel : NSObject

/** 毫秒为单位计算 */
@property (nonatomic, assign) NSTimeInterval time;
/** 原始开始时间 毫秒 */
@property (nonatomic, assign) NSTimeInterval oriTime;
/** 进度单位 */
@property (nonatomic, assign) NSTimeInterval unit;
/** 定时器执行block */

/** 是否本地持久化保存定时数据 */
@property (nonatomic,assign) BOOL isDisk;
/** 是否暂停 */
@property (nonatomic,assign) BOOL isPause;
/** 标识 */
@property (nonatomic, copy) NSString *identifier;
/** 通知名称 */
@property (nonatomic, copy) NSString *NFName;
/** 通知类型 0.不发通知 1.毫秒通知 2.秒通知 */
@property (nonatomic, assign) ADTTimerSecondChangeNFType NFType;


@property (nonatomic, copy) ADTTimerChangeBlock handleBlock;
/** 定时器执行block */
@property (nonatomic, copy) ADTTimerFinishBlock finishBlock;
/** 定时器执行block */
@property (nonatomic, copy) ADTTimerPauseBlock pauseBlock;

+ (instancetype)timeInterval:(NSInteger)timeInterval;

@end

@implementation ADTPopViewTimerModel

+ (instancetype)timeInterval:(NSInteger)timeInterval {
    ADTPopViewTimerModel *object = [ADTPopViewTimerModel new];
    object.time = timeInterval*1000;
    object.oriTime = timeInterval*1000;
    return object;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.time forKey:@"timeInterval"];
    [aCoder encodeDouble:self.oriTime forKey:@"oriTime"];
    [aCoder encodeDouble:self.unit forKey:@"unit"];
    [aCoder encodeBool:self.isDisk forKey:@"isDisk"];
    [aCoder encodeBool:self.isPause forKey:@"isPause"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeBool:self.NFType forKey:@"NFType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.time = [aDecoder decodeDoubleForKey:@"timeInterval"];
        self.oriTime = [aDecoder decodeDoubleForKey:@"oriTime"];
        self.unit = [aDecoder decodeDoubleForKey:@"unit"];
        self.isDisk = [aDecoder decodeBoolForKey:@"isDisk"];
        self.isPause = [aDecoder decodeBoolForKey:@"isPause"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.NFType = [aDecoder decodeBoolForKey:@"NFType"];
    }
    return self;
}

@end

@interface ADTTimer ()

@property (nonatomic, strong) NSTimer * _Nullable showTimer;
/** 储存多个计时器数据源 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, ADTPopViewTimerModel *> *timerMdic;


@end

@implementation ADTTimer

static ADTTimer *_instance;


ADTTimer *ADTTimerM() {
    return [ADTTimer sharedInstance];
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

/// 设置倒计时任务的通知回调
/// @param name 通知名
/// @param identifier 倒计时任务的标识
/// @param type 倒计时变化通知类型
+ (void)setNotificationForName:(NSString *)name identifier:(NSString *)identifier changeNFType:(ADTTimerSecondChangeNFType)type  {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return;
    }
    ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
    if (model) {
        model.NFType = type;
        model.NFName = name;
        return;
    }else {
        NSLog(@"找不到计时器任务");
        return;
    }
}


/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time handle:(ADTTimerChangeBlock)handle {
    [self initTimerForForTime:time identifier:nil ForIsDisk:NO unit:0 handle:handle finish:nil pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(ADTTimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:-1
                        handle:handle
                        finish:nil
                         pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(ADTTimerChangeBlock)handle
                 finish:(ADTTimerFinishBlock)finishBlock
                  pause:(ADTTimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:-1
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

/** 添加定时器并开启计时 */
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(ADTTimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:-1
                        handle:handle
                        finish:nil
                         pause:nil];
}

/** 添加定时器并开启计时 */
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(ADTTimerChangeBlock)handle
                     finish:(ADTTimerFinishBlock)finishBlock
                      pause:(ADTTimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:-1
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}


/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time handle:(ADTTimerChangeBlock)handle {
     [self initTimerForForTime:time identifier:nil ForIsDisk:NO unit:1000 handle:handle finish:nil pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(ADTTimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:1000
                        handle:handle
                        finish:nil
                         pause:nil];
}

/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(ADTTimerChangeBlock)handle
                       finish:(ADTTimerFinishBlock)finishBlock
                        pause:(ADTTimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:1000
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

/** 添加定时器并开启计时 */
+ (void)addDiskMinuteTimerForTime:(NSTimeInterval)time
                       identifier:(NSString *)identifier
                           handle:(ADTTimerChangeBlock)handle
                           finish:(ADTTimerFinishBlock)finishBlock
                            pause:(ADTTimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:1000
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

//总初始化入口
+ (void)initTimerForForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                  ForIsDisk:(BOOL)isDisk
                       unit:(NSTimeInterval)unit
                     handle:(ADTTimerChangeBlock)handle
                     finish:(ADTTimerFinishBlock)finishBlock
                      pause:(ADTTimerPauseBlock)pauseBlock {
    
    if (identifier.length<=0) {
        ADTPopViewTimerModel *model = [ADTPopViewTimerModel timeInterval:time];
        model.isDisk = isDisk;
        model.identifier = [NSString stringWithFormat:@"%p",model];
        model.unit = unit;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [ADTTimerM().timerMdic setObject:model forKey:model.identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
          
        }
        // 发出通知
        if (model.NFType != ADTTimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
             [self savaForTimerModel:model];
        }
        [self initTimer];
        return;
    }
    
        
    BOOL isTempDisk = [ADTTimer timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = ADTTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    
    if (!isRAM && !isTempDisk) {//新任务
        ADTPopViewTimerModel *model = [ADTPopViewTimerModel timeInterval:time];
        model.handleBlock = handle;
        model.isDisk = isDisk;
        model.identifier = identifier;
        model.unit = unit;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [ADTTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            if (model.isDisk) {
                [self savaForTimerModel:model];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        // 发出通知
        if (model.NFType != ADTTimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        [self initTimer];
    }
    
    
    if (isRAM && !isTempDisk) {//内存任务
        ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
        model.isPause = NO;
        model.handleBlock = handle;
        model.isDisk = isDisk;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
//         [self initTimer];
    }
    
    if (!isRAM && isTempDisk) {//硬盘的任务
        ADTPopViewTimerModel *model = [ADTTimer getTimerModelForIdentifier:identifier];
        if (isDisk == NO) {
            [ADTTimer deleteForIdentifier:identifier];
        }
        model.isPause = NO;
        model.isDisk = isDisk;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [ADTTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
           
        }
        // 发出通知
        if (model.NFType != ADTTimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
        [self initTimer];
    }
    
    if (isRAM && isTempDisk) {//硬盘的任务
        ADTPopViewTimerModel *model = [ADTTimer getTimerModelForIdentifier:identifier];
        model.isPause = NO;
        if (isDisk == NO) {
            [ADTTimer deleteForIdentifier:identifier];
        }
        model.isDisk = isDisk;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [ADTTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        // 发出通知
        if (model.NFType != ADTTimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
//        [self initTimer];
    }
    
}

+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        return 0.0;
    }
    
    BOOL isTempDisk = [ADTTimer timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = ADTTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    
    
    if (isTempDisk) {
        ADTPopViewTimerModel *model = [ADTTimer loadTimerForIdentifier:identifier];
        return model.oriTime - model.time;
    }else if (isRAM) {
        ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
        return model.oriTime - model.time;
    }else {
        NSLog(@"找不到计时任务");
        return 0.0;
    }
    
}

+ (BOOL)pauseTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
    
    if (model) {
        model.isPause = YES;
        if (model.pauseBlock) { model.pauseBlock(model.identifier); }
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
}

+ (void)pauseAllTimer {
    [ADTTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, ADTPopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = YES;
        if (obj.pauseBlock) { obj.pauseBlock(obj.identifier); }
    }];
}

+ (BOOL)restartTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    //只有内存任务才能重启, 硬盘任务只能调用addTimer系列方法重启
    BOOL isRAM = ADTTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    if (isRAM) {
        ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
        model.isPause = NO;
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
    
    
}
+ (void)restartAllTimer {
    
    if (ADTTimerM().timerMdic.count<=0) {
        return;
    }
    
    [ADTTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, ADTPopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = NO;
    }];
}

+ (BOOL)resetTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    //只有内存任务才能重启, 硬盘任务只能调用addTimer系列方法重启
    BOOL isRAM = ADTTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    if (isRAM) {
        ADTPopViewTimerModel *model = ADTTimerM().timerMdic[identifier];
        model.isPause = NO;
        model.time = model.oriTime;
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
}

+ (void)resetAllTimer {
    if (ADTTimerM().timerMdic.count<=0) {
        return;
    }
    
    [ADTTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, ADTPopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = NO;
        obj.time = obj.oriTime;
        if (obj.handleBlock) {
            NSInteger totalSeconds = obj.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(obj.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            obj.handleBlock(days,hours,minute,second,ss);
          
        }
    }];
}

+ (BOOL)removeTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    [ADTTimerM().timerMdic removeObjectForKey:identifier];
    if (ADTTimerM().timerMdic.count<=0) {//如果没有计时任务了 就销毁计时器
        [ADTTimerM().showTimer invalidate];
        ADTTimerM().showTimer = nil;
    }
    return YES;
}

+ (void)removeAllTimer {
    [ADTTimerM().timerMdic removeAllObjects];
    [ADTTimerM().showTimer invalidate];
    ADTTimerM().showTimer = nil;
}

/** increase YES: 递增 NO: 递减   */
+ (void)initTimer {
    
    if (ADTTimerM().showTimer) {
        return;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01f target:ADTTimerM() selector:@selector(timerChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    ADTTimerM().showTimer = timer;
    
}

- (void)timerChange {
    // 时间差+
    [ADTTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, ADTPopViewTimerModel *obj, BOOL *stop) {
        if (!obj.isPause) {
            
            obj.time = obj.time-10.0;
            
            if (obj.unit>-1) {
                obj.unit = obj.unit-10.0;
            }
            
            if (obj.time<0) {//计时结束
                obj.time = 0;
                obj.isPause = YES;
            }
            NSInteger totalSeconds = obj.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(obj.time))%1000/10;
            NSString *ms = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ms.integerValue < 10) {
                ms = [NSString stringWithFormat:@"0%@", ms];
            }
            
            
            
            if (obj.unit<=-1) {
                if (obj.handleBlock) {obj.handleBlock(days,hours,minute,second,ms);}
                
                if (obj.NFType == ADTTimerSecondChangeNFTypeMS) {
                    // 发出通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:obj.NFName object:nil userInfo:nil];
                }
            }else if (obj.unit == 0) {
                if (obj.handleBlock) {obj.handleBlock(days,hours,minute,second,ms);}
                obj.unit = 1000;
                if (obj.NFType == ADTTimerSecondChangeNFTypeSecond) {
                    // 发出通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:obj.NFName object:nil userInfo:nil];
                }
            }
            
            if (obj.isDisk) {
                [ADTTimer savaForTimerModel:obj];
            }
            
            if (obj.time<=0) {//计时器计时完毕自动移除计时任务
                if (obj.finishBlock) { obj.finishBlock(obj.identifier); }
                [ADTTimerM().timerMdic removeObjectForKey:obj.identifier];
                [ADTTimer deleteForIdentifier:obj.identifier];
            }
            
        }
    }];
  
}

- (NSMutableDictionary<NSString *,ADTPopViewTimerModel *> *)timerMdic {
    if(_timerMdic) return _timerMdic;
    _timerMdic = [NSMutableDictionary dictionary];
    return _timerMdic;
}



#pragma mark - ***** other *****

+ (BOOL)timerIsExistInDiskForIdentifier:(NSString *)identifier {
    NSString *filePath = ADTPopViewTimerPath(identifier);
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return isExist;
}

/** 格式化时间  */
+ (void)formatDateForTime:(NSTimeInterval)time handle:(ADTTimerChangeBlock)handle {
    if (handle) {
        NSInteger totalSeconds = time/1000.0;
        NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
        NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
        NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
        NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
        CGFloat sss = ((NSInteger)(time))%1000/10;
        NSString *ms = [NSString stringWithFormat:@"%.lf", sss];
        
        if (hours.integerValue < 10) {
            hours = [NSString stringWithFormat:@"0%@", hours];
        }
        if (minute.integerValue < 10) {
            minute = [NSString stringWithFormat:@"0%@", minute];
        }
        if (second.integerValue < 10) {
            second = [NSString stringWithFormat:@"0%@", second];
        }
        if (ms.integerValue < 10) {
            ms = [NSString stringWithFormat:@"0%@", ms];
        }
        
        handle(days,hours,minute,second,ms);
    }
}


+ (BOOL)savaForTimerModel:(ADTPopViewTimerModel *)model {
    NSString *filePath = ADTPopViewTimerPath(model.identifier);
    return [NSKeyedArchiver archiveRootObject:model toFile:filePath];
}

+ (ADTPopViewTimerModel *)loadTimerForIdentifier:(NSString *)identifier{
    NSString *filePath = ADTPopViewTimerPath(identifier);
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (BOOL)deleteForIdentifier:(NSString *)identifier {
    NSString *filePath = ADTPopViewTimerPath(identifier);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (ADTPopViewTimerModel *)getTimerModelForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        return nil;
    }
    ADTPopViewTimerModel *model = [ADTTimer loadTimerForIdentifier:identifier];
    return model;
    
}


@end
