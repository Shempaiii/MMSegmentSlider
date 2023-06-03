#import "MMSegmentSlider.h"

static CGFloat const HorizontalInsets = 45.0f;

@interface MMSegmentSlider ()

@property (nonatomic, strong) CAShapeLayer *sliderLayer;
@property (nonatomic, strong) CAShapeLayer *circlesLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;
@property (nonatomic, strong) CAShapeLayer *labelsLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLabelsLayer;
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
    _bottomSelectedValueColor = [UIColor blackColor];
    _selectedLabelColor = [UIColor blackColor];
    _bottomSelectedLabelColor = [UIColor blackColor];
    _labelColor = [UIColor grayColor];
    _bottomLabelColor = [UIColor grayColor];
    
    _bottomOffset = 15.0f;
    _textOffset = 30.0f;
    _bottomTextOffset = -38.0f;
    _circlesRadius = 12.0f;
    _circlesRadiusForSelected = 12.0f;
    
    _selectedItemIndex = 0;
    _values = @[];
    _labels = @[];
    _labelsColor = @[];
    _bottomLabels = @[];
    _bottomLabelsColors = @[];
    
    _labelsFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    _bottomLabelsFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    _selectedFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    _unselectedFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
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
    self.sliderLayer.path = nil;
    if (self.values.count > 1) {
        self.sliderLayer.path = [[self pathForSlider] CGPath];
    }
    
    self.circlesLayer.fillColor = self.basicColor.CGColor;
    self.circlesLayer.path = [[self pathForCircles] CGPath];
    
    // Add image to CGShapeLayer
    if ([[self.selectedLayer sublayers] count] == 0 && self.selectedValueImage != nil) {
        if (self.selectedImageLayer != nil) {
            CFRelease((__bridge CFTypeRef)(self.selectedImageLayer));
        }
        self.selectedImageLayer = [CALayer layer];
        self.selectedImageLayer.backgroundColor = UIColor.clearColor.CGColor;
        self.selectedImageLayer.bounds = [[self pathForSelected] bounds];
        self.selectedImageLayer.contents = (__bridge id _Nullable)(CFBridgingRetain(_selectedValueImage.CGImage));
        [self.selectedLayer addSublayer: self.selectedImageLayer];
    }
    self.selectedLayer.fillColor = self.selectedValueColor.CGColor;
    self.selectedLayer.path = [[self pathForSelected] CGPath];
    
    self.selectedImageLayer.position = [self selectedImagePointForSelected];
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
    
    CGFloat lineY = self.bounds.size.height - self.circlesRadius - _bottomOffset;
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
    CGFloat yPos = self.bounds.size.height - self.circlesRadius - _bottomOffset;
    
    for (int i = 0; i < self.values.count; i++) {
        CGPoint center = CGPointMake(self.values.count == 1 ? self.center.x : (startPointX + i * intervalSize), yPos);
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
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.circlesRadius - _bottomOffset;
    CGPoint center = CGPointMake(self.values.count == 1 ? self.center.x : (startPointX + self.selectedItemIndex * intervalSize), yPos);

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
    if (self.selectedImageOffset > 0) {
        selectedImagePoint.y = selectedImagePoint.y - (self.circlesRadius + self.selectedImageOffset);
    }
    selectedImagePoint.x = selectedImagePoint.x - (self.selectedImageLayer.bounds.size.width / 2);
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
    
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height + 5 - self.circlesRadiusForSelected - _bottomOffset * 2;
    
    for (int i = 0; i < self.values.count; i++) {
        UIColor *textColor = self.selectedItemIndex == i ? self.selectedLabelColor : self.labelColor;
        
        if (self.labelsColor.count > 0 && i <= (self.labelsColor.count - 1)) {
            textColor = [self.labelsColor objectAtIndex:i];
        }
        
        UIColor *bottomTextColor = self.selectedItemIndex == i ? self.bottomSelectedLabelColor : self.bottomLabelColor;
        
        if (self.bottomLabelsColors.count > 0 && i <= (self.bottomLabelsColors.count - 1)) {
            textColor = [self.bottomLabelsColors objectAtIndex:i];
        }
        
        if (i <= (self.labels.count - 1)) {
        // Top
        [self drawLabel:[self.labels objectAtIndex:i]
                atPoint:CGPointMake(self.values.count == 1 ? self.center.x : (startPointX + i * intervalSize), yPos - self.circlesRadius - self.textOffset)
              withColor:textColor
             isSelected:self.selectedItemIndex == i];
        }
        
        // Bottom
        if (self.bottomLabels.count > 0 && i <= (self.bottomLabels.count - 1)) {
            [self drawLabel:[self.bottomLabels objectAtIndex:i]
                    atPoint:CGPointMake(self.values.count == 1 ? self.center.x : (startPointX + i * intervalSize), yPos - self.circlesRadius - self.bottomTextOffset)
                  withColor:bottomTextColor
                 isSelected:self.selectedItemIndex == i];
        }
    }
}

- (void)drawLabel:(NSString*)label atPoint:(CGPoint)point withColor:(UIColor*)color isSelected:(BOOL)isSelected
{
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = NSTextAlignmentCenter;
    [label drawInRect:CGRectMake(point.x - 35, point.y - 10, 70, 60)
       withAttributes:@{
                        NSFontAttributeName: [self getMinimizedFont: isSelected ? self.selectedFont : self.unselectedFont],
                        NSForegroundColorAttributeName: color,
                        NSParagraphStyleAttributeName: textStyle
                        }];
}

#pragma mark -

- (UIFont*) getMinimizedFont: (UIFont *)font {
    NSString *longestLabel = [self getLongestLabel];
    CGSize textSize = [longestLabel sizeWithFont: font];
    CGFloat widthNeeded = textSize.width * 0.5;
    if (widthNeeded > (self.circlesRadius * 3)) {
        UIFont *newFont = [UIFont fontWithName: font.fontName size: font.pointSize - 1];
        return [self getMinimizedFont: newFont];
    } else {
        return font;
    }
}

- (NSString *) getLongestLabel {
    NSArray *sortedLabels = [self.labels sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second) {
        return [self compareLengthOf:first withLengthOf:second];
    }];
    return sortedLabels[0];
}

- (NSComparisonResult)compareLengthOf: (NSString *)first withLengthOf: (NSString *)second {
    if ([first length] > [second length])
        return NSOrderedAscending;
    else if ([first length] < [second length])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
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
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.circlesRadius - _bottomOffset;
    
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

-(void)setSelectedValueImage:(UIImage *)selectedValueImage
{
    _selectedValueImage = selectedValueImage;
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
    if (self.selectedItemIndex <= (self.values.count - 1)) {
        return [self.values objectAtIndex:self.selectedItemIndex];
    }
    return nil;
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
