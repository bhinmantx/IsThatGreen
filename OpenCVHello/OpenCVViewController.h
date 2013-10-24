//
//  OpenCVViewController.h
//  OpenCVHello
//
//  Created by Brendan Hinman on 10/10/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <opencv2/highgui/highgui_c.h>
#import <opencv2/highgui/cap_ios.h>
#import "ColorMatcher.h"





@interface OpenCVViewController : UIViewController<CvVideoCameraDelegate>{

    
    CvVideoCamera *_videoCamera;
    UIImageView *_CameraView;
    UIButton *_StartButton;
    UIButton *_IsThisRedButton;
    
    UIImage *_wasGreenFlagImage;
    cv::Mat *_wasGreenFlagMat;
  
    BOOL _shouldDisplayFeedback;
    
    BOOL _redButtonIsPressed;
    BOOL _buttonIsPressed;
    
    BOOL _wasItGreen;
    BOOL _wasItRed;
 
    ColorMatcher *_matcher;
    int _timerCount;
    NSTimer *_timer;
    
}

-(IBAction)actionStart:(id)sender;
-(cv::Mat)drawBoxAroundTarget:(cv::Mat)source;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)image;
-(void)isThisGreen:(cv::Mat)testMat :(NSString*)color;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

-(void)timerCallback;
-(void)timerFire;


@property (strong, nonatomic) IBOutlet UISlider *TargetSizeSlider;
@property (strong, nonatomic) ColorMatcher * matcher;
@property (strong, nonatomic) UIImage * wasGreenFlagImage;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (strong, nonatomic) IBOutlet UIImageView *CameraView;
@property (strong, nonatomic) IBOutlet UIButton *StartButton;
@property (strong, nonatomic) IBOutlet UIButton *IsThisRedButton;



//@property (strong, atomic) IBOutlet UIImageView *thumbNail;
//@property (atomic) cv::Mat *sample;
@property (nonatomic) cv::Mat * wasGreenFlagMat;
@property (strong,nonatomic) NSTimer * timer;


@property BOOL redButtonIsPressed;
@property BOOL buttonIsPressed;
@property BOOL wasItGreen;
@property BOOL wasItRed;
@property BOOL wasItFirstSample;

@property (strong, nonatomic) IBOutlet UILabel *GreenStatus;


@end

