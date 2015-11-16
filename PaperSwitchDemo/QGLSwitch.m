//
//  QGLSwitch.m
//  PaperSwitchDemo
//
//  Created by 求攻略 on 15/11/16.
//  Copyright © 2015年 mobmaxime. All rights reserved.
//

#import "QGLSwitch.h"

@interface QGLSwitch() {
    
    double duration;
}

@property (nonatomic,strong) CAShapeLayer *shape;
@property (nonatomic,assign) CGFloat redius;
@property (nonatomic,assign) BOOL oldState;


@end

@implementation QGLSwitch

-(instancetype)init{
    if(self = [super init]) {
        [self initParame];
    }
    return self;
}

- (CAShapeLayer *)shape {
    if(!_shape) {
        _shape = [[CAShapeLayer alloc] init];
    }
    return _shape;
}
- (void)setOn:(BOOL)on {
    [super setOn:on];
    self.oldState = on;
}

- (void) initParame {
    self.redius = 0;
    self.oldState = NO;
    duration = 0.35;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    BOOL changed = on != self.on;
    
    [super setOn:on animated:animated];
    
    if(changed) {
        [self switchChanged];
    }else {
        [self showShapeIfNeed];
    }
}

- (void)awakeFromNib {
    
    [self initParame];
    
    UIColor *shapColor = self.onTintColor ? self.onTintColor : [UIColor greenColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = self.frame.size.height / 2.0f;
    
    self.shape.fillColor = shapColor.CGColor;
    self.shape.masksToBounds = YES;
    
    [self.superview.layer insertSublayer:self.shape atIndex:0];
    self.superview.layer.masksToBounds = YES;
    
    [self showShapeIfNeed];
    
    [self addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    
    [super awakeFromNib];
}

-(void)layoutSubviews {
    
    CGFloat x = MAX(CGRectGetMidX(self.frame), self.superview.frame.size.width - CGRectGetMidX(self.frame));
    CGFloat y = MAX(CGRectGetMidY(self.frame), self.superview.frame.size.height - CGRectGetMidY(self.frame));
    
    self.redius = sqrt(x*x + y*y);
    
    self.shape.frame = CGRectMake(CGRectGetMidX(self.frame)-self.redius, CGRectGetMidY(self.frame)-self.redius, self.redius * 2, self.redius * 2);
    self.shape.anchorPoint = CGPointMake(0.5, 0.5);
    self.shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.redius*2, self.redius*2)].CGPath;
}

- (void) switchChanged {
    if(self.on == self.oldState) {
        return;
    }
    
    self.oldState = self.on;
    
    if(self.on) {
        [CATransaction begin];
        
        [self.shape removeAnimationForKey:@"scaleDown"];
        
        CABasicAnimation *scaleAnimation = [self animateKeyPath:@"transform"
                                                      fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0001, 0.0001, 0.0001)]
                                                        toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)] timing:kCAMediaTimingFunctionEaseIn];
        
        [self.shape addAnimation:scaleAnimation forKey:@"scaleUp"];
        
        [CATransaction commit];
    } else {
        [CATransaction begin];
        
        [self.shape removeAnimationForKey:@"scaleUp"];
        
        CABasicAnimation *scaleAnimation = [self animateKeyPath:@"transform"
                                                      fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]
                                                        toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0001, 0.0001, 0.0001)] timing:kCAMediaTimingFunctionEaseOut];
        
        [self.shape addAnimation:scaleAnimation forKey:@"scaleDown"];
        
        [CATransaction commit];
    }
}

- (CABasicAnimation *)animateKeyPath:(NSString *)keyPath  fromValue:(id)from toValue:(id)to timing:(NSString *)timingFunction{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = from;
    animation.toValue = to;
    animation.repeatCount = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = duration;
    animation.delegate = self;
    
    return animation;
}

- (void) showShapeIfNeed {
    self.shape.transform = self.on ? CATransform3DMakeScale(1.0, 1.0, 1.0) : CATransform3DMakeScale(0.0001, 0.0001, 0.0001);
}


@end
