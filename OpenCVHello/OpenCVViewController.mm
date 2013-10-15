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

@synthesize buttonIsPressed = _buttonIsPressed;
@synthesize wasItGreen = _wasItGreen;



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
  
 
    
    ///Following lines were attempts at seeing what the process thumbnail was seeing.
    
 /*
   UIImage *newThumb = [[UIImage alloc] init];
 
    cv::Mat tempMat(image);

    newThumb = [self createThumbnail:tempMat :newThumb];
    
    [self thumbNail].image = newThumb;
*/
 //  NSLog(@"%@ %f %f", @"stats for newThumb are: ", newThumb.size.height, newThumb.size.width);

    if(_buttonIsPressed){
        cv::Mat tempMat(image);
        _buttonIsPressed = false;
    [self isThisGreen:tempMat];
        
    }


    
    
image = [self drawBoxAroundTarget:image];
    if (_wasItGreen) {
        CvFont font;
        cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 1.0, 1.0, 0,1, 8);
        cv::putText(image, "Yes that was green", cvPoint(50, 50), CV_FONT_HERSHEY_SIMPLEX, .5, cv::Scalar(0,0,0));
    }else
        cv::putText(image, "Previous Sample Not Green", cvPoint(50, 50), CV_FONT_HERSHEY_SIMPLEX, .5, cv::Scalar(0,0,0));
    
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
[self greenTestHelper:b :g :r :count];
    
}

///TODO: Implement a color difference algorithim to get the harder to guess colors.
////Doing something quick and dirty here.
    
-(void)greenTestHelper:(long)b :(long)g :(long)r :(int)count{
    NSLog(@"Firing Test Helper");
////Get the average RGB values of each
    _wasItGreen = false;
    long B,G,R;
    
    B = b/count;
    G = g/count;
    R = r/count;
    ///The color "Green" is a bit tough to calculate for. 
    
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
