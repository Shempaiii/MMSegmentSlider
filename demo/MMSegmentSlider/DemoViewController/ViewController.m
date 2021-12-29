#import "ViewController.h"
#import "MMSegmentSlider.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet MMSegmentSlider *segmentSlider;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sampleWithImage];
}

- (void)sampleTextOnly {
    self.segmentSlider.values = @[@"$19", @"$99", @"$199", @"$299"];
    self.segmentSlider.labels = @[@"1 month", @"6 months", @"1 year", @"2 years"];
    self.segmentSlider.labelsFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    
    [self.segmentSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self updatePriceLabel];
}

- (void)sampleWithImage {
    self.segmentSlider.values = @[@"$19", @"$99", @"$199", @"$299"];
    self.segmentSlider.labels = @[@"1 month", @"6 months", @"1 year", @"2 years"];
    self.segmentSlider.bottomLabels = @[@"A", @"B", @"C", @"D"];
    self.segmentSlider.circlesRadius = 8.0;
    self.segmentSlider.circlesRadiusForSelected = 8.0;
    self.segmentSlider.selectedImageOffset = 8.0;
    self.segmentSlider.selectedValueImage = [UIImage imageNamed:@"arrow_down_green"];
    
    [self.segmentSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged
{
    [self updatePriceLabel];
}

- (void)updatePriceLabel
{
    self.priceLabel.text = (NSString *)self.segmentSlider.currentValue;
}

@end
