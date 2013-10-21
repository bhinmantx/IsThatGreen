//
//  OpenCVViewController.m
//  OpenCVHello
//
//  Created by Brendan Hinman on 10/10/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "OpenCVViewController.h"
#import "ColorMatcher.h"

@interface OpenCVViewController ()

@end

@implementation OpenCVViewController



@synthesize StartButton = _StartButton;
@synthesize CameraView = _CameraView;
@synthesize videoCamera = _videoCamera;
@synthesize timer = _timer;


///Because we don't have control over the main processing loop, we're having to use bools as flags
///so that methods will run.
///Also we can't update the UIView elements reliably.
@synthesize buttonIsPressed = _buttonIsPressed;
@synthesize wasItGreen = _wasItGreen;

@synthesize wasGreenFlagImage = _wasGreenFlagImage;
@synthesize wasGreenFlagMat = _wasGreenFlagMat;
@synthesize matcher = _matcher;

///TODO make a "setup" method so we're not loading the flag and doing the matrix conversion
///more than once.


////TODO Break image processing into its own class for code readability

- (void)viewDidLoad
{
//    _thumbNail = [_thumbNail init];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_CameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    _shouldDisplayFeedback = false;
    
    ///Load the flag image
//    _wasGreenFlagImage = [UIImage imageWithContentsOfFile:@"flagtest.png"];
    _wasGreenFlagImage = [UIImage imageNamed:@"YesGreenYes.png"];
 
    
    ///Convert the flag image to a Mat
    
    
    ///
    
    
    ///We need to change the camera being used
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    //self.videoCamera.grayscale = NO;

    _matcher = [[ColorMatcher alloc]initWithColorFileName:@"colordataF-R"];
    _timerCount = 0;
     
    [self timerFire];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];

    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionStart:(id)sender
{
    
    _buttonIsPressed = true;
/*
    [self.videoCamera stop];
    cv::Mat * frame = new cv::Mat;
    
   // cv::VideoCapture  cap = cv::VideoCapture(0);
    cv::VideoCapture cap;
    cap.open(0);

    cap.release();
  [self.videoCamera start];
 */
}

-(void)processImage:(cv::Mat &)image{


    if(_buttonIsPressed){
        cv::Mat tempMat(image);
        _buttonIsPressed = false;
        _shouldDisplayFeedback = true;
    [self isThisGreen:tempMat];
        
    }


    
    
image = [self drawBoxAroundTarget:image];
    if (_wasItGreen && _shouldDisplayFeedback) {
        
        
        ///Previously we were writing stuff, now we're displaying images.

        cv::Rect roi(cv::Point(0,0), cv::Size(200,40));
      
        cv::Mat temp = [self cvMatFromUIImage:_wasGreenFlagImage];
      
        temp.copyTo(image(roi));
//        _wasGreenFlagMat->copyTo(image(roi));
      
        
    }else if(_shouldDisplayFeedback) {
        cv::putText(image, "Previous Sample Not Green", cvPoint(50, 50), CV_FONT_HERSHEY_SIMPLEX, .5, cv::Scalar(0,0,0));
      
    }
    
    
}


-(cv::Mat)getTargetSubRegion:(cv::Mat)source{
    
    return source;
}

///TODO: Fix the color scalar issue
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
    
    cv::rectangle(source, top, bottom, CV_RGB(50, 60, 100));
    
    return source;
}


-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)tImage{
    
    NSInteger iRows = source.rows;
    NSInteger iCols = source.cols;
    
    ///We get the center of the image by dividing rows
    ////and cols by 2. Then we can subtract ten from the x and y then add 10 to x, y and get us the rectangle coords
    CvPoint center = cvPoint(iCols/2,iRows/2);  
  
    CvRect sampleRect = cvRect(center.x - 10, center.y - 10, 100, 100);

  
    
    
    cv::Mat  crop(source, sampleRect);

    tImage = [self imageWithCVMat:(cv::Mat(source,sampleRect))];

    
    return tImage;
}


/**
 Is this green
 */
-(void)isThisGreen:(cv::Mat)source{
    
    NSInteger iRows = source.rows;
    NSInteger iCols = source.cols;
    
    CvPoint center = cvPoint(iCols/2,iRows/2); 
    
    ///We take the center 20X20 of the image.
    CvRect sampleRect = cvRect(center.x - 10, center.y - 10, 20, 20);
    
    cv::Mat img(source, sampleRect);
    int count =0;
    long b = 0;
    long g = 0;
    long r = 0;
    for(int row = 0; row < img.rows; ++row){
      uchar* p = img.ptr(row);
        
        for(int col = 0; col < img.cols*3; ++col) {
            //*p++;  //points to each pixel B,G,R value in turn assuming a CV_8UC3 color image
             int B = [[NSNumber numberWithUnsignedChar:p[0]] integerValue] ;
            int G = [[NSNumber numberWithUnsignedChar:p[1]] integerValue] ;
            int R = [[NSNumber numberWithUnsignedChar:p[2]] integerValue] ;
          count++;
            b += B;
            g += G;
            r += R;
//            NSLog(@"B:%i G:%x R:%x Number: %i", b,p[1],p[2],tempInt );
        }
        
    }
/////We're going to try using a timer so that when 5 seconds have passed, the image vanishes.


    _timerCount = 0;

    
    
    if([self respondsToSelector:@selector(timerCallback)]){
        NSLog(@"I claim to respond to the correct selector");
    }
    
[self greenTestHelper:b :g :r :count];
    
}

///TODO: Implement a color difference algorithim to get the harder to guess colors.
////Doing something quick and dirty here.
    
-(void)greenTestHelper:(long)b :(long)g :(long)r :(int)count{
    NSLog(@"Firing Test Helper");
////Get the average RGB values of each
    _wasItGreen = false;
   NSNumber *B,*G,*R;
 
    R = [NSNumber numberWithInt:(r/count)];
    G = [NSNumber numberWithInt:(g/count)];
    B = [NSNumber numberWithInt:(b/count)];
   // B = b/count;
   // G = g/count;
    //R = r/count;
    ///The color "Green" is a bit tough to calculate for. 
    
    NSArray * testArray = [NSArray arrayWithObjects:R,G,B, nil];
    
    if ([[_matcher findDistance:testArray]  isEqual: @"g"]){
        [self GreenStatus].text = @"I think it's green";
         NSLog(@"tested Green");
        _wasItGreen = true;
    }
    else [self GreenStatus].text = @"I don't think it's green";
    
    
    /*
if(G > (B/2)){
    NSLog(@"Greater than half blue");
    if(G>(R/2)){
    NSLog(@"Greater than half red");
        if(((G-B) > 20) and ((G-R)>20)){
    NSLog(@"I think It's green");
            [self GreenStatus].text = @"I think it's green";
            _wasItGreen = true;
        }
        else
            [self GreenStatus].text = @"I don't think it's green";
        
    }

    if(G>(R/2)){
        NSLog(@"Greater than half blue");
        if(G > (B/2)){
            NSLog(@"Greater than half red");
            if(((G-B) > 20) and ((G-R)>20)){
                NSLog(@"I think It's green");
                [self GreenStatus].text = @"I think it's green";
                _wasItGreen = true;
            }
            else
                [self GreenStatus].text = @"I don't think it's green";
            
            }
        }


    }
    */

}
    
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
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
 Once 5 seconds has elapsed and no additional samples taken, remove feedback
 */





-(void)timerCallback{
    NSLog(@"TimerCallback");
    _timerCount += 1;
    
    if(_timerCount > 4){
        _timerCount = 0;
    _shouldDisplayFeedback = false;
    }
}

-(void)timerFire{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    NSLog(@"Timer Fired");
    if([self respondsToSelector:@selector(timerCallback)]){
        NSLog(@"TimerFire has been Fired");
    }
}



@end
