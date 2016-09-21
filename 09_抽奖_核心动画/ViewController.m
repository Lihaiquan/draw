/**
 * 项目1:         仿360wifi抽奖(本程序)
 * 项目2:         转盘式抽奖(待续)
 * 疑问:          1.效率不高; 2.中奖概率没有控制...
 * 建议bug:       373866166@qq.com
 * QQGroup:      484746059 2货大叔 2015-12-24
 * 题外:          图片资源为截屏,抠图获得,不懂PS所以...太糙de大叔还自己ppt画了抽奖大转盘原理图
 */

#import "ViewController.h"

@interface ViewController ()
#pragma mark - 定义属性
/** 奖项 */
@property (nonatomic, strong)   NSArray *awards;

/** 大转盘 */
@property (nonatomic, weak)     UIImageView *wheelView;

/** 开始按钮 */
@property (nonatomic, weak)     UIButton *startButton;

/** 旋转的起始角度 */
@property (nonatomic, assign)   CGFloat beginAngle;

/** 旋转的终止角度 */
@property (nonatomic, assign)   CGFloat endAngle;

/** 随机整数 */
@property (nonatomic, assign)   NSInteger intRandom;
@property (nonatomic,assign) CGFloat duringTime;
@property (nonatomic,strong)CABasicAnimation* rotationAnimation;

@property (nonatomic,assign)double beginTime;
@property (nonatomic,assign)double endTime;
@end

@implementation ViewController

#pragma mark - 主要方法

/** 属性延迟加载:奖项设置 */
- (NSArray *)awards{
    if (!_awards) {
        // 奖项的min和max区间由奖项在圆上分配多少决定。
        // 中奖和没中奖之间的分隔线设有1个弧度的盲区，指针不会旋转到的，避免抽奖的时候起争议。
        //        _awards = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"award.plist" ofType:nil]];
        _awards = @[
                    @{@"min" : @1,      @"max" : @29,     @"title" : @"满200减去200"},
                    @{@"min" : @31,     @"max" : @59,     @"title" : @"天天炫舞"},
                    @{@"min" : @61,     @"max" : @89,     @"title" : @"涂油斗地主"},
                    @{@"min" : @91,     @"max" : @119,    @"title" : @"300金币"},
                    @{@"min" : @121,    @"max" : @149,    @"title" : @"20元代金券"},
                    @{@"min" : @151,    @"max" : @179,    @"title" : @"50金币"},
                    @{@"min" : @181,    @"max" : @209,    @"title" : @"钟繇之怒"},
                    @{@"min" : @211,    @"max" : @239,    @"title" : @"星际传奇"},
                    @{@"min" : @241,    @"max" : @269,    @"title" : @"360独家"},
                    @{@"min" : @271,    @"max" : @299,    @"title" : @"100金币"},
                    @{@"min" : @301,    @"max" : @329,    @"title" : @"360M空间"},
                    @{@"min" : @331,    @"max" : @359,    @"title" : @"10金币"},
                    ];
    }
    return _awards;
}

/** 控制器完成view加载 */
- (void)viewDidLoad{
    [super viewDidLoad];
    
    // 设置控制器view参数
    self.view.backgroundColor = [UIColor orangeColor];
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height;
    
    // 创建大转盘并设置参数
    UIImageView *wheelView = [[UIImageView alloc] init];
    wheelView.image = [UIImage imageNamed:@"360wheel"];
    wheelView.bounds = CGRectMake(0, 0, w, w);
    wheelView.center = CGPointMake(w * 0.5, h * 0.5);
    [self.view addSubview:wheelView];
    self.wheelView = wheelView;
    
    // 创建开始按钮并设置参数
    UIButton *wheelButton = [[UIButton alloc] init];
    [wheelButton setImage:[UIImage imageNamed:@"360button"] forState:UIControlStateNormal];
    wheelButton.center = self.wheelView.center;
    wheelButton.bounds = CGRectMake(0, 0, 120, 120); // 按钮尺寸缩小试试看 -..-
    [wheelButton addTarget:self action:@selector(wheelButtonClick:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:wheelButton];
    self.startButton = wheelButton;
}

/** 监听开始按钮 */
- (void)wheelButtonClick:(UIButton *)btn{

    NSDate *date = [NSDate date];
    _beginTime = date.timeIntervalSince1970;
    // 健壮性判断
    if (!self.awards.count) return;

    // 关闭按钮响应
    btn.userInteractionEnabled = NO;
    
    // 转弧度制后返回
    [self.wheelView.layer removeAllAnimations];
    

    // 创建核心动画
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//     _rotationAnimation.delegate = self;
    _rotationAnimation.fromValue = @(0.0);   // 旋转的起始角度
    _rotationAnimation.beginTime = 0;
    _rotationAnimation.toValue = @(2.0*M_PI);       // 旋转的终止角度
    _rotationAnimation.duration = 1.0;    // 动画持续时间
    _rotationAnimation.repeatCount = 100;
    _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];           // 淡入淡出效果
//    _rotationAnimation.removedOnCompletion = NO;         // 不移除动画完成后的效果
    _rotationAnimation.fillMode = kCAFillModeBoth;       // 保持
    
    // 添加动画到开始按钮上
    self.wheelView.layer.speed = 1.0;
    self.wheelView.layer.timeOffset =   CACurrentMediaTime();


    [self.wheelView.layer addAnimation:_rotationAnimation forKey:@"ViewAnimation"];

    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0];
    
    
}
- (void)delayMethod
{
   
    _duringTime = 1/24.0 + 1/12.0 *(arc4random()%12);//代表转30度角＊随机整数倍角度后停止
    
    if (_duringTime < 1.0) {
        _duringTime += 1.0;
    }

    NSDate *date = [NSDate date];
    _endTime = date.timeIntervalSince1970;
    NSLog(@"动画持续时间1＝%f",_endTime - _beginTime);
//    CFTimeInterval pausedTime = [self.wheelView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
//    _rotationAnimation.delegate = self;
    _rotationAnimation.fromValue = @((_endTime - _beginTime)*2.0*M_PI );   // 旋转的起始角度
    _rotationAnimation.toValue = @(2.0*M_PI *(_duringTime + _endTime - _beginTime));       // 旋转的终止角度
    _rotationAnimation.duration = 2.0 *_duringTime ;    // 动画持续时间
    _rotationAnimation.repeatCount = 1;
    _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    _rotationAnimation.removedOnCompletion = NO;
    [self.wheelView.layer addAnimation:_rotationAnimation forKey:@"ViewAnimation"];
    self.startButton.userInteractionEnabled = YES;
 
//    [self performSelector:@selector(stopAnination) withObject:nil afterDelay:_duringTime];
    
}

- (void)stopAnination
{
     NSDate *date = [NSDate date];
    _endTime = date.timeIntervalSince1970;
    NSLog(@"动画持续时间＝%f",_endTime - _beginTime);

    CFTimeInterval pausedTime = [self.wheelView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    NSLog(@"currentTime = %f",pausedTime);
    self.rotationAnimation.speed = 0;
    self.wheelView.layer.speed = 0;
    self.wheelView.layer.timeOffset =   pausedTime;
    self.startButton.userInteractionEnabled = YES;

}


#pragma mark - 核心动画代理方法
/** 动画代理方法:动画播放完毕调用 */
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

 }

#pragma mark - 私有工具方法
/** 随机获取旋转的角度 */
- (CGFloat)angleRandom{
    // 获取随机整数(奖项数量以内)
    //    self.intRandom = arc4random() % self.awards.count;
    srand((unsigned)time(NULL));
    self.intRandom = rand() % self.awards.count;
    
    // 健壮性判断
    if (self.intRandom >= self.awards.count) return 0;
    
    // 取出这个奖项所在的角度
    NSDictionary *angleDict = self.awards[self.intRandom];
    int min = [angleDict[@"min"] intValue];
    int max = [angleDict[@"max"] intValue];
    
    // 获取随机角度(介于min与max之间)
    CGFloat angleRandom = arc4random() % (max - min) + min;
    
    // 360*5代表多圈旋转增添逼真效果
    // 注:如果让中心指针旋转那么计算的角度为angleRandom而不是(360 - angleRandom).
    CGFloat angle = ((360 - angleRandom) + 360 * 10.0);
    
    // 转弧度制后返回
    return [self angleRadian:angle];
}

/** 角度值转弧度制 */
- (CGFloat)angleRadian:(CGFloat)angle{
    return angle * M_PI / 180;
}

/**显示AlertView*/
- (void)alertViewShowMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抽奖结果" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

@end
