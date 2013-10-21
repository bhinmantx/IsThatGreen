//
//  ColorMatcher.h
//  IsItGreen2
//
//  Created by Brendan Hinman on 10/18/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface ColorMatcher : NSObject{

NSMutableArray *_colors;
    cv::Mat _colorCoords;
}

@property (strong,nonatomic) NSMutableArray * colors;
@property (nonatomic) cv::Mat  colorCoords;


//+(ColorMatcher*):(NSString*)colorCoordsFileName;

//+(id)ColorMatcherWithcolorCoordsFileName:(NSString*);

-(id)initWithColorFileName:(NSString*)colorCoordsFileName;
-(NSString*)matchFromMat:(cv::Mat)sampleMat;
-(NSString*)findDistance:(NSArray*)sample;

@end