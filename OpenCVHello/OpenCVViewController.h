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






@interface OpenCVViewController : UIViewController<CvVideoCameraDelegate>{

    
    CvVideoCamera *_videoCamera;
    UIImageView *_CameraView;
    UIButton *_StartButton;
    UIImageView *_thumbNail;
    cv::Mat *_sample;
    UILabel *_GreenStatus;

}

-(IBAction)actionStart:(id)sender;
-(cv::Mat)drawBoxAroundTarget:(cv::Mat)source;
-(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)image;
-(void)isThisGreen:(cv::Mat)testMat;


@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (strong, nonatomic) IBOutlet UIImageView *CameraView;
@property (strong, nonatomic) IBOutlet UIButton *StartButton;
@property (strong, atomic) IBOutlet UIImageView *thumbNail;
@property (atomic) cv::Mat *sample;

@property (strong, nonatomic) IBOutlet UILabel *GreenStatus;


@end

