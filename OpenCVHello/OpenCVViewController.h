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
    //UIImageView *_thumbNail;
    //cv::Mat *_sample;
    UIImage *_wasGreenFlagImage;
    cv::Mat *_wasGreenFlagMat;
    BOOL _wasItFirstSample;
    BOOL _buttonIsPressed;
    BOOL _wasItGreen;
    ColorMatcher *_matcher;
}

-(IBAction)actionStart:(id)sender;
-(cv::Mat)drawBoxAroundTarget:(cv::Mat)source;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)image;
-(void)isThisGreen:(cv::Mat)testMat;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;


@property (strong, nonatomic) ColorMatcher * matcher;
@property (strong, nonatomic) UIImage * wasGreenFlagImage;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (strong, nonatomic) IBOutlet UIImageView *CameraView;
@property (strong, nonatomic) IBOutlet UIButton *StartButton;
//@property (strong, atomic) IBOutlet UIImageView *thumbNail;
//@property (atomic) cv::Mat *sample;
@property (nonatomic) cv::Mat * wasGreenFlagMat;

@property BOOL buttonIsPressed;
@property BOOL wasItGreen;
@property BOOL wasItFirstSample;

@property (strong, nonatomic) IBOutlet UILabel *GreenStatus;


@end

