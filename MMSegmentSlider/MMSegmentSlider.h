/**
 *  Segmented slider
 */

#import "UIKit/UIKit.h"

IB_DESIGNABLE
@interface MMSegmentSlider : UIControl

/**
 * Basic slider color
 */
@property (nonatomic, strong) IBInspectable UIColor *basicColor;

/**
 *  Basic labels color
 */
@property (nonatomic, strong) IBInspectable UIColor *labelColor;

/**
 * Selected value color
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedValueColor;


/**
 * Selected image
 */
@property (nonatomic, strong) UIImage *selectedImage;

/**
 * Color of selected label
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedLabelColor;

/**
 * Circles radius
 */
@property (nonatomic) IBInspectable CGFloat circlesRadius;

/**
 * Circles radius for the selected item.
 */
@property (nonatomic) IBInspectable CGFloat circlesRadiusForSelected;

/**
 * Text offset from the circle
 */
@property (nonatomic) IBInspectable CGFloat textOffset;

/**
 * Font for labels
 */
@property (nonatomic, strong) UIFont *labelsFont;

/**
 * Contains NSNumber values
 */
@property (nonatomic, strong) NSArray *values;

/**
 * Contains NSString labels
 */
@property (nonatomic, strong) NSArray *labels;

/**
 * Set/get current selected value
 */
@property (nonatomic, readonly) NSObject *currentValue;

/**
 * Set/get selected item index
 */
@property (nonatomic) NSInteger selectedItemIndex;

/**
 * Set/get selected item index (animated)
 */
- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex animated:(BOOL)animated;

-(void)setSelectedImage:(UIImage *)selectedImage;

@end
