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
    UIButton *_GreenButton;
    UIButton *_IsThisRedButton;
    
    int _deleteMe; 
  
    BOOL _shouldDisplayFeedback;
    
    BOOL _redButtonIsPressed;
    BOOL _buttonIsPressed;
    
    BOOL _wasItGreen;
    BOOL _wasItRed;
 
    BOOL _isDetectorOn;
    
    ColorMatcher *_matcher;
    int _timerCount;
    NSTimer *_timer;
    NSArray *_json;
    
    NSMutableString *_targetColor;
}


-(cv::Mat)drawBoxAroundTarget:(cv::Mat)source;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)image;
-(void)isThisGreen:(cv::Mat)testMat :(NSString*)color;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

-(void)timerCallback;
-(void)timerFire;

-(void)processJSON;


@property (strong, nonatomic) IBOutlet UILabel *AcrossLabel;

@property (strong, nonatomic) IBOutlet UISlider *TargetSizeSlider;
@property (strong, nonatomic) ColorMatcher * matcher;

@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (strong, nonatomic) IBOutlet UIImageView *CameraView;
@property (strong, nonatomic) IBOutlet UIButton *GreenButton;


@property (strong, nonatomic) IBOutlet UISwitch *ScanMode;

@property (strong, nonatomic) IBOutlet UIButton *IsThisRedButton;
@property (strong, nonatomic) NSArray *json;

@property (strong,nonatomic) NSTimer * timer;

@property (strong, atomic) NSMutableString *targetColor;


@property BOOL redButtonIsPressed;
@property BOOL buttonIsPressed;
@property BOOL wasItGreen;
@property BOOL wasItRed;





@end

