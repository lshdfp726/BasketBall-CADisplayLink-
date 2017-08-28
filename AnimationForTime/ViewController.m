//
//  ViewController.m
//  AnimationForTime
//
//  Created by fns on 2017/8/28.
//  Copyright © 2017年 lsh726. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (nonatomic, strong) UIImageView *ballView;
@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CFTimeInterval timeOffset;
@property (nonatomic, assign) CFTimeInterval lastStep;
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ballView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"basketBall.jpeg"]];
    self.ballView.contentMode = UIViewContentModeScaleAspectFit;
    self.ballView.frame = CGRectMake(0, 0, 50, 50);
    self.ballView.center = self.containView.center;
    [self.containView addSubview:self.ballView];
    [self animate];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self animate];
}


- (void)animate {
    self.ballView.center = self.containView.center;
    self.duration = 1.0;
    self.timeOffset = 0.0;
    self.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.containView.center.x, 0)];
    self.toValue   = [NSValue valueWithCGPoint:CGPointMake(self.containView.center.x, self.containView.center.y)];
    [self.timer invalidate];
    self.lastStep = CACurrentMediaTime();
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


//单位时间动作
- (void)step:(CADisplayLink *)setp {
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval setpDuration = thisStep - self.lastStep;
    self.lastStep = thisStep;
    
    self.timeOffset = MIN(self.timeOffset + setpDuration, self.duration);
    float time = self.timeOffset / self.duration;
    
    time = bounceEaseOut(time);
    id position = [self interpolateFromValue:self.fromValue toValue:self.toValue
                                        time:time];
    //move ball view to new position
    self.ballView.center = [position CGPointValue];
    //stop the timer if we've reached the end of the animation
    if (self.timeOffset >= self.duration) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


//弹性公式（专业人士总结出来的）
float bounceEaseOut(float t) {
    if (t < 4/11.0) {
        return (121 * t * t)/16.0;
    } else if (t < 8/11.0) {
        return (363/40.0 * t * t) - (99/10.0 * t) + 17/5.0;
    } else if (t < 9/10.0) {
        return (4356/361.0 * t * t) - (35442/1805.0 * t) + 16061/1805.0;
    }
    return (54/5.0 * t * t) - (513/25.0 * t) + 268/25.0;
}


//可以理解为运动轨迹
float interpolate(float from, float to, float time) {
    return (to - from) * time + from;
}


- (id)interpolateFromValue:(id)fromValue toValue:(id)toValue time:(float)time {
    if ([fromValue isKindOfClass:[NSValue class]]) {
        const char *type = [(NSValue *)fromValue objCType];
        if (strcmp(type, @encode(CGPoint)) == 0) {
            CGPoint from = [fromValue CGPointValue];
            CGPoint to   = [toValue CGPointValue];
            CGPoint result = CGPointMake(interpolate(from.x, to.x, time), interpolate(from.y, to.y, time));
            return [NSValue valueWithCGPoint:result];
        }
    }
    return (time < 0.5)?fromValue:toValue;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
