//
//  OpenCVViewController.m
//  OpenCVHello
//
//  Created by Brendan Hinman on 10/10/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "OpenCVViewController.h"


@interface OpenCVViewController ()

@end

@implementation OpenCVViewController



@synthesize StartButton = _StartButton;
@synthesize CameraView = _CameraView;
@synthesize videoCamera = _videoCamera;
@synthesize thumbNail = _thumbNail;
@synthesize sample = _sample;
@synthesize GreenStatus = _GreenStatus;




- (void)viewDidLoad
{
    _thumbNail = [_thumbNail init]; 
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_CameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    
    
    ///We need to change the camera being used
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    //self.videoCamera.grayscale = NO;

    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionStart:(id)sender
{
  [self.videoCamera stop];
    cv::Mat * frame = new cv::Mat;
    
   // cv::VideoCapture  cap = cv::VideoCapture(0);
    cv::VideoCapture cap;
    cap.open(0);

    cap.release();
  [self.videoCamera start];
}

-(void)processImage:(cv::Mat &)image{
  
 
    
    ///Following lines were attempts at seeing what the process thumbnail was seeing.
    
 /*
   UIImage *newThumb = [[UIImage alloc] init];
 
    cv::Mat tempMat(image);

    newThumb = [self createThumbnail:tempMat :newThumb];
    
    [self thumbNail].image = newThumb;
*/
 //  NSLog(@"%@ %f %f", @"stats for newThumb are: ", newThumb.size.height, newThumb.size.width);

    [self isThisGreen:image];
    [[self GreenStatus] setNeedsDisplay];
image = [self drawBoxAroundTarget:image];
    
  
    
}


-(cv::Mat)getTargetSubRegion:(cv::Mat)source{
    
    return source;
}


-(cv::Mat)drawBoxAroundTarget:(cv::Mat)source{

   
    CvPoint top;
    CvPoint bottom;
    
    NSInteger iRows = source.rows;
    NSInteger iCols = source.cols;
    
///We get the center of the image by dividing rows
    ////and cols by 2. Then we can subtract ten from the x and y then add 10 to x, y and get us the rectangle coords
    CvPoint center = cvPoint(iCols/2,iRows/2);
    
    top = cvPoint(center.x - 10, center.y - 10);
    bottom = cvPoint(center.x +10, center.y +10);
    
    cv::rectangle(source, top, bottom, cv::Scalar(255,0,0));
    
    return source;
}


-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)tImage{
    
    NSInteger iRows = source.rows;
    NSInteger iCols = source.cols;
    
    ///We get the center of the image by dividing rows
    ////and cols by 2. Then we can subtract ten from the x and y then add 10 to x, y and get us the rectangle coords
    CvPoint center = cvPoint(iCols/2,iRows/2);  
  
    CvRect sampleRect = cvRect(center.x - 10, center.y - 10, 100, 100);
   // NSLog(@"%@ %f %f", @"tImage stats before crop etc are: ", tImage.size.height, tImage.size.width);
  
    
    
    cv::Mat  crop(source, sampleRect);

    tImage = [self imageWithCVMat:(cv::Mat(source,sampleRect))];

   // NSLog(@"%@ %f %f", @"tImage stats are NOW: ", tImage.size.height, tImage.size.width);
//    return [self imageWithCVMat:(cv::Mat(*source,sampleRect))];
    return tImage;
}


/**
 Is this green
 */
-(void)isThisGreen:(cv::Mat)testMat{
     _GreenStatus.text = @"Not Green";
     
}

    
    
    



/**
 Convert mat to uiimage
 */
- (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
  
    return image;
}


/**
 Trying to get a look at what the system is seeing in the copied Mat
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    UIViewController *temp = segue.destinationViewController;
    NSLog(@"%@ %f", @"Fire", [self thumbNail].image.size.height);
    ((UIImageView *)[temp.view viewWithTag:100]).image = [self thumbNail].image;
//    tempview.image = _thumbNail.image;

}



@end
