//
//  RSViewController.m
//  PhotoTiltPan
//
//  Created by Ramsundar Shandilya on 16/07/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "RSViewController.h"
#import <CoreMotion/CoreMotion.h>

static CGFloat kMovementSmoothing = 0.3f;
static CGFloat kAnimationDuration = 0.3f;
static CGFloat kRotationMultiplier = 5.f;

@interface RSViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign, getter = isMotionBasedPanEnabled) BOOL motionBasedPanEnabled;

@end

@implementation RSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.motionBasedPanEnabled = YES;
    
    self.photoScrollView.contentSize = self.view.bounds.size;
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    [self.photoImageView setImage:[UIImage imageNamed:@"Try3a.JPG"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateScrollViewZoomToMaximumForImage:self.photoImageView.image];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat offsetX = (self.photoScrollView.contentSize.width / 2.f) - (CGRectGetWidth(self.photoScrollView.bounds)) / 2.f;
    CGFloat offsetY = (self.photoScrollView.contentSize.height / 2.f) - (CGRectGetHeight(self.photoScrollView.bounds)) / 2.f;
    self.photoScrollView.contentOffset = CGPointMake(offsetX, offsetY);
    
    [self startMotionDetection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMotionDetection
{
    
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:self.motionManager.attitudeReferenceFrame toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        if (self.isMotionBasedPanEnabled) {
            CGFloat xRotationRate = motion.rotationRate.x;
            CGFloat yRotationRate = motion.rotationRate.y;
            CGFloat zRotationRate = motion.rotationRate.z;
            
            if (fabs(yRotationRate) > (fabs(xRotationRate) + fabs(zRotationRate)))
            {
                CGFloat invertedYRotationRate = yRotationRate * -1;
                
                CGFloat zoomScale = [self maximumZoomScaleForImage:self.photoImageView.image];
                CGFloat interpretedXOffset = self.photoScrollView.contentOffset.x + (invertedYRotationRate * zoomScale * kRotationMultiplier);
                
                CGPoint contentOffset = [self clampedContentOffsetForHorizontalOffset:interpretedXOffset];
                
                [UIView animateWithDuration:kMovementSmoothing
                                      delay:0.0f
                                    options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.photoScrollView setContentOffset:contentOffset animated:NO];
                                 } completion:NULL];
            }
        }     
        
    }];
}

- (CGPoint)clampedContentOffsetForHorizontalOffset:(CGFloat)horizontalOffset;
{
    CGFloat maximumXOffset = self.photoScrollView.contentSize.width - CGRectGetWidth(self.photoScrollView.bounds);
    CGFloat minimumXOffset = 0.f;
    
    CGFloat clampedXOffset = fmaxf(minimumXOffset, fmin(horizontalOffset, maximumXOffset));
    CGFloat centeredY = (self.photoScrollView.contentSize.height / 2.f) - (CGRectGetHeight(self.photoScrollView.bounds)) / 2.f;
    
    return CGPointMake(clampedXOffset, centeredY);
}

#pragma mark - Zooming

- (CGFloat)maximumZoomScaleForImage:(UIImage *)image
{
    return (CGRectGetHeight(self.photoScrollView.bounds) / CGRectGetWidth(self.photoScrollView.bounds)) * (image.size.width / image.size.height);
}

- (void)updateScrollViewZoomToMaximumForImage:(UIImage *)image
{
    CGFloat zoomScale = [self maximumZoomScaleForImage:image];
    
    self.photoScrollView.maximumZoomScale = zoomScale;
    self.photoScrollView.zoomScale = zoomScale;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}


- (IBAction)viewTapped:(id)sender {
    
    BOOL motionBasedPanWasEnabled = self.isMotionBasedPanEnabled;
    if (motionBasedPanWasEnabled)
    {
        self.motionBasedPanEnabled = NO;
    }
    
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         [self updateViewsForMotionBasedPanEnabled:!motionBasedPanWasEnabled];
                     } completion:^(BOOL finished) {
                         if (motionBasedPanWasEnabled == NO)
                         {
                             self.motionBasedPanEnabled = YES;
                         }
                     }];
}

- (void)updateViewsForMotionBasedPanEnabled:(BOOL)motionBasedPanEnabled
{
    if (motionBasedPanEnabled)
    {
        [self updateScrollViewZoomToMaximumForImage:self.photoImageView.image];
    }
    else
    {
        self.photoScrollView.zoomScale = 1.f;
    }
}

@end
