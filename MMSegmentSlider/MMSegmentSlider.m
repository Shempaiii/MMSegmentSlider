#import "MMSegmentSlider.h"

static CGFloat const HorizontalInsets = 45.0f;
static CGFloat const BottomOffset = 15.0f;

@interface MMSegmentSlider ()

@property (nonatomic, strong) CAShapeLayer *sliderLayer;
@property (nonatomic, strong) CAShapeLayer *circlesLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;
@property (nonatomic, strong) CAShapeLayer *labelsLayer;
@property (nonatomic, strong) CALayer *selectedImageLayer;

@end

@implementation MMSegmentSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupProperties];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupProperties];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProperties];
    }
    
    return self;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupLayers];
}

- (void)prepareForInterfaceBuilder
{
    [self setupLayers];
}

- (void)layoutSubviews
{
    [self updateLayers];
    [self setNeedsDisplay];
}

- (void)setupProperties
{
    _basicColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    _selectedValueColor = [UIColor blackColor];
    _selectedLabelColor = [UIColor blackColor];
    _labelColor = [UIColor grayColor];
    
    _textOffset = 30.0f;
    _circlesRadius = 12.0f;
    _circlesRadiusForSelected = 26.0f;
    
    _selectedItemIndex = 0;
    _values = @[@0, @1, @2];
    _labels = @[@"item 0", @"item 1", @"item 2"];
    
    _labelsFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
}

#pragma mark - Shape Layers

- (void)setupLayers
{
    self.sliderLayer = [CAShapeLayer layer];
    self.sliderLayer.lineWidth = 3.0f;
    [self.layer addSublayer:self.sliderLayer];
    
    self.circlesLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.circlesLayer];
    
    self.selectedLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.selectedLayer];
}

- (void)updateLayers
{
    self.sliderLayer.strokeColor = self.basicColor.CGColor;
    self.sliderLayer.path = [[self pathForSlider] CGPath];
    
    self.circlesLayer.fillColor = self.basicColor.CGColor;
    self.circlesLayer.path = [[self pathForCircles] CGPath];
    
    // Add image to CGShapeLayer
    
    self.selectedImageLayer = [CALayer layer];
    self.selectedImageLayer.backgroundColor = UIColor.clearColor.CGColor;
    
    CGRect pathForSelectedBounds = [[self pathForSelected] bounds];
    CGRect selectedImageRect = CGRectMake(pathForSelectedBounds.origin.x,
                                          pathForSelectedBounds.origin.y,
                                          pathForSelectedBounds.size.width * 0.8,
                                          pathForSelectedBounds.size.height * 0.8);
    
    self.selectedImageLayer.bounds = selectedImageRect;
    self.selectedImageLayer.position = [self selectedImagePointForSelected];
    self.selectedImageLayer.contents = CFBridgingRelease((_selectedValueImage.CGImage));
    
    [self.selectedImageLayer removeFromSuperlayer];
    [self.selectedLayer addSublayer: self.selectedImageLayer];
    
    self.selectedLayer.fillColor = self.selectedValueColor.CGColor;
    self.selectedLayer.path = [[self pathForSelected] CGPath];
}

- (void)animateSelectionChange
{
    CGPathRef oldPath = self.selectedLayer.path;
    CGPathRef newPath = [[self pathForSelected] CGPath];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id) oldPath;
    pathAnimation.toValue = (__bridge id) newPath;
    pathAnimation.duration = 0.25f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :1.00 :0.70 :1.00];

    self.selectedImageLayer.position = [self selectedImagePointForSelected];
    self.selectedLayer.path = newPath;
    [self.selectedLayer addAnimation:pathAnimation forKey:@"PathAnimation"];
}

- (UIBezierPath *)pathForSlider
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat lineY = self.bounds.size.height - self.circlesRadius - BottomOffset;
    [path moveToPoint:CGPointMake(self.circlesRadius + HorizontalInsets, lineY)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - self.circlesRadius - HorizontalInsets, lineY)];
    [path closePath];
    
    return path;
}

- (UIBezierPath *)pathForCircles
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat startPointX = self.circlesRadius + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.circlesRadius + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height - self.circlesRadius - BottomOffset;
    
    for (int i = 0; i < self.values.count; i++) {
        CGPoint center = CGPointMake(startPointX + i * intervalSize, yPos);
        [path addArcWithCenter:center
                        radius:self.circlesRadius
                    startAngle:0
                      endAngle:2 * M_PI
                     clockwise:YES];
        [path closePath];
    }
    
    return path;
}

- (UIBezierPath *)pathForSelected
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGFloat startPointX = self.bounds.origin.x + self.circlesRadius + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.circlesRadius + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.circlesRadius - BottomOffset;
    CGPoint center = CGPointMake(startPointX + self.selectedItemIndex * intervalSize, yPos);

    [path addArcWithCenter:center
                    radius:self.circlesRadiusForSelected
                startAngle:0
                  endAngle:2 * M_PI
                 clockwise:YES];
    [path closePath];

    return path;
}

- (CGPoint)selectedImagePointForSelected
{
    CGPoint selectedImagePoint = [[self pathForSelected] currentPoint];
    selectedImagePoint.x = selectedImagePoint.x - (self.selectedImageLayer.bounds.size.width * 0.63);
    return selectedImagePoint;
}

#pragma mark - UIView drawing

- (void)drawRect:(CGRect)rect
{
    [self drawLabels];
}

- (void)drawLabels
{
    CGFloat startPointX = self.bounds.origin.x + self.circlesRadius + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.circlesRadius + HorizontalInsets) * 2.0) / (self.values.count - 1);
    
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height + 5 - self.circlesRadiusForSelected - BottomOffset * 2;
    
    for (int i = 0; i < self.values.count; i++) {
        UIColor *textColor = self.selectedItemIndex == i ? self.selectedLabelColor : self.labelColor;
        
        [self drawLabel:[self.labels objectAtIndex:i]
                atPoint:CGPointMake(startPointX + i * intervalSize, yPos - self.circlesRadius - self.textOffset)
              withColor:textColor];
    }
}

- (void)drawLabel:(NSString*)label atPoint:(CGPoint)point withColor:(UIColor*)color
{
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = NSTextAlignmentCenter;
    [label drawInRect:CGRectMake(point.x - 40, point.y - 10, 70, 60)
       withAttributes:@{
                        NSFontAttributeName: self.labelsFont,
                        NSForegroundColorAttributeName: color,
                        NSParagraphStyleAttributeName: textStyle
                        }];
}

#pragma mark - Touch handlers

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) return;
    
    UITouch *touch = [touches.allObjects firstObject];
    [self switchSelectionForTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) return;
    
    UITouch *touch = [touches.allObjects firstObject];
    [self switchSelectionForTouch:touch];
}

- (void)switchSelectionForTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    
    NSInteger index = [self indexForTouchPoint:location];
    BOOL canSwitch = index >= 0 && index < self.values.count && index != self.selectedItemIndex;

    if (canSwitch) {
        [self setSelectedItemIndex:index animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (NSInteger)indexForTouchPoint:(CGPoint)point
{
    CGFloat startPointX = self.bounds.origin.x + self.circlesRadius + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.circlesRadius + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.circlesRadius - BottomOffset;
    
    NSInteger approximateIndex = round((point.x - startPointX) / intervalSize);
    CGFloat xAccuracy = fabs(point.x - (startPointX + approximateIndex * intervalSize));
    CGFloat yAccuracy = fabs(yPos - point.y);
    
    if (xAccuracy > self.circlesRadius * 2.4f || yAccuracy > self.bounds.size.height * 0.8f) {
        return -1;
    }
    
    return approximateIndex;
}

#pragma mark - Properties

- (void)setValues:(NSArray *)values
{
    _values = values;
    self.selectedItemIndex = 0;

    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setImage:(UIImage *)image {
    self.selectedValueImage = image;
    self.selectedValueColor = UIColor.clearColor;
    
    [self updateLayers];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    _selectedItemIndex = selectedItemIndex;
    
    [self updateLayers];
    [self setNeedsDisplay];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex animated:(BOOL)animated
{
    _selectedItemIndex = selectedItemIndex;
    
    if (animated) {
        [self animateSelectionChange];
    }
    else {
        [self updateLayers];
    }
    
    [self setNeedsDisplay];
}

- (NSObject *)currentValue
{
    return [self.values objectAtIndex:self.selectedItemIndex];
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (_selectedItemIndex < self.labels.count) {
        return self.labels[_selectedItemIndex];
    }
    else {
        return nil;
    }
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitSelected | UIAccessibilityTraitAdjustable | UIAccessibilityTraitSummaryElement;
}

- (void)accessibilityIncrement
{
    if (_selectedItemIndex < self.labels.count - 1) {
        [self setSelectedItemIndex:_selectedItemIndex+1 animated:YES];
    }
}

- (void)accessibilityDecrement
{
    if (_selectedItemIndex > 0) {
        [self setSelectedItemIndex:_selectedItemIndex-1 animated:YES];
    }
}

@end
