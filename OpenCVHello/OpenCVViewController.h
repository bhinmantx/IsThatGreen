//
//  OpenCVViewController.h
//  OpenCVHello
//
//  Created by Brendan Hinman on 10/10/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
// Contains code from OpenCV libraries that is distributed under the BSD license. The following is the copyright disclaimer:
/*
 By downloading, copying, installing or using the software you agree to this license. If you do not agree to this license, do not download, install, copy or use the software.
 
 License Agreement
 For Open Source Computer Vision Library
 
 Copyright (C) 2000-2008, Intel Corporation, all rights reserved. Copyright (C) 2008-2011, Willow Garage Inc., all rights reserved. Third party copyrights are property of their respective owners.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 The name of the copyright holders may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 This software is provided by the copyright holders and contributors "as is" and any express or implied warranties, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. In no event shall the Intel Corporation or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this software, even if advised of the possibility of such damage.
 */
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
    
    //int _deleteMe;
  
    BOOL _shouldDisplayFeedback;
    
    BOOL _redButtonIsPressed;
    BOOL _buttonIsPressed;
    
    BOOL _wasItGreen;
    BOOL _wasItRed;
 
    BOOL _isDetectorOn;
    BOOL _ColorReplaced;
    
    ColorMatcher *_matcher;
    int _timerCount;
    NSTimer *_timer;
    NSArray *_json;
    
    UIImageView *_thumb;
    
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
@property (atomic) UIImageView * thumb; 

@property (strong, atomic) NSMutableString *targetColor;


@property BOOL redButtonIsPressed;
@property BOOL buttonIsPressed;
@property BOOL wasItGreen;
@property BOOL wasItRed;
@property BOOL ColorReplaced; 




@end

