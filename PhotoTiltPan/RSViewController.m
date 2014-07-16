//
//  RSViewController.m
//  PhotoTiltPan
//
//  Created by Ramsundar Shandilya on 16/07/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "RSViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface RSViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation RSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.motionManager = [[CMMotionManager alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        
        CGFloat xRotationRate = motion.rotationRate.x;
        CGFloat yRotationRate = motion.rotationRate.y;
        CGFloat zRotationRate = motion.rotationRate.z;
        
    }];
}

@end
