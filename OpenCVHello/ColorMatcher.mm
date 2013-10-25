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


-(id)initWithColorFileName:(NSString*)colorCoordsFileName{
    if (self = [super init]){
        
        NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
        
        _colors =  [[NSArray alloc] initWithContentsOfFile:path];
        
        
         cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
       // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
     //  cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_32F);

        for(int i=0; i<_colors.count; i++){
            
            //We have to bring the vals in from the dictionary as ints that NSinteger will accept
            NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"red"] intValue];
            NSInteger g = [[[_colors objectAtIndex:i] objectForKey:@"green"] intValue];
            NSInteger b = [[[_colors objectAtIndex:i] objectForKey:@"blue"] intValue];
       
      
            colorCoords.at<int>(i,0) = r;
            colorCoords.at<int>(i,1) = g;
            colorCoords.at<int>(i,2) = b;
        }
        _colorCoords = colorCoords.clone();
    }
    
    NSLog(@"Colors Count %i", _colors.count);
    return self;
}



-(id)initWithJSON:(NSArray*)colorJson{
    if (self = [super init]){
        
      //  NSString *path = [[NSBundle mainBundle] pathForResource:colorCoordsFileName ofType:@"plist"];
        
        _colors = colorJson;
        
        
        cv::Mat colorCoords = cv::Mat(_colors.count,3,CV_32S);
        // cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_8UC3);
        
        //  cv::Mat sampleMat = cv::Mat(_colors.count,3,CV_32F);
        
        for(int i=0; i<_colors.count; i++){
            
            //We have to bring the vals in from the dictionary as ints that NSinteger will accept
            NSInteger r = [[[_colors objectAtIndex:i] objectForKey:@"r"] intValue];
            NSInteger g = [[[_colors objectAtIndex:i] objectForKey:@"g"] intValue];
            NSInteger b = [[[_colors objectAtIndex:i] objectForKey:@"b"] intValue];
            
            
            colorCoords.at<int>(i,0) = r;
            colorCoords.at<int>(i,1) = g;
            colorCoords.at<int>(i,2) = b;
        }
        _colorCoords = colorCoords.clone();
    }
    
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
  
    for(int i = 0; i<_colors.count; i++){
        NSInteger R = [[[_colors objectAtIndex:i] objectForKey:@"red"] intValue];
        NSInteger G = [[[_colors objectAtIndex:i] objectForKey:@"green"] intValue];
        NSInteger B = [[[_colors objectAtIndex:i] objectForKey:@"blue"] intValue];
        
      ////Find Euclidean
        double dx = abs(R-r);
        double dy = abs(G-g);
        double dz = abs(B-b);
        double dist = sqrt(dx*dx + dy*dy + dz*dz);
        ///Update closest
        if(dist < curShortest){
            curShortest = dist;
            indexOfClosest = i;
        }
        
    }
   
    NSLog(@"%@, r %@, g %@ b %@",[[_colors objectAtIndex:indexOfClosest] objectForKey:@"friendlyname"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"red"], [[_colors objectAtIndex:indexOfClosest] objectForKey:@"green"],[[_colors objectAtIndex:indexOfClosest] objectForKey:@"blue"]);
    
    return [[_colors objectAtIndex:indexOfClosest] objectForKey:@"friendlyname"];
}




@end



