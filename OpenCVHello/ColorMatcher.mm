//
//  ColorMatcher.m
//  IsItGreen2
//
//  Created by Brendan Hinman on 10/18/13.
//  Copyright (c) 2013 Brendan Hinman. All rights reserved.
//

#import "ColorMatcher.h"

@implementation ColorMatcher

@synthesize colors = _colors;
@synthesize colorCoords = _colorCoords;


//+(ColorMatcher*):(NSString*)colorCoordsFileName{
/*
+(id)ColorMatcherWithcolorCoordsFileName:(NSString*)colorCoordsFileName{
    
    
   ColorMatcher * newMatcher = [[ColorMatcher alloc] init];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
    
     _colors =  [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    //_colors] = [[NSMutableArray alloc] initWithContentsOfFile:path];
  
    return newMatcher;
}
 int vIn = 0;
 unsigned char vOut = (unsigned char)vIn;

 
*/

-(id)initWithColorFileName:(NSString*)colorCoordsFileName{
    if (self = [super init]){
        
        NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
        
        _colors =  [[NSMutableArray alloc] initWithContentsOfFile:path];
        
        
         cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
       // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
     //  cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_32F);

        for(int i=0; i<_colors.count; i++){
            
           
            
//            NSInteger r = (NSInteger)[[_colors objectAtIndex:i] objectForKey:@"red"];
//            NSInteger g = (NSInteger)[[_colors objectAtIndex:i] objectForKey:@"green"];
//            int b = (int)[[_colors objectAtIndex:i] objectForKey:@"blue"];
            
            NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"red"] intValue];
            NSInteger g = [[[_colors objectAtIndex:i] objectForKey:@"green"] intValue];
            NSInteger b = [[[_colors objectAtIndex:i] objectForKey:@"blue"] intValue];
       
        //    NSLog(@"%@ r %@ g %@ b %@", [[_colors objectAtIndex:i] objectForKey:@"name"], [[_colors objectAtIndex:i] objectForKey:@"red"],[[_colors objectAtIndex:i] objectForKey:@"green"],[[_colors objectAtIndex:i] objectForKey:@"blue"]);

            
 //      Converting ints to uchars
            
       // unsigned char RU = (unsigned char)r;
       // unsigned char GU = (unsigned char)g;
       // unsigned char BU = (unsigned char)b;
         
            //NSString * RU = (NSString*)[[_colors objectAtIndex:i] objectForKey:@"xred"];
            //NSString * GU = (NSString*)[[_colors objectAtIndex:i] objectForKey:@"xgreen"];
            //NSString * BU = (NSString*)[[_colors objectAtIndex:i] objectForKey:@"xblue"];
           
            
            
            colorCoords.at<int>(i,0) = r;
            colorCoords.at<int>(i,1) = g;
            colorCoords.at<int>(i,2) = b;
            
         //   sampleMat.at<uchar>(i,0) = RU;
          //  sampleMat.at<uchar>(i,1) = GU;
          //  sampleMat.at<uchar>(i,2) = BU;
       //   NSLog(@"%@ r %x g %x b %x RU %x GU %x BU %x", [[_colors objectAtIndex:i] objectForKey:@"name"], r,g,b,RU,GU,BU);
          //     NSLog(@"%@ r %i g %i b %i", [[_colors objectAtIndex:i] objectForKey:@"name"], r,g,b);
            
            
        }
        
        
        
        _colorCoords = colorCoords.clone();
    }
    /*
    for(int row = 0 ; row < _colorCoords.rows ; row++){
		for(int col = 0 ; col < _colorCoords.cols ; col++){
            NSLog(@"%c",_colorCoords.at<uchar>(row,col));
		}
        NSLog(@"");
	}
    */
    
    NSLog(@"Colors Count %i", _colors.count);
    return self;
}


-(NSString*)matchFromMat:(cv::Mat)sampleMat{
    
   NSLog(@"%@ %i rows %i", @"Color Coord columns", _colorCoords.cols, _colorCoords.rows);
   NSLog(@"%@ %i rows %i", @"Sample Mat columns", sampleMat.cols, sampleMat.rows);
    
   ////Wait a second why not just find the Euclian distance between all of the points and just go with the smallest one?
   
    ////Appparently FLANN only accepts CV_32f
    ////Going to try converting them here
/*

    if(_colorCoords.type()!=CV_32F) {
      _colorCoords.convertTo(_colorCoords, CV_32F);
  }
    

    if(sampleMat.type()!=CV_32F) {
        sampleMat.convertTo(sampleMat, CV_32F);
    }

    NSLog(@" as Floats r %i g %i b %f", _colorCoords.at<int>(1,0),_colorCoords.at<int>(1,1),_colorCoords.at<Float32>(1,2));

  */
    
    
    ///Creating kdtree with 5 random trees
 // cv::flann::KMeansIndexParams indexParams(5);
//cv::flann::AutotunedIndexParams indexParams(2);
//cv::flann::LinearIndexParams indexParams;
    
    cv::flann::IndexParams indexParams;
    
    
    ///Create the index to search
    ///According to this: http://code.opencv.org/issues/1947
    ///I should directly use the flann index
   // cvflann::Index kdtree(_colorCoords,indexParams);
    

    
  cv::flann::Index kdtree(_colorCoords,indexParams);
    
    ///Creation of a single query. I guess it's a vector?
    
    cv::vector<int> singleQuery;
    cv::vector<int> index(1);
    cv::vector<Float32> dist(1);
    ///populate the query, in reverse order I guess

    
    singleQuery.push_back(sampleMat.at<int>(0,2));
    singleQuery.push_back(sampleMat.at<int>(0,1));
    singleQuery.push_back(sampleMat.at<int>(0,0));

    
    /*
    singleQuery.push_back(sampleMat.at<uchar>(0,2));
    singleQuery.push_back(sampleMat.at<uchar>(0,1));
    singleQuery.push_back(sampleMat.at<uchar>(0,0));
    */
    

    
    
    kdtree.knnSearch(singleQuery, index, dist, 1, cv::flann::SearchParams(64));
    
    NSLog(@"Index, dist %x , %f", index[0], dist[0]);
    
  
    return @"test";
}



-(NSString*)findDistance:(NSArray*)sample{
    
   
    
    float curShortest = FLT_MAX;
    int indexOfClosest = 0;
    
    NSInteger r = [[sample objectAtIndex:0] intValue];
    NSInteger g = [[sample objectAtIndex:1] intValue];
    NSInteger b = [[sample objectAtIndex:2] intValue];
    //int g = (int)[sample objectAtIndex:1];
    //int b = (int)[sample objectAtIndex:2];
    
    for(int i = 0; i<_colors.count; i++){
        
       ///This was the old way.
//    int R = (int)[[_colors objectAtIndex:i]objectForKey:@"red"];
 //   int G = (int)[[_colors objectAtIndex:i]objectForKey:@"green"];
 //   int B = (int)[[_colors objectAtIndex:i]objectForKey:@"blue"];
        NSInteger R = [[[_colors objectAtIndex:i] objectForKey:@"red"] intValue];
        NSInteger G = [[[_colors objectAtIndex:i] objectForKey:@"green"] intValue];
        NSInteger B = [[[_colors objectAtIndex:i] objectForKey:@"blue"] intValue];
        
        
      ////Find Euclidean
        double dx = abs(R-r);
        double dy = abs(G-g);
        double dz = abs(B-b);
        double dist = sqrt(dx*dx + dy*dy + dz*dz);
        
     
 
        if(dist < curShortest){
            curShortest = dist;
            indexOfClosest = i;
        }
        
    }
    
    
    ////We're going to calculate the Euclidian distance between the color
    
    NSLog(@"%@, r %@, g %@ b %@",[[_colors objectAtIndex:indexOfClosest] objectForKey:@"friendlyname"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"red"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"green"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"blue"]);
    
    return [[_colors objectAtIndex:indexOfClosest] objectForKey:@"friendlyname"];
}




@end



