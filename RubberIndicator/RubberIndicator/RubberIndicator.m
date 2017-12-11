//
//  RubberIndicator.m
//  RubberIndicator
//
//  Created by Mayqiyue on 3/29/16.
//  Copyright © 2016 mayqiyue. All rights reserved.
//

#import "RubberIndicator.h"

typedef NS_ENUM(NSUInteger, MoveDirection) {
    MoveLeft = 0,
    MoveRight = 1,
};

@interface Bubble : UIView

@property(nonatomic, strong) UIImage *image;

- (void)refreshImage:(UIImage *)newImage withDuration:(CGFloat)duration;

- (void)translateToPosition:(CGPoint)position
                   duration:(CGFloat)duration
                  beginTime:(CFTimeInterval)beginTime
             withCompletion:(void(^)(void))completion;

- (void)translateWithRotateAndShake:(MoveDirection)direction
                             radius:(CGFloat)radius
                           duration:(CGFloat)duration
                          beginTime:(CFTimeInterval)beginTime;

@end


#pragma mark- RubberIndicator class

@interface RubberIndicator ()
{
    BOOL _inited;
    CGFloat startX;
}

@property(nonatomic, assign) NSUInteger selectedIndex;

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIView *backLineView;
@property(nonatomic, strong) CAShapeLayer *selectedItemBoxLayer;

@property(nonatomic, assign) NSUInteger itemCount;
@property(nonatomic, strong) NSMutableArray <Bubble *> *itemViews;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesure;

@property(nonatomic, strong) NSMutableArray <NSString *> *titles;
@property(nonatomic, strong) NSMutableArray <UIImage *> *images;

@end

@implementation RubberIndicator

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (_inited) {
        return;
    }
    _inited = YES;
    
    self.contentInsets         = UIEdgeInsetsZero;
    self.itemSize              = 16.0f;
    self.selectedItemSize      = 20.0f;
    self.itemInternalSpacing   = 15.0f;
    self.animationDuration     = 0.2f;
    self.selectedIndex         = 0;
    self.selectedItemTintColor = [UIColor colorWithRed:31.0f/255.0f green:183/255.0f blue:215.0f/255.0f alpha:1.0f];
    self.backLineViewColor     = [UIColor colorWithRed:27.0f/255.0f green:63/255.0f blue:70.0f/255.0f alpha:1.0f];
    
    self.itemViews = [[NSMutableArray alloc] init];
    self.titles = [[NSMutableArray alloc] init];
    
    [self configureContentView];
}

- (void)configureContentView
{
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.clipsToBounds = NO;
    [self addSubview:self.contentView];
    
    self.tapGesure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.contentView addGestureRecognizer:self.tapGesure];
}

- (void)configureBackLineView
{
    CGSize extendInset = CGSizeMake(7.0f, 7.0f);
    self.backLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (_itemCount - 1) * (_itemSize + _itemInternalSpacing) + _selectedItemSize + extendInset.width*2.0f, _itemSize + extendInset.height * 2.0f)];
    self.backLineView.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    self.backLineView.backgroundColor = self.backLineViewColor;
    self.backLineView.layer.cornerRadius = self.backLineView.bounds.size.height/2.0f;
    
    [self.contentView insertSubview:self.backLineView atIndex:0];
}

- (void)configureSelectedItemBoxView
{
    CGFloat outsideBoxSize = 10.0f;
    CGFloat insideBoxSize = 5.0f;
    
    Bubble *selectedBubble = self.itemViews[self.selectedIndex];
    selectedBubble.clipsToBounds = NO;
    
    CGRect outsideFrame = CGRectMake(-outsideBoxSize,
                                     -outsideBoxSize,
                                     _selectedItemSize+2.0f*outsideBoxSize,
                                     _selectedItemSize+2.0f*outsideBoxSize);
    CGRect insideFrame = CGRectMake(-insideBoxSize,
                                    -insideBoxSize,
                                    _selectedItemSize+2.0f*insideBoxSize,
                                    _selectedItemSize+2.0f*insideBoxSize);
    
    CAShapeLayer *(^createCircleLayer)(CGRect, UIColor *) = ^(CGRect rect, UIColor *fillColor) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
        layer.fillColor = fillColor.CGColor;
        layer.strokeColor = fillColor.CGColor;
        layer.lineWidth = 1.0f;
        return layer;
    };
    
    CAShapeLayer *outsideLayer = createCircleLayer(outsideFrame, self.backLineViewColor);
    CAShapeLayer *insideLayer = createCircleLayer(insideFrame, self.selectedItemTintColor);
    
    [outsideLayer addSublayer:insideLayer];
    [selectedBubble.layer insertSublayer:outsideLayer atIndex:0];
    
    self.selectedItemBoxLayer = outsideLayer;
}

#pragma mark- Public

- (void)selectIndex:(NSUInteger)index
{
    if ([self shouldChangetoIndex:index]) {
        [self changeToIndex:index];
    }
}

- (void)selectIndexForcibly:(NSUInteger)index
{
    [self changeToIndex:index];
}

#pragma mark - Event responese

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture
{
    NSUInteger index = [self tappedItemViewIndex:[tapGesture locationInView:tapGesture.view]];
    if (index != NSNotFound && [self shouldChangetoIndex:index]) {
        [self changeToIndex:index];
    }
}

- (NSUInteger)tappedItemViewIndex:(CGPoint)point
{
    static CGFloat extendWidth = 10.0f;
    if (point.x < self.itemViews[0].frame.origin.x - extendWidth ||
        point.x > self.itemViews.lastObject.frame.origin.x + self.itemViews.lastObject.frame.size.width + extendWidth) {
        // Out of the tap area.
        return  NSNotFound;
    }
    
    // Find out the nearest item to tap location.
    NSUInteger targetIndex = 0;
    CGFloat shortestDistance = CGFLOAT_MAX;
    for (Bubble *item in self.itemViews) {
        CGFloat distance = fabs(point.x - item.center.x);
        if (distance <= shortestDistance) {
            shortestDistance = distance;
            targetIndex = [self.itemViews indexOfObject:item];
        }
    }
    return targetIndex;
}

#pragma mark - Change position

- (BOOL)shouldChangetoIndex:(NSUInteger)index
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(shoulSelectIndicatorAtIndex:indicator:)]) {
        return [self.dataSource shoulSelectIndicatorAtIndex:index indicator:self];
    }
    else {
        return YES;
    }
}

- (void)changeToIndex:(NSInteger)index
{
    if (index != self.selectedIndex) {
        self.tapGesure.enabled = NO;
        [self executeAnimations:index completion:^{
            self.tapGesure.enabled = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectIndicatorAtIndex:indicator:)]) {
                [self.delegate didSelectIndicatorAtIndex:index indicator:self];
            }
        }];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectIndicatorAtIndex:indicator:)]) {
            [self.delegate didSelectIndicatorAtIndex:index indicator:self];
        }
    }
    self.selectedIndex = index;
}

- (void)executeAnimations:(NSInteger)index completion:(void(^)())completion
{
    // Animate main bubble
    Bubble *mainBubble = self.itemViews[self.selectedIndex];
    CGPoint toPoint = CGPointMake(startX + index * (_itemSize + _itemInternalSpacing) + _selectedItemSize*0.5f, mainBubble.center.y);
    [mainBubble translateToPosition:toPoint duration:self.animationDuration beginTime:CACurrentMediaTime() withCompletion:completion];
    
    // Animate small bubbles
    void(^changeSmallBubbleBlock)(NSUInteger) = ^(NSUInteger integer) {
        [self.itemViews[integer] translateWithRotateAndShake:(index > self.selectedIndex) ? MoveLeft : MoveRight
                                                      radius:0.5f * (_selectedItemSize + self.itemInternalSpacing)
                                                    duration:self.animationDuration
                                                   beginTime:CACurrentMediaTime()];
    };
    if (index > self.selectedIndex) {
        for (NSUInteger i = self.selectedIndex + 1; i <= index; i++) {
            changeSmallBubbleBlock(i);
        }
    }
    else {
        for (NSUInteger i = index; i <= self.selectedIndex-1; i++) {
            changeSmallBubbleBlock(i);
        }
    }
    
    // Re sort item views arrry
    [self.itemViews removeObject:mainBubble];
    [self.itemViews insertObject:mainBubble atIndex:index];
    
    // Refresh images
    for (Bubble *bubble in self.itemViews) {
        [bubble refreshImage:[UIImage imageNamed:self.titles[[self.itemViews indexOfObject:bubble]]]
                withDuration:self.animationDuration*0.5f];
    }
}

#pragma mark - Datasource

- (void)setDelegate:(id<RubberIndicatorDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        if ([_delegate respondsToSelector:@selector(numberOfIndicatorsForRubberIndicator:)] &&
            [_delegate respondsToSelector:@selector(titleOfIndicatorsAtIndex:indicator:)]) {
            [self reloadData];
        }
    }
}

- (void)reloadData
{
    // Clear current state
    [self.itemViews removeAllObjects];
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.itemCount = [self.dataSource numberOfIndicatorsForRubberIndicator:self];
    self.titles = [[NSMutableArray alloc] initWithCapacity:self.itemCount];
    
    for (NSUInteger i = 0; i < self.itemCount; i++) {
        Bubble *item = [self itemViewAtIndex:i];
        
        [self.itemViews addObject:item];
        [self.contentView addSubview:item];
    }
    
    [self configureBackLineView];
    [self configureSelectedItemBoxView];
}

- (Bubble *)itemViewAtIndex:(NSUInteger)index
{
    startX = (self.contentView.bounds.size.width - (_itemCount - 1) * (_itemSize + _itemInternalSpacing) - _selectedItemSize)/2.0f;
    CGFloat x = startX + index * (_itemSize + _itemInternalSpacing);
    if (index > self.selectedIndex) {
        x += _selectedItemSize - _itemSize;
    }
    
    CGRect frame = CGRectMake(x, 0.5f * (self.contentView.bounds.size.height-_itemSize), _itemSize, _itemSize);
    if (index == self.selectedIndex) {
        frame = CGRectMake(x, 0.5f * (self.contentView.bounds.size.height-_selectedItemSize), _selectedItemSize, _selectedItemSize);
    }
    
    NSString *title = [_dataSource titleOfIndicatorsAtIndex:index indicator:self];
    [self.titles insertObject:title atIndex:index];
    
    Bubble *item = [[Bubble alloc] initWithFrame:frame];
    item.image = [UIImage imageNamed:title];
    
    return item;
}

@end

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

#pragma mark- Bubble class

static NSString *const kPropPosition           = @"position";
static NSString *const kPropPositionY          = @"position.y";
static NSString *const kPropTransform          = @"transform";
static NSString *const kPropTransformRotationZ = @"transform.rotation.z";

@implementation Bubble
{
    UIImageView *imageView;
    
    MoveDirection _direction;
    CGFloat _radius;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
}

- (void)setImage:(UIImage *)image
{
    imageView.image = image;
}

#pragma mark - Public

- (void)refreshImage:(UIImage *)newImage withDuration:(CGFloat)duration
{
    [UIView transitionWithView:imageView
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        imageView.image = newImage;
                    } completion:^(BOOL finished) {
                    }];
}

- (void)translateToPosition:(CGPoint)position
                   duration:(CGFloat)duration
                  beginTime:(CFTimeInterval)beginTime
             withCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = position;
                     } completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)translateWithRotateAndShake:(MoveDirection)direction
                             radius:(CGFloat)radius
                           duration:(CGFloat)duration
                          beginTime:(CFTimeInterval)beginTime
{
    _radius = radius;
    _direction = direction;
    
    BOOL toleft = (direction == MoveLeft) ? true : false;
    UIBezierPath *movePath = [[UIBezierPath alloc] init];
    CGPoint center = CGPointZero;
    CGFloat startAngle = toleft ? 0.0f : M_PI;
    CGFloat endAngle = toleft ? M_PI : 0.0f;
    center.x += radius * (toleft ? 1.0f : -1.0f);
    [movePath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:toleft];
    
    // Position animation
    CAKeyframeAnimation *curveAnimaton = [CAKeyframeAnimation animationWithKeyPath:kPropPosition];
    curveAnimaton.duration = duration;
    curveAnimaton.beginTime = beginTime;
    curveAnimaton.path = movePath.CGPath;
    curveAnimaton.additive = true;
    curveAnimaton.calculationMode = kCAAnimationPaced;
    curveAnimaton.fillMode = kCAFillModeForwards;
    curveAnimaton.removedOnCompletion = YES;
    curveAnimaton.delegate = self;
    
    // Scale animation
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:kPropTransform];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7f, 1.1f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7f, 1.1f, 1.0f)],
                              [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    scaleAnimation.keyTimes = @[@0.0f, @0.3f, @0.6f, @1.0f];
    scaleAnimation.duration = duration*0.9f;
    scaleAnimation.beginTime = beginTime;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = YES;
    
    // Rotate z animaition
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:kPropTransformRotationZ];
    rotate.fromValue = @(-M_PI);
    rotate.toValue = @(0.0f);
    rotate.beginTime = beginTime;
    rotate.duration = duration*0.9f;
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = YES;
    
    // Shake the bubble
#define NSValuePointOffsetY(point, oy) [NSNumber numberWithFloat:(point.y+(oy))]
    CAKeyframeAnimation *bubbleShakeAnim = [CAKeyframeAnimation animationWithKeyPath:kPropPositionY];
    bubbleShakeAnim.beginTime = beginTime + duration;
    bubbleShakeAnim.repeatCount = 3;
    bubbleShakeAnim.duration = duration*0.1f;
    bubbleShakeAnim.values = @[NSValuePointOffsetY(self.layer.position, -10.0f),
                               NSValuePointOffsetY(self.layer.position, 10.0f),
                               NSValuePointOffsetY(self.layer.position, -5.0f),
                               NSValuePointOffsetY(self.layer.position, 5.0f),
                               NSValuePointOffsetY(self.layer.position, -1.0f),
                               NSValuePointOffsetY(self.layer.position, 0.0f)];
    bubbleShakeAnim.keyTimes = @[@(0.0f), @(0.2f), @(0.4f), @(0.6f), @(0.8f), @(1.0f)];
    bubbleShakeAnim.fillMode = kCAFillModeForwards;
    bubbleShakeAnim.removedOnCompletion = YES;
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:curveAnimaton forKey:@"curveAnimaton"];
    [self.layer addAnimation:scaleAnimation forKey:@"scaleanimtion"];
    [self.layer addAnimation:rotate forKey:@"rotatez"];
    [self.layer addAnimation:bubbleShakeAnim forKey:@"Shake"];
    
    self.center = CGPointMake(self.center.x + ((_direction == MoveRight) ? _radius *2.0f : -_radius *2.0f), self.center.y);
}

#pragma mark- Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    return;
    if ([anim isKindOfClass:CAKeyframeAnimation.class]) {
        CAKeyframeAnimation *keyframeAnim = (id)anim;
        if ([keyframeAnim.keyPath isEqualToString:kPropPosition]) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.layer.opacity = 0;
            self.center = CGPointMake(self.center.x + ((_direction == MoveRight) ? _radius *2.0f : -_radius *2.0f), self.center.y);
            self.layer.opacity = 1;
            [CATransaction commit];
        }
    }
}

@end