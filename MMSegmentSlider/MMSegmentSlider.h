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
 *  Basic bottom labels color
 */
@property (nonatomic, strong) IBInspectable UIColor *bottomLabelColor;

/**
 * Selected value color
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedValueColor;

/**
 * Bottom selected value color
 */
@property (nonatomic, strong) IBInspectable UIColor *bottomSelectedValueColor;


/**
 * Selected image
 */
@property (nonatomic, strong) UIImage *selectedValueImage;

/**
 * Color of selected label
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedLabelColor;

/**
 * Color of selected bottom label
 */
@property (nonatomic, strong) IBInspectable UIColor *bottomSelectedLabelColor;

/**
 * Circles radius
 */
@property (nonatomic) IBInspectable CGFloat circlesRadius;

/**
 * Circles radius for the selected item.
 */
@property (nonatomic) IBInspectable CGFloat circlesRadiusForSelected;

@property (nonatomic) IBInspectable CGFloat bottomOffset;

/**
 * Text offset from the circle
 */
@property (nonatomic) IBInspectable CGFloat textOffset;

/**
 * Bottom Text offset from the circle
 */
@property (nonatomic) IBInspectable CGFloat bottomTextOffset;
    
@property (nonatomic) CGFloat selectedImageOffset;

/**
 * Font for labels
 */
@property (nonatomic, strong) UIFont *labelsFont;

/**
 * Font for bottom labels
 */
@property (nonatomic, strong) UIFont *bottomLabelsFont;

@property (nonatomic, strong) UIFont *selectedFont;

@property (nonatomic, strong) UIFont *unselectedFont;

/**
 * Contains NSNumber values
 */
@property (nonatomic, strong) NSArray *values;

/**
 * Contains NSString labels
 */
@property (nonatomic, strong) NSArray *labels;

/**
 * Contains NSString bottom labels
 */
@property (nonatomic, strong) NSArray *bottomLabels;

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

@end
