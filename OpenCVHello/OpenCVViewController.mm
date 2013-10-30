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



@synthesize GreenButton = _GreenButton;
@synthesize CameraView = _CameraView;
@synthesize videoCamera = _videoCamera;



///Because we don't have control over the main processing loop, we're having to use bools as flags
///so that methods will run.
///Also we can't update the UIView elements reliably.
@synthesize buttonIsPressed = _buttonIsPressed;
@synthesize redButtonIsPressed = _redButtonIsPressed;
@synthesize wasItGreen = _wasItGreen;
@synthesize wasItRed = _wasItRed;
@synthesize ColorReplaced = _ColorReplaced;


@synthesize matcher = _matcher;
@synthesize TargetSizeSlider;
@synthesize targetColor = _targetColor;
@synthesize thumb = _thumb;

///TODO make a "setup" method so we're not loading the flag and doing the matrix conversion
///more than once.




- (void)viewDidLoad
{

    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_CameraView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    _shouldDisplayFeedback = false;
    
    _targetColor = (NSMutableString*)@"";
    
    ///We need to change the camera being used
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    
    //self.videoCamera.grayscale = NO;

   // _matcher = [[ColorMatcher alloc]initWithColorFileName:@"colordataF-R"];
   
    _deleteMe = 0;
    _isDetectorOn = false;
    _thumb = (UIImageView*)[self.view  viewWithTag:101];
    _thumb.hidden = true;
    ///Load up our color data
    [self processJSON];
    
    _matcher = [[ColorMatcher alloc]initWithJSON:_json];
    
    ///We're resetting the feedback timer
    _timerCount = 0;
     
    [self timerFire];
    
    [self.videoCamera start];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self timerFire];
    
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
    _targetColor = (NSMutableString*)@"g";

}

-(IBAction)redButtonPressed:(id)sender
{
    
    _redButtonIsPressed = true;
    _targetColor = (NSMutableString*)@"r";
}

- (IBAction)detectorButtonToggle:(id)sender {
    
    ////Hold on to the value of the old text
    static UIColor *oldButtonTitleColor;
    static UIColor *oldSliderMaxColor;
        static UIColor *oldSliderMinColor;
    
    if(_isDetectorOn){
     
        ////Here we reset everything we did before
        ///Enabling all the buttons etc
        [self TargetSizeSlider].enabled = true;
        [self GreenButton].enabled = true;
        [self IsThisRedButton].enabled = true;
         _shouldDisplayFeedback = false;
        [[self IsThisRedButton] setTitleColor:oldButtonTitleColor forState:UIControlStateNormal];
        [[self GreenButton] setTitleColor:oldButtonTitleColor forState:UIControlStateNormal];
    //    [self TargetSizeSlider].minimumTrackTintColor = oldSliderMinColor;
      //  [self TargetSizeSlider].maximumTrackTintColor = oldSliderMaxColor;
    }
    else {
        ////We're activating the detector mode here
        ////we need to deactivate the other controls
        ///But save their text color
        oldButtonTitleColor = [self IsThisRedButton].currentTitleColor;
        oldSliderMinColor = [self TargetSizeSlider].minimumTrackTintColor;
        oldSliderMaxColor =[self TargetSizeSlider].maximumTrackTintColor;
        
        [[self TargetSizeSlider] setValue:5.0];
      //  [self TargetSizeSlider].minimumTrackTintColor = [UIColor lightGrayColor];
      //  [self TargetSizeSlider].maximumTrackTintColor = [UIColor lightGrayColor];
       // [self TargetSizeSlider].enabled = false;
        [self GreenButton].enabled = false;
        [self IsThisRedButton].enabled = false;
       ////We also need to change their colors
        //[self TargetSizeSlider].backgroundColor = [UIColor lightGrayColor];
        
        [[self IsThisRedButton] setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [[self GreenButton] setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
    }
    _shouldDisplayFeedback = false;
    _isDetectorOn = !_isDetectorOn;
    _AcrossLabel.hidden = true;
    [[self view] setNeedsDisplay];
   // [self.DetectorButton setImage:[UIImage imageNamed:_isDetectorOn ? @"detectoriconactive.png" :@"detectoricon.png"] forState:UIControlStateNormal];
}





-(void)processImage:(cv::Mat &)image{

    if(_isDetectorOn){
        
        ///Originally just following line
        //        cv::Mat tempMat(image);
        //Now we're resizing it here
        NSInteger iRows = image.rows;
        NSInteger iCols = image.cols;
        
        CvPoint center = cvPoint(iCols/2,iRows/2);
        
        NSInteger  targ = (int)[self TargetSizeSlider].value;
        ///We take the center 20X20 of the image.
        
        ///We're expanding the target area, or making it smaller based on the slider.
        CvRect sampleRect = cvRect(center.x - targ, center.y - targ, (targ*2), (targ*2));
                 cv::Mat tempMat(image, sampleRect);
         _buttonIsPressed = false;
         _targetColor = (NSMutableString*)@"g";
         [self isThisGreen:tempMat:@"g"];
         
         _shouldDisplayFeedback = true;
         _deleteMe = 0;
      }
    ////If they've hit the green button or if it's in detector mode.
  // if(_buttonIsPressed || _isDetectorOn){
     if(_buttonIsPressed){
         
         ///Originally just following line
//        cv::Mat tempMat(image);
         //Now we're resizing it here
         NSInteger iRows = image.rows;
         NSInteger iCols = image.cols;
         
         CvPoint center = cvPoint(iCols/2,iRows/2);
         
         NSInteger  targ = (int)[self TargetSizeSlider].value;
         ///We take the center 20X20 of the image.
         
         ///We're expanding the target area, or making it smaller based on the slider.
         CvRect sampleRect = cvRect(center.x - targ, center.y - targ, (targ*2), (targ*2));
       
       
       float x = center.x - targ;
       float y = center.y - targ;
       float width = (targ*2);
       float height = (targ*4);
       
       _thumb.frame = CGRectMake(x, y, width, height);
       cv::Mat tempMat(image, sampleRect);
         
       _buttonIsPressed = false;
      // [self GreenButton].enabled = false;
       [[self view] setNeedsDisplay];
       
       ///Previously this did this:
       //       [self isThisGreen:tempMat:@"r"];
       ///now we're trying the experimental image swap
       // _thumb.hidden = true;
       tempMat = [_matcher ColorReplacer:tempMat :@"g" :_thumb];
       
       _thumb.image = [self imageWithCVMat:tempMat];
       _thumb.hidden = false;
       [self AcrossLabel].text = @"Processed!";
       [self IsThisRedButton].enabled = true;
       [[self.view  viewWithTag:101] setNeedsDisplay];
       _timerCount = 0;
       _ColorReplaced = true;
       _shouldDisplayFeedback = true;
       
       
       ///Previous is it green code
        /*
         cv::Mat tempMat(image, sampleRect);
        _buttonIsPressed = false;
        _targetColor = (NSMutableString*)@"g";
        [self isThisGreen:tempMat:@"g"];
       
         _shouldDisplayFeedback = true;
         _deleteMe = 0;
         */
    }
    
    
    
    if(_redButtonIsPressed){
        _shouldDisplayFeedback = false;
        ///Originally just following line
        //        cv::Mat tempMat(image);
        //Now we're resizing it here
        NSInteger iRows = image.rows;
        NSInteger iCols = image.cols;
        
        CvPoint center = cvPoint(iCols/2,iRows/2);
        
        NSInteger  targ = (int)[self TargetSizeSlider].value;
        ///We take the center 20X20 of the image.
        ///We're expanding the target area, or making it smaller based on the slider.
        CvRect sampleRect = cvRect(center.x - targ, center.y - targ, (targ*2), (targ*2));
        float x = center.x - targ;
        float y = center.y - targ;
        float width = (targ*2);
        float height = (targ*4);
        
        _thumb.frame = CGRectMake(x, y, width, height);
        cv::Mat tempMat(image, sampleRect);
        _redButtonIsPressed = false;
        [self IsThisRedButton].enabled = false;
        [[self view] setNeedsDisplay];
       
        ///Previously this did this:
 //       [self isThisGreen:tempMat:@"r"];
        ///now we're trying the experimental image swap
       // _thumb.hidden = true;
        tempMat = [_matcher ColorReplacer:tempMat :@"r" :_thumb];
        
        _thumb.image = [self imageWithCVMat:tempMat];
        _thumb.hidden = false;
        [self AcrossLabel].text = @"Processed!";
        [self IsThisRedButton].enabled = true;
        [[self.view  viewWithTag:101] setNeedsDisplay];
        _timerCount = 0;
        _ColorReplaced = true;
        _shouldDisplayFeedback = true;
        

        
    }

/////TODO: Change this into a switch statement.
   
    image = [self drawBoxAroundTarget:image];
  
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
   
    NSInteger  targ = (int)[self TargetSizeSlider].value;
    
    top = cvPoint(center.x - targ, center.y - targ);
    bottom = cvPoint(center.x +targ, center.y +targ);
    
    cv::rectangle(source, top, bottom, CV_RGB(50, 60, 100));
    
    return source;
}


-(UIImage*)createThumbnail:(cv::Mat)source :(UIImage *)tImage{
    
    NSInteger iRows = source.rows;
    NSInteger iCols = source.cols;
    
    ///We get the center of the image by dividing rows
    ////and cols by 2. Then we can subtract ten from the x and y then add 10 to x, y and get us the rectangle coords
    CvPoint center = cvPoint(iCols/2,iRows/2);  
  
    CvRect sampleRect = cvRect(center.x - 10, center.y - 10, 20, 20);

    ///Copying only the target area
    cv::Mat  crop(source, sampleRect);

    tImage = [self imageWithCVMat:(cv::Mat(source,sampleRect))];

    
    return tImage;
}


/**
 Is this green
 */

/////Going to try removing one of these mat copies by
/////removing the rectangle code and putting it into the process image loop

//-(void)isThisGreen:(cv::Mat)source :(NSString*)color{
-(void)isThisGreen:(cv::Mat)img :(NSString*)color{
    
    NSString * badwaytodothis = [_matcher flannFinder:img :color];
    
    if([badwaytodothis isEqual: @"g"])
    {
       _wasItGreen = true;
    }
    else if ([badwaytodothis isEqual: @"r"])
    {
        _wasItRed = true;
    }
    else{
       _wasItGreen = false;
       _wasItRed = false;
    }
    _timerCount = 0;
    
    /////////The following is the new, slow as anything matching code
    /*

     _wasItGreen = false;
     _wasItRed = false;
     
     
     if ([_matcher matchColorFromMat:img :color])
    {
        _wasItGreen = true;
        _timerCount = 0;
    }
     
     */
    /////////////THE CODE BELOW IS BROKEN
    //////////////The following was the old match code. Trying new match code
/*
    
    int count =0;
    long b = 0;
    long g = 0;
    long r = 0;
    for(int row = 0; row < img.rows; ++row){
      uchar* p = img.ptr(row);
        
        for(int col = 0; col < img.cols*3; ++col) {
            // *p++;  //points to each pixel B,G,R value in turn assuming a CV_8UC3 color image
            int B = [[NSNumber numberWithUnsignedChar:p[0]] integerValue] ;
            int G = [[NSNumber numberWithUnsignedChar:p[1]] integerValue] ;
            int R = [[NSNumber numberWithUnsignedChar:p[2]] integerValue] ;
          count++;
            b += B;
            g += G;
            r += R;
          // NSLog(@"B:%li G:%x R:%x Number: %i", b,p[1],p[2],count);
        }
        
    }
/////We're going to try using a timer so that when 3 seconds have passed, the image vanishes.

    _timerCount = 0;
// NSLog(@"B:%li G:%li R:%li Number: %i", b,g,r,count);
  

    [self greenTestHelper:b :g :r :count :color];
  */
}



///TODO: Set this up to return a BOOL based on a string passed with the rest of the info.
///Change all the flag setting to the calling function

/////Still doesn't use the NSString color for anything
    
-(void)greenTestHelper:(long)b :(long)g :(long)r :(int)count :(NSString*)color{
 //   NSLog(@"Firing Test Helper");
////Get the average RGB values of each
    _wasItGreen = false;
    _wasItRed = false;
   NSNumber *B,*G,*R;
 
    R = [NSNumber numberWithInt:(r/count)];
    G = [NSNumber numberWithInt:(g/count)];
    B = [NSNumber numberWithInt:(b/count)];
    
 //NSLog(@"Inside Green Test Helper: B:%@ G:%@ R:%@ Number: %i", B,G,R,count);
    
    
    
    R = [NSNumber numberWithFloat:(r/count)];
    G = [NSNumber numberWithFloat:(g/count)];
    B = [NSNumber numberWithFloat:(b/count)];
    
    NSArray * testArray = [NSArray arrayWithObjects:R,G,B, nil];

    
    if ([[_matcher findDistance:testArray]  isEqual: @"g"]){

        // NSLog(@"tested Green");
        _wasItGreen = true;
       
    }
    else if ([[_matcher findDistance:testArray]  isEqual: @"r"]){

       // NSLog(@"tested Red");
       
        _wasItRed = true;
    }
  

}





/**
 For conversion of foundation images to OpenCV mats
 */
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
 Once 3 seconds has elapsed and no additional samples taken, remove feedback
 */

-(void)timerCallback{

    _timerCount += 1;
    
    if(!_isDetectorOn){
        if(_timerCount > 120){
            _timerCount = 0;
            _shouldDisplayFeedback = false;
            [self AcrossLabel].text = @"";
            [self AcrossLabel].hidden = true;
            _thumb.hidden = true;
            _ColorReplaced = false;
        }
    
        if (_shouldDisplayFeedback) {
            
            if(_wasItRed)
                [self AcrossLabel].text = @"RED!";
            else if(_wasItGreen)
                [self AcrossLabel].text = @"GREEN!";
            else if (!_wasItGreen && [_targetColor isEqual:(NSMutableString*)@"g"])
                [self AcrossLabel].text = @"It wasn't green!";
            else if (!_wasItRed && [_targetColor isEqual:(NSMutableString*)@"r"])
                [self AcrossLabel].text = @"It wasn't red!";
            else if (_ColorReplaced){
                _timerCount = 0;
                [self AcrossLabel].text = @"Processed";
                _IsThisRedButton.enabled = false;
                _thumb.hidden = false;
                [[self.view  viewWithTag:101] setNeedsDisplay];
            }
        
        [self AcrossLabel].hidden = false;
        
        }
    
    }
    else {
        ///so the detector is on
        [self AcrossLabel].hidden = false;
        if(_wasItGreen)
            [self AcrossLabel].text = @"GREEN!";
        else
            [self AcrossLabel].text = @"";
    }
   // [[self.view  viewWithTag:101] setNeedsDisplay];
    if(_ColorReplaced){
        _thumb.hidden = false;
    [self AcrossLabel].text = @"Processed!";
        _IsThisRedButton.enabled = true;
    }
    else{
        _thumb.hidden = true;
        _IsThisRedButton.enabled = true;
    }
    [[self view] setNeedsDisplay];
    
}

-(void)timerFire{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];

    if([self respondsToSelector:@selector(timerCallback)]){

    }
}

-(void)processJSON{
    
    ///First we pull the data from the file
    
    NSError* noError;
    
    NSData *jsFile = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colordata2" ofType:@"js"]];
  
    _json = [NSJSONSerialization JSONObjectWithData:jsFile options:0 error:&noError];

    NSLog(@"JSON count: %i", _json.count);
    
    ///We're going to see if the data loaded correctly.
 //   for(int i = 0; i< _json.count; i++){
//       NSLog(@"%@ %@ %@ %@", [[_json objectAtIndex:i] objectForKey:@"name"],[[_json objectAtIndex:i] objectForKey:@"r"],[[_json objectAtIndex:i] objectForKey:@"g"],[[_json objectAtIndex:i] objectForKey:@"b"]);
//    }
    
}









@end
